#!/usr/bin/env swift
// A minimal MCP server over stdio. `TC_MCP_MODE` picks which way it misbehaves.

import Darwin
import Foundation

let mode = ProcessInfo.processInfo.environment["TC_MCP_MODE"] ?? "normal"

let tools: [[String: Any]] = [
    [
        "name": "read_file",
        "description": "Reads a file.",
        "inputSchema": [
            "type": "object",
            "properties": ["path": ["type": "string"]],
        ],
    ],
    [
        "name": "write_file",
        "description": "Writes a file.",
    ],
]

func serializeJSON(_ object: Any) -> String {
    guard let data = try? JSONSerialization.data(
        withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]),
        let text = String(data: data, encoding: .utf8)
    else { return "{}" }
    return text
}

func send(_ message: [String: Any]) {
    let line = serializeJSON(message) + "\n"
    let bytes = Array(line.utf8)
    bytes.withUnsafeBytes { raw in
        guard let base = raw.baseAddress else { return }
        var written = 0
        while written < bytes.count {
            let n = Darwin.write(STDOUT_FILENO, base.advanced(by: written), bytes.count - written)
            if n > 0 {
                written += n
            } else if n < 0 && (errno == EINTR || errno == EAGAIN) {
                usleep(5000)
            } else {
                break
            }
        }
    }
}

func reply(_ id: Any, _ result: [String: Any]) {
    send(["jsonrpc": "2.0", "id": id, "result": result])
}

func readLines() -> AnySequence<String> {
    var pending = Data()
    var eof = false
    let chunkSize = 65_536
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: chunkSize)

    return AnySequence {
        AnyIterator {
            while true {
                if let nl = pending.firstIndex(of: 0x0A) {
                    let lineData = pending.subdata(in: pending.startIndex..<nl)
                    pending.removeSubrange(pending.startIndex...nl)
                    return String(data: lineData, encoding: .utf8) ?? ""
                }
                if eof {
                    buffer.deallocate()
                    return nil
                }
                let n = Darwin.read(STDIN_FILENO, buffer, chunkSize)
                if n > 0 {
                    pending.append(buffer, count: n)
                } else if n == 0 {
                    eof = true
                } else if errno == EAGAIN || errno == EINTR {
                    usleep(5000)
                } else {
                    eof = true
                }
            }
        }
    }
}

for line in readLines() {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { continue }
    guard let data = line.data(using: .utf8),
        let message = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { continue }

    let method = message["method"] as? String
    let id = message["id"].flatMap { $0 is NSNull ? nil : $0 }

    if method == "initialize" {
        if mode == "die-on-initialize" {
            FileHandle.standardError.write(Data("the server refused to start\n".utf8))
            exit(3)
        }
        if let id {
            reply(id, ["protocolVersion": "2025-06-18", "capabilities": ["tools": [String: Any]()]])
        }
    } else if method == "notifications/initialized" {
        if mode == "unsolicited-request" {
            send(["jsonrpc": "2.0", "id": "srv-1", "method": "sampling/createMessage"])
        }
    } else if method == "tools/list" {
        if let id {
            reply(id, ["tools": tools])
        }
    } else if method == "tools/call" {
        if mode == "die-on-call" { exit(4) }
        if mode == "hang-on-call" { continue }
        let params = message["params"] as? [String: Any] ?? [:]
        let name = params["name"] as? String
        if let id {
            if name == "write_file" {
                reply(id, ["isError": true, "content": [["type": "text", "text": "read only"]]])
            } else {
                let arguments = params["arguments"] ?? [String: Any]()
                let echoed = serializeJSON(arguments)
                reply(id, ["content": [["type": "text", "text": echoed]]])
            }
        }
    } else if let id {
        send(["jsonrpc": "2.0", "id": id, "error": ["code": -32601, "message": "no"]])
    }
}
