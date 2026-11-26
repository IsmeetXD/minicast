#!/usr/bin/env swift
// Verify Settings search targets, string catalog localizations, and optional SwiftLint rules.
// Usage: swift Scripts/check.swift [--fix]

import Foundation

func findRepoRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .resolvingSymlinksInPath()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

func writeStderr(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

func swiftSources(in directory: URL) -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
        at: directory, includingPropertiesForKeys: [.isRegularFileKey])
    else { return [] }
    var files: [URL] = []
    for case let url as URL in enumerator where url.pathExtension == "swift" {
        files.append(url)
    }
    return files.sorted { $0.path < $1.path }
}

func checkSettingsSearch(root: URL) throws -> [String] {
    let anchorsURL = root.appending(path: "Tinycast/Features/Settings/SettingsAnchor.swift")
    let catalogURL = root.appending(path: "Tinycast/Features/Settings/SettingsSearchCatalog.swift")
    let anchorSource = try String(contentsOf: anchorsURL, encoding: .utf8)
    let catalogSource = try String(contentsOf: catalogURL, encoding: .utf8)
    let allSource = try swiftSources(in: root.appending(path: "Tinycast"))
        .map { try String(contentsOf: $0, encoding: .utf8) }
        .joined(separator: "\n")

    var problems: [String] = []

    let anchorPattern = try Regex(#"static let (\w+) = Self\(\s*tab: \.\w+, title: "([^"]+)""#)
    for match in anchorSource.matches(of: anchorPattern) {
        guard let nameSub = match[1].substring else { continue }
        let anchor = String(nameSub)
        let claimed =
            allSource.contains("SettingsSectionHeader(.\(anchor))")
            || allSource.contains("SettingsSectionHeader(anchor: .\(anchor))")
            || allSource.contains("settingsAnchor(.\(anchor))")
            || allSource.contains("anchor: .\(anchor)")
        if !claimed {
            problems.append("anchor .\(anchor) — no Section declares it")
        }
    }

    let rowPattern = try Regex(#"\.init\(\s*\.(\w+),\s*"((?:[^"\\]|\\.)*)""#)
    for match in catalogSource.matches(of: rowPattern) {
        guard let anchorSub = match[1].substring, let titleSub = match[2].substring else { continue }
        let anchor = String(anchorSub)
        let title = String(titleSub)
        let quoted = NSRegularExpression.escapedPattern(for: title)

        let featureToggle = try Regex(#"SettingsFeatureToggleLabel\(\s*anchor: \."# + anchor + #", title: ""# + quoted + #"""#)
        let settingsRow = try Regex(#"SettingsRow\(\s*title: ""# + quoted + #"",[\s\S]*?anchor: \."# + anchor)
        let featureSwitch = try Regex(#"anchor: \."# + anchor + #",\s*\n\s*enableTitle: ""# + quoted + #"""#)
        let categorySwitch = try Regex(#"anchor: \."# + anchor + #",\s*title: ""# + quoted + #"""#)

        let marked =
            allSource.contains("SettingsRowTitle(.\(anchor), \"\(title)\")")
            || allSource.firstMatch(of: featureToggle) != nil
            || allSource.firstMatch(of: settingsRow) != nil
            || allSource.firstMatch(of: featureSwitch) != nil
            || allSource.firstMatch(of: categorySwitch) != nil

        if !marked {
            problems.append("row “\(title)” (.\(anchor)) — no SettingsRowTitle marks it")
        }
    }

    return problems
}

func checkLocalizations(root: URL) throws -> [String] {
    let catalogs = [
        "Tinycast/Resources/Localizable.xcstrings",
        "Tinycast/Resources/InfoPlist.xcstrings",
    ]
    let languages: [String: [String]] = [
        "en": ["one", "other"],
        "de": ["one", "other"],
        "es": ["one", "many", "other"],
        "fr": ["one", "many", "other"],
        "ja": ["other"],
        "ko": ["other"],
        "pt": ["one", "many", "other"],
        "ru": ["one", "few", "many", "other"],
        "zh-Hans": ["other"],
    ]

    let subPattern = try NSRegularExpression(pattern: #"%(\d+\$)?#@([^@]+)@"#)
    let specPattern = try NSRegularExpression(
        pattern: #"%(?:(\d+)\$)?[-+ 0#]*\d*(?:\.\d+)?(hh|h|ll|l|q|L|z|t|j)?([@dDiuUxXoOfFeEgGcCsSpaA])"#)

    func specifiers(_ rawText: String, substitutions: [String: [String: Any]] = [:]) -> [String?] {
        var text = rawText as NSString
        let subMatches = subPattern.matches(in: rawText, range: NSRange(location: 0, length: text.length))
        if !subMatches.isEmpty {
            let mutable = NSMutableString(string: rawText)
            for match in subMatches.reversed() {
                let name = text.substring(with: match.range(at: 2))
                if let sub = substitutions[name],
                    let argNum = sub["argNum"] as? Int,
                    let fmt = sub["formatSpecifier"] as? String
                {
                    mutable.replaceCharacters(in: match.range, with: "%\(argNum)$\(fmt)")
                }
            }
            text = (mutable as String).replacingOccurrences(of: "%%", with: "") as NSString
        } else {
            text = rawText.replacingOccurrences(of: "%%", with: "") as NSString
        }

        var types: [String?] = []
        var next = 0
        for match in specPattern.matches(in: text as String, range: NSRange(location: 0, length: text.length)) {
            let explicitIndex: Int? =
                match.range(at: 1).location != NSNotFound
                ? Int(text.substring(with: match.range(at: 1))).map { $0 - 1 }
                : nil
            let idx = explicitIndex ?? { defer { next += 1 }; return next }()
            let lengthMod =
                match.range(at: 2).location != NSNotFound ? text.substring(with: match.range(at: 2)) : ""
            let conv = text.substring(with: match.range(at: 3))
            let type = lengthMod + conv
            while types.count <= idx { types.append(nil) }
            if let existing = types[idx], existing != type {
                types[idx] = "\(existing)/\(type)"
            } else {
                types[idx] = type
            }
        }
        return types
    }

    struct Leaf {
        let label: String
        let unit: [String: Any]
        let argumentTypes: [String?]?
        let substitutions: [String: [String: Any]]
    }

    func collectLeaves(
        _ localization: [String: Any], label: String = "", argumentTypes: [String?]? = nil
    ) -> [Leaf] {
        var found: [Leaf] = []
        let subs = localization["substitutions"] as? [String: [String: Any]] ?? [:]
        if let unit = localization["stringUnit"] as? [String: Any] {
            found.append(Leaf(label: label, unit: unit, argumentTypes: argumentTypes, substitutions: subs))
        }
        if let variations = localization["variations"] as? [String: [String: [String: Any]]] {
            for (kind, cases) in variations {
                for (name, child) in cases {
                    found.append(
                        contentsOf: collectLeaves(
                            child, label: "\(label)\(kind).\(name) ", argumentTypes: argumentTypes))
                }
            }
        }
        for (name, child) in subs {
            let fmt = child["formatSpecifier"] as? String
            found.append(
                contentsOf: collectLeaves(
                    child, label: "\(label)%#@\(name)@ ", argumentTypes: fmt.map { [$0] }))
        }
        return found
    }

    func pluralCases(_ obj: [String: Any]) -> [String] {
        let variations = obj["variations"] as? [String: Any]
        let plural = variations?["plural"] as? [String: Any]
        return plural.map { Array($0.keys) } ?? []
    }

    func checkPlurals(
        _ obj: [String: Any], required: [String], context: String, problems: inout [String]
    ) {
        let cases = pluralCases(obj)
        if !cases.isEmpty {
            let missing = required.filter { !cases.contains($0) }
            if !missing.isEmpty {
                problems.append("\(context) lacks plural \(missing.joined(separator: ", "))")
            }
        }
        if let subs = obj["substitutions"] as? [String: [String: Any]] {
            for (name, child) in subs {
                checkPlurals(child, required: required, context: "\(context) substitution \(name)", problems: &problems)
            }
        }
    }

    let letterSet = CharacterSet.letters
    let intSpecRegex = try Regex(#"^(?:ll|l)?[diu]$"#)
    var problems: [String] = []

    for relativePath in catalogs {
        let fileURL = root.appending(path: relativePath)
        let data = try Data(contentsOf: fileURL)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let strings = json["strings"] as? [String: [String: Any]]
        else { continue }
        let fileName = fileURL.lastPathComponent

        for (key, entry) in strings.sorted(by: { $0.key < $1.key }) {
            if (entry["extractionState"] as? String) == "stale" {
                problems.append("\(fileName): “\(key)” is stale — no source uses it any more")
                continue
            }
            if (entry["shouldTranslate"] as? Bool) == false || key.rangeOfCharacter(from: letterSet) == nil {
                continue
            }
            let localizations = entry["localizations"] as? [String: [String: Any]] ?? [:]
            let source = localizations["en"]
            let keyTypes = specifiers(key)
            let sourceValue = (source?["stringUnit"] as? [String: Any])?["value"] as? String ?? key
            let sourceSubs = source?["substitutions"] as? [String: [String: Any]] ?? [:]
            let sourceTypes = keyTypes.isEmpty ? specifiers(sourceValue, substitutions: sourceSubs) : keyTypes
            let isPlural = source.map { !pluralCases($0).isEmpty } ?? false

            for (language, required) in languages.sorted(by: { $0.key < $1.key }) {
                guard let localization = localizations[language] else {
                    if language != "en" {
                        problems.append("\(fileName): “\(key)” has no \(language) translation")
                    }
                    continue
                }
                let context = "\(fileName): “\(key)” \(language)"
                if isPlural && pluralCases(localization).isEmpty {
                    problems.append("\(context) lacks plural variations")
                }
                checkPlurals(localization, required: required, context: context, problems: &problems)

                let locSubs = localization["substitutions"] as? [String: [String: Any]] ?? [:]
                for sub in sourceSubs.values {
                    if !pluralCases(sub).isEmpty,
                        let subArgNum = sub["argNum"] as? Int,
                        !locSubs.values.contains(where: {
                            ($0["argNum"] as? Int) == subArgNum && !pluralCases($0).isEmpty
                        })
                    {
                        problems.append("\(context) lacks plural substitution for argument \(subArgNum)")
                    }
                }
                for (subName, sub) in locSubs {
                    if let argNum = sub["argNum"] as? Int,
                        let fmt = sub["formatSpecifier"] as? String,
                        argNum <= 0 || argNum > sourceTypes.count || sourceTypes[argNum - 1] != fmt
                    {
                        problems.append("\(context) substitution \(subName) has an invalid argument type or position")
                    }
                }

                let leaves = collectLeaves(localization)
                if leaves.isEmpty {
                    problems.append("\(context) has no translated text")
                }
                for leaf in leaves {
                    guard let state = leaf.unit["state"] as? String else { continue }
                    if state != "translated" {
                        problems.append("\(fileName): “\(key)” \(language) \(leaf.label)is \(state)")
                        continue
                    }
                    let value = leaf.unit["value"] as? String ?? ""
                    let nsVal = value as NSString
                    for subRef in subPattern.matches(in: value, range: NSRange(location: 0, length: nsVal.length)) {
                        let refName = nsVal.substring(with: subRef.range(at: 2))
                        if leaf.substitutions[refName] == nil {
                            problems.append("\(context) references missing substitution \(refName)")
                        }
                    }
                    let expected = leaf.argumentTypes ?? sourceTypes
                    if expected.isEmpty { continue }
                    let types = specifiers(value, substitutions: leaf.substitutions)
                    let countIdx: Int = leaf.label.contains("plural.")
                        ? (expected.firstIndex { t in
                            t.map { $0.firstMatch(of: intSpecRegex) != nil } ?? false
                        } ?? -1)
                        : -1
                    let mismatched =
                        types.enumerated().contains { i, type in
                            type != nil && (i >= expected.count || type != expected[i])
                        }
                        || types.count > expected.count
                        || expected.enumerated().contains { i, exp in
                            i != countIdx && (i >= types.count || exp != types[i])
                        }
                    if mismatched {
                        problems.append("\(context) \(leaf.label)has specifiers \(types) for \(expected)")
                    }
                }
            }
        }
    }

    return problems
}

func runSwiftLintIfAvailable(root: URL, fix: Bool) -> Int32 {
    let which = Process()
    which.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    which.arguments = ["which", "swiftlint"]
    which.standardOutput = FileHandle.nullDevice
    which.standardError = FileHandle.nullDevice
    try? which.run()
    which.waitUntilExit()
    guard which.terminationStatus == 0 else { return 0 }

    if fix {
        let fixProc = Process()
        fixProc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        fixProc.arguments = ["swiftlint", "--fix", "--quiet"]
        fixProc.currentDirectoryURL = root
        try? fixProc.run()
        fixProc.waitUntilExit()
    }
    let lintProc = Process()
    lintProc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    lintProc.arguments = ["swiftlint", "lint", "--quiet"]
    lintProc.currentDirectoryURL = root
    try? lintProc.run()
    lintProc.waitUntilExit()
    return lintProc.terminationStatus
}

let root = findRepoRoot()
FileManager.default.changeCurrentDirectoryPath(root.path)

let fix = CommandLine.arguments.contains("--fix")
let lintStatus = runSwiftLintIfAvailable(root: root, fix: fix)
if lintStatus != 0 {
    writeStderr("\nLint errors above. Warnings do not block; errors do.")
    exit(lintStatus)
}

let searchProblems = try checkSettingsSearch(root: root)
if !searchProblems.isEmpty {
    writeStderr("\n✗ Settings search targets with nothing to land on:")
    for p in searchProblems { writeStderr("  \(p)") }
    writeStderr("  Mark the row with SettingsRowTitle, or make the entry a `group:` one.")
    exit(1)
}

let locProblems = try checkLocalizations(root: root)
if !locProblems.isEmpty {
    writeStderr("\n✗ \(locProblems.count) localization problem(s):")
    for p in locProblems.prefix(200) { writeStderr("  \(p)") }
    if locProblems.count > 200 { writeStderr("  … and \(locProblems.count - 200) more") }
    exit(1)
}

print("✓ check-clean")
