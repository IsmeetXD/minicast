#!/usr/bin/env swift
// Local HTTP OAuth + MCP stub server listening on 127.0.0.1:4963 for MCPOAuthTests.

import Darwin
import Foundation

signal(SIGPIPE, SIG_IGN)

let base = "http://127.0.0.1:4963"
let supplied = "supplied+client"
let issued: [String: Any] = [
    "access_token": "fixture-access",
    "token_type": "Bearer",
    "refresh_token": "rotated-refresh",
    "expires_in": 3600,
]

final class StubState: @unchecked Sendable {
    let lock = NSLock()
    var refreshes = 0
    var calls = 0
    var redirects = 0
    var held: [() -> Void] = []
    var registrations = 0
    var clientAuth: [String] = []
}

let state = StubState()

func writeAll(_ fd: Int32, _ data: Data) {
    data.withUnsafeBytes { raw in
        guard let base = raw.baseAddress else { return }
        var sent = 0
        while sent < data.count {
            let n = Darwin.write(fd, base.advanced(by: sent), data.count - sent)
            if n > 0 {
                sent += n
            } else if n < 0 && (errno == EINTR || errno == EAGAIN) {
                usleep(1000)
            } else {
                break
            }
        }
    }
}

func sendResponse(
    _ fd: Int32, status: Int, headers: [String: String] = [:], body: Data = Data()
) {
    let statusText: String = switch status {
    case 200: "OK"
    case 201: "Created"
    case 202: "Accepted"
    case 307: "Temporary Redirect"
    case 400: "Bad Request"
    case 401: "Unauthorized"
    case 404: "Not Found"
    case 503: "Service Unavailable"
    default: "Status"
    }
    var head = "HTTP/1.1 \(status) \(statusText)\r\n"
    head += "Content-Length: \(body.count)\r\n"
    head += "Connection: close\r\n"
    for (k, v) in headers {
        head += "\(k): \(v)\r\n"
    }
    head += "\r\n"
    writeAll(fd, Data(head.utf8))
    if !body.isEmpty {
        writeAll(fd, body)
    }
    Darwin.close(fd)
}

func sendJSON(
    _ fd: Int32, status: Int, body: Any, headers: [String: String] = [:]
) {
    let data =
        (try? JSONSerialization.data(
            withJSONObject: body, options: [.withoutEscapingSlashes])) ?? Data("{}".utf8)
    var allHeaders = ["Content-Type": "application/json"]
    for (k, v) in headers { allHeaders[k] = v }
    sendResponse(fd, status: status, headers: allHeaders, body: data)
}

func destroySocket(_ fd: Int32) {
    var linger = Darwin.linger(l_onoff: 1, l_linger: 0)
    setsockopt(fd, SOL_SOCKET, SO_LINGER, &linger, socklen_t(MemoryLayout<Darwin.linger>.size))
    Darwin.close(fd)
}

func parseForm(_ raw: String) -> [String: String] {
    var result: [String: String] = [:]
    for pair in raw.split(separator: "&", omittingEmptySubsequences: true) {
        let parts = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        let keyRaw = String(parts[0]).replacingOccurrences(of: "+", with: " ")
        let valRaw = parts.count > 1 ? String(parts[1]).replacingOccurrences(of: "+", with: " ") : ""
        let key = keyRaw.removingPercentEncoding ?? keyRaw
        let val = valRaw.removingPercentEncoding ?? valRaw
        result[key] = val
    }
    return result
}

func decodeChunked(_ data: Data) -> Data? {
    var idx = data.startIndex
    var decoded = Data()
    let crlf = Data("\r\n".utf8)
    while idx < data.endIndex {
        guard let lineEnd = data.range(of: crlf, in: idx..<data.endIndex) else { return nil }
        let sizeStr = String(data: data[idx..<lineEnd.lowerBound], encoding: .utf8)?
            .split(separator: ";", maxSplits: 1).first
            .map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
        guard let chunkLen = Int(sizeStr, radix: 16) else { return nil }
        idx = lineEnd.upperBound
        if chunkLen == 0 {
            if data.range(of: crlf, in: idx..<data.endIndex) != nil || idx <= data.endIndex {
                return decoded
            }
            return nil
        }
        guard idx + chunkLen + 2 <= data.endIndex else { return nil }
        decoded.append(data[idx..<(idx + chunkLen)])
        idx += chunkLen + 2
    }
    return nil
}

