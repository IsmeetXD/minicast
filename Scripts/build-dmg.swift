#!/usr/bin/env swift
// Build a signed Tinycast.app into build/Tinycast-<version>.dmg. Usage: swift Scripts/build-dmg.swift [version]

import Foundation

func findRepoRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .resolvingSymlinksInPath()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

func makeEnvironment() -> [String: String] {
    var env = ProcessInfo.processInfo.environment
    if env["DEVELOPER_DIR"] == nil {
        let xcodeDev = "/Applications/Xcode.app/Contents/Developer"
        if FileManager.default.fileExists(atPath: xcodeDev) {
            env["DEVELOPER_DIR"] = xcodeDev
        }
    }
    return env
}

@discardableResult
func runCommand(
    _ executable: String,
    _ arguments: [String],
    environment: [String: String],
    captureStdout: Bool = false,
    quietStdout: Bool = false
) throws -> (status: Int32, stdout: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.environment = environment

    let pipe: Pipe? = captureStdout ? Pipe() : nil
    if let pipe {
        process.standardOutput = pipe
    } else if quietStdout {
        process.standardOutput = FileHandle.nullDevice
    }

    try process.run()
    var output = ""
    if let pipe {
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        output = String(data: data, encoding: .utf8) ?? ""
    }
    process.waitUntilExit()
    return (process.terminationStatus, output)
}

func writeStderr(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

let root = findRepoRoot()
let fm = FileManager.default
fm.changeCurrentDirectoryPath(root.path)

let env = makeEnvironment()
let identity = "Tinycast Self-Signed"
let derived = "build/DerivedData"

let idCheck = try runCommand(
    "/usr/bin/security", ["find-identity", "-p", "codesigning"],
    environment: env, captureStdout: true)
guard idCheck.status == 0, idCheck.stdout.contains(identity) else {
    writeStderr("✗ '\(identity)' code-signing identity not found — see README.md to create it once.")
    exit(1)
}

print("▸ Building signed Tinycast.app (Release)…")
var xcodebuildArgs = [
    "-project", "Tinycast.xcodeproj",
    "-scheme", "Tinycast",
    "-configuration", "Release",
    "-derivedDataPath", derived,
    "CODE_SIGN_STYLE=Manual",
    "CODE_SIGN_IDENTITY=\(identity)",
    "OTHER_CODE_SIGN_FLAGS=--timestamp=none",
]
if let versionOverride = CommandLine.arguments.dropFirst().first, !versionOverride.isEmpty {
    xcodebuildArgs.append("MARKETING_VERSION=\(versionOverride)")
}
xcodebuildArgs.append("build")

let buildResult = try runCommand("/usr/bin/xcodebuild", xcodebuildArgs, environment: env)
guard buildResult.status == 0 else { exit(buildResult.status) }

let appURL = root.appending(path: "\(derived)/Build/Products/Release/Tinycast.app")
let plistURL = appURL.appending(path: "Contents/Info.plist")
let plistData = try Data(contentsOf: plistURL)
guard let plist = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
    let version = plist["CFBundleShortVersionString"] as? String
else {
    writeStderr("✗ Could not read CFBundleShortVersionString from \(plistURL.path)")
    exit(1)
}

let dmgPath = "build/Tinycast-\(version).dmg"
let dmgURL = root.appending(path: dmgPath)
print("▸ Packaging \(dmgPath)")

let stageURL = fm.temporaryDirectory.appending(path: "tinycast-dmg-\(UUID().uuidString)")
try fm.createDirectory(at: stageURL, withIntermediateDirectories: true)
defer { try? fm.removeItem(at: stageURL) }

try fm.copyItem(at: appURL, to: stageURL.appending(path: "Tinycast.app"))
try fm.createSymbolicLink(
    at: stageURL.appending(path: "Applications"),
    withDestinationURL: URL(fileURLWithPath: "/Applications"))
try? fm.removeItem(at: dmgURL)

let dmgResult = try runCommand(
    "/usr/sbin/diskutil",
    ["image", "create", "from", stageURL.path, "--format", "UDZO", "--volumeName", "Tinycast", dmgURL.path],
    environment: env, quietStdout: true)
guard dmgResult.status == 0 else {
    writeStderr("✗ diskutil image create failed")
    exit(dmgResult.status)
}

print("✓ \(dmgPath)")