func readHTTPRequest(_ fd: Int32) -> (target: String, headers: [String: String], body: String)? {
    var buffer = Data()
    let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: 16_384)
    defer { temp.deallocate() }
    let separator = Data("\r\n\r\n".utf8)

    var headerEndRange: Range<Data.Index>?
    while headerEndRange == nil {
        let n = Darwin.read(fd, temp, 16_384)
        if n > 0 {
            buffer.append(temp, count: n)
            headerEndRange = buffer.range(of: separator)
        } else if n < 0 && (errno == EINTR || errno == EAGAIN) {
            usleep(1000)
        } else {
            return nil
        }
    }

    guard let sep = headerEndRange,
        let headerText = String(data: buffer[..<sep.lowerBound], encoding: .utf8)
    else { return nil }

    let lines = headerText.components(separatedBy: "\r\n")
    guard let requestLine = lines.first else { return nil }
    let parts = requestLine.split(separator: " ", omittingEmptySubsequences: true)
    guard parts.count >= 2 else { return nil }
    let target = String(parts[1])

    var headers: [String: String] = [:]
    for line in lines.dropFirst() {
        if let colon = line.firstIndex(of: ":") {
            let name = line[..<colon].trimmingCharacters(in: .whitespaces).lowercased()
            let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            headers[name] = value
        }
    }

    var bodyData = buffer[sep.upperBound...]
    if let te = headers["transfer-encoding"]?.lowercased(), te.contains("chunked") {
        var assembled = Data(bodyData)
        while decodeChunked(assembled) == nil {
            let n = Darwin.read(fd, temp, 16_384)
            if n > 0 {
                assembled.append(temp, count: n)
            } else if n < 0 && (errno == EINTR || errno == EAGAIN) {
                usleep(1000)
            } else {
                break
            }
        }
        let decoded = decodeChunked(assembled) ?? assembled
        return (target, headers, String(data: decoded, encoding: .utf8) ?? "")
    }

    let contentLength = Int(headers["content-length"] ?? "") ?? 0
    var fullBody = Data(bodyData)
    while fullBody.count < contentLength {
        let n = Darwin.read(fd, temp, 16_384)
        if n > 0 {
            fullBody.append(temp, count: n)
        } else if n < 0 && (errno == EINTR || errno == EAGAIN) {
            usleep(1000)
        } else {
            break
        }
    }
    if fullBody.count > contentLength && contentLength > 0 {
        fullBody = fullBody.prefix(contentLength)
    }
    return (target, headers, String(data: fullBody, encoding: .utf8) ?? "")
}

func handleConnection(_ fd: Int32) {
    var yes: Int32 = 1
    setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &yes, socklen_t(MemoryLayout<Int32>.size))

    guard let req = readHTTPRequest(fd) else {
        Darwin.close(fd)
        return
    }

    let metadata: [String: Any] = [
        "issuer": base,
        "authorization_endpoint": base + "/authorize",
        "token_endpoint": base + "/token",
        "registration_endpoint": base + "/register",
        "code_challenge_methods_supported": ["S256"],
        "token_endpoint_auth_methods_supported": ["none"],
        "authorization_response_iss_parameter_supported": true,
    ]

    switch req.target {
    case "/.well-known/oauth-protected-resource/mcp":
        sendJSON(
            fd, status: 200,
            body: ["resource": base + "/mcp", "authorization_servers": [base], "scopes_supported": ["read"]])

    case "/.well-known/oauth-authorization-server":
        sendJSON(fd, status: 200, body: metadata)

    case "/register":
        state.lock.lock()
        state.registrations += 1
        state.lock.unlock()
        guard let data = req.body.data(using: .utf8),
            let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            (body["application_type"] as? String) == "native",
            (body["token_endpoint_auth_method"] as? String) == "none",
            let grantTypes = body["grant_types"] as? [String],
            grantTypes.contains("refresh_token"),
            let redirectURIs = body["redirect_uris"] as? [String],
            redirectURIs.first == "http://127.0.0.1:4962/callback"
        else {
            sendJSON(fd, status: 400, body: [String: Any]())
            return
        }
        sendJSON(
            fd, status: 201,
            body: [
                "client_id": "fixture-client",
                "token_endpoint_auth_method": "none",
                "redirect_uris": redirectURIs,
            ])

    case "/token":
        let fields = parseForm(req.body)
        let client = fields["client_id"]
        if client == supplied {
            let auth = req.headers["authorization"] ?? ""
            let basic = auth.hasPrefix("Basic ") ? String(auth.dropFirst("Basic ".count)) : ""
            var used: [String] = []
            if !basic.isEmpty, let decoded = Data(base64Encoded: basic),
                let str = String(data: decoded, encoding: .utf8)
            {
                used.append("basic " + str)
            }
            if let secret = fields["client_secret"] {
                used.append("post " + secret)
            }
            state.lock.lock()
            state.clientAuth.append(used.isEmpty ? "none" : used.joined(separator: " + "))
            state.lock.unlock()
        } else if client != "fixture-client" {
            sendJSON(fd, status: 400, body: [String: Any]())
            return
        }

        if fields["resource"] != base + "/mcp" {
            sendJSON(fd, status: 400, body: [String: Any]())
            return
        }

        if fields["grant_type"] == "refresh_token" {
            let rt = fields["refresh_token"]
            if rt == "fixture-unavailable" {
                sendJSON(fd, status: 503, body: [String: Any]())
                return
            }
            if rt == "fixture-dropped" {
                destroySocket(fd)
                return
            }
            if rt == "fixture-held" {
                state.lock.lock()
                state.held.append { sendJSON(fd, status: 200, body: issued) }
                state.lock.unlock()
                return
            }
            state.lock.lock()
            state.refreshes += 1
            state.lock.unlock()
            if rt != "fixture-refresh" {
                sendJSON(fd, status: 400, body: ["error": "invalid_grant"])
                return
            }
        } else if fields["code"] != "fixture-code" || (fields["code_verifier"] ?? "").isEmpty {
            sendJSON(fd, status: 400, body: [String: Any]())
            return
        }

        sendJSON(fd, status: 200, body: issued)

    case "/redirect":
        sendResponse(fd, status: 307, headers: ["Location": base + "/unexpected"])

    case "/mcp-moved":
        sendResponse(fd, status: 307, headers: ["Location": base + "/mcp"])

    case "/mcp-away":
        sendResponse(fd, status: 307, headers: ["Location": "http://localhost:4963/unexpected"])

    case "/unexpected":
        state.lock.lock()
        state.redirects += 1
        state.lock.unlock()
        sendJSON(fd, status: 200, body: [String: Any]())

    case "/release":
        state.lock.lock()
        let pending = state.held
        state.held.removeAll()
        state.lock.unlock()
        for responder in pending { responder() }
        sendJSON(fd, status: 200, body: [String: Any]())

    case "/counts":
        state.lock.lock()
        let counts: [String: Any] = [
            "refreshes": state.refreshes,
            "calls": state.calls,
            "redirects": state.redirects,
            "held": state.held.count,
            "registrations": state.registrations,
        ]
        state.lock.unlock()
        sendJSON(fd, status: 200, body: counts)

    case "/client-auth":
        state.lock.lock()
        let auths = state.clientAuth
        state.lock.unlock()
        sendJSON(fd, status: 200, body: auths)

    case "/always-401":
        state.lock.lock()
        state.calls += 1
        state.lock.unlock()
        sendJSON(fd, status: 401, body: [String: Any]())

    case "/mcp":
        state.lock.lock()
        state.calls += 1
        state.lock.unlock()
        if req.headers["authorization"] != "Bearer fixture-access" {
            sendJSON(
                fd, status: 401, body: [String: Any](),
                headers: [
                    "WWW-Authenticate":
                        #"Bearer resource_metadata="\#(base)/.well-known/oauth-protected-resource/mcp", scope="read""#
                ])
            return
        }
        guard let data = req.body.data(using: .utf8),
            let request = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            sendJSON(fd, status: 400, body: [String: Any]())
            return
        }
        guard let requestID = request["id"], !(requestID is NSNull) else {
            sendResponse(fd, status: 202)
            return
        }
        let method = request["method"] as? String
        let result: [String: Any] =
            if method == "initialize" {
                [
                    "protocolVersion": "2025-03-26",
                    "capabilities": ["tools": [String: Any]()],
                    "serverInfo": ["name": "oauth-fixture", "version": "1"],
                ]
            } else if method == "tools/list" {
                [
                    "tools": [[
                        "name": "greet",
                        "description": "Say hello",
                        "inputSchema": ["type": "object", "properties": [String: Any]()],
                    ]]
                ]
            } else {
                ["content": [["type": "text", "text": "Hello from OAuth"]]]
            }
        sendJSON(fd, status: 200, body: ["jsonrpc": "2.0", "id": requestID, "result": result])

    default:
        sendJSON(fd, status: 404, body: [String: Any]())
    }
}

let serverFD = socket(AF_INET, SOCK_STREAM, 0)
guard serverFD >= 0 else {
    FileHandle.standardError.write(Data("\(errno)\n".utf8))
    exit(1)
}

var reuseAddr: Int32 = 1
setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &reuseAddr, socklen_t(MemoryLayout<Int32>.size))

var addr = sockaddr_in()
addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
addr.sin_family = sa_family_t(AF_INET)
addr.sin_port = UInt16(4963).bigEndian
addr.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))

let bindResult = withUnsafePointer(to: &addr) {
    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        Darwin.bind(serverFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
    }
}
guard bindResult == 0, listen(serverFD, 64) == 0 else {
    FileHandle.standardError.write(Data("\(errno)\n".utf8))
    exit(1)
}

FileHandle.standardOutput.write(Data("ready\n".utf8))
fflush(stdout)

while true {
    let clientFD = Darwin.accept(serverFD, nil, nil)
    if clientFD < 0 {
        if errno == EINTR { continue }
        break
    }
    DispatchQueue.global(qos: .userInitiated).async {
        handleConnection(clientFD)
    }
}
