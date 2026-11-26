#!/usr/bin/env swift
// The test suite: each harness compiles the shipped sources it guards.
// Usage: swift Scripts/run-tests.swift [HarnessName | --index]

import Darwin
import Foundation

struct Harness {
    let name: String
    let sources: [String]
    let optimize: Bool
    let slow: Bool
    let indexOnly: Bool

    init(
        _ name: String,
        _ sources: [String],
        optimize: Bool = false,
        slow: Bool = false,
        indexOnly: Bool = false
    ) {
        self.name = name
        self.sources = sources
        self.optimize = optimize
        self.slow = slow
        self.indexOnly = indexOnly
    }
}

let lDir = "Tinycast/Features/Launcher/Model"
let fsDir = "Tinycast/Features/FileSearch"
let fileIndexSources = [
    "\(fsDir)/Service/FileIndex.swift",
    "\(fsDir)/Service/FileIndexSnapshot.swift",
    "\(fsDir)/Service/FileIndexCrawler.swift",
]
let syncSources = [
    "Tinycast/Features/CloudSync/Model/*.swift",
    "Tinycast/Features/CloudSync/Service/SyncSource.swift",
    "Tinycast/Features/CloudSync/Service/RecordSyncSource.swift",
    "Tinycast/Features/Settings/Model/SettingsFileKey.swift",
    "Tinycast/DesignSystem/IconTint.swift",
]
let quicklinkDestination = "Tinycast/Features/Quicklinks/Model/QuicklinkDestination.swift"

let harnesses: [Harness] = [
    Harness("FuzzTests", [
        "\(lDir)/SearchRelevance.swift", "\(lDir)/ScriptRomanization.swift",
        "\(lDir)/LauncherMatch.swift", "\(lDir)/EntryNaming.swift", "\(lDir)/LauncherOrder.swift",
        "\(lDir)/LauncherRankingStore.swift", "\(lDir)/LauncherSuggestions.swift",
    ], optimize: true, slow: true),
    Harness("FileSearchTests", ["\(fsDir)/Model/*.swift"]),
    Harness("FileIndexTests", ["\(fsDir)/Model/*.swift"] + fileIndexSources),
    Harness("FileSearchSessionTests", ["\(fsDir)/Model/*.swift", "\(fsDir)/Service/FileSearchSession.swift"] + fileIndexSources),
    Harness("MenuSearchTests", [
        "\(lDir)/SearchRelevance.swift",
        "Tinycast/Features/MenuSearch/Model/*.swift",
        "Tinycast/Features/MenuSearch/Service/*.swift",
    ]),
    Harness("WindowSwitchTests", [
        "\(lDir)/SearchRelevance.swift",
        "Tinycast/Features/WindowSwitcher/Model/*.swift",
    ]),
    Harness("FileSearchPerformanceTests", ["\(fsDir)/Model/*.swift"] + fileIndexSources, indexOnly: true),
    Harness("RankingTests", [
        "\(lDir)/SearchRelevance.swift", "\(lDir)/ScriptRomanization.swift",
        "\(lDir)/LauncherMatch.swift", "\(lDir)/LauncherRankingStore.swift",
    ]),
    Harness("ScopesTests", ["\(lDir)/SearchScopes.swift"]),
    Harness("AppNameTests", [
        "Tinycast/Platform/AppDisplayName.swift",
        "Tinycast/Platform/BundleLocalization.swift",
        "\(lDir)/SearchRelevance.swift",
    ]),
    Harness("FavoritesTests", ["\(lDir)/FavoriteSlots.swift"]),
    Harness("AppInstallationTests", [
        "\(lDir)/SearchRelevance.swift", "\(lDir)/ScriptRomanization.swift",
        "\(lDir)/LauncherMatch.swift", "\(lDir)/EntryNaming.swift", "\(lDir)/LauncherOrder.swift",
        "\(lDir)/LauncherRankingStore.swift", "\(lDir)/LauncherSuggestions.swift", "\(lDir)/SearchScopes.swift",
        "Tinycast/Features/Launcher/Service/AppIndex.swift",
        "Tinycast/Features/Launcher/Service/AppLauncher.swift",
        "Tinycast/Features/Launcher/Service/RunningAppsMonitor.swift",
        "Tinycast/Features/Launcher/Service/FavoritesStore.swift",
        "\(fsDir)/Model/FileSearchResult.swift",
        "Tinycast/Features/Launcher/Service/AliasStore.swift",
        "Tinycast/Features/Launcher/Service/VisibilityStore.swift",
        "Tinycast/Features/Launcher/Service/BundleNameCache.swift",
        "Tinycast/Platform/AppDisplayName.swift", "Tinycast/Platform/BundleLocalization.swift",
        "Tinycast/Platform/SystemLanguages.swift",
        "Tinycast/Platform/Images/FileIconStamp.swift", "Tinycast/Platform/Memo.swift",
        "Tinycast/Platform/Signposts.swift", "Tinycast/Platform/NotificationToken.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("LauncherFileTests", [
        "\(lDir)/LauncherFileFormat.swift",
        "Tinycast/Features/Settings/Model/SettingsFileJSON.swift",
    ]),
    Harness("LauncherSettingsFileTests", [
        "\(lDir)/LauncherFileFormat.swift", "\(lDir)/CommandID.swift", "\(lDir)/CommandCatalog.swift",
        "Tinycast/Features/Launcher/Service/LauncherSettingsFile.swift",
        "Tinycast/Features/Launcher/Service/AliasStore.swift",
        "Tinycast/Features/Launcher/Service/VisibilityStore.swift",
        "Tinycast/Features/Settings/SettingsTab.swift",
        "Tinycast/Features/Settings/Model/*.swift",
        "Tinycast/Features/HotKeys/Service/HotKeySettingsFile.swift",
        "Tinycast/Features/HotKeys/Service/KeyShortcut.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyBinding.swift",
        "Tinycast/Features/HotKeys/Model/HotKeySpelling.swift",
        "Tinycast/Features/HotKeys/Model/DoubleTapModifier.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKey.swift",
        "Tinycast/Features/HotKeys/Model/HyperKey.swift",
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Platform/ASCIIKeyboardLayout.swift",
        "Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/SystemActions/Model/SystemAction.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/Snippets/Model/Snippet.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("AppleShortcutTests", ["Tinycast/Features/AppleShortcuts/Model/*.swift"]),
    Harness("CalcTests", ["Tinycast/Features/Calculator/Model/*.swift"]),
    Harness("CalcPerformanceTests", ["Tinycast/Features/Calculator/Model/*.swift"], indexOnly: true),
    Harness("CalendarTests", [
        "Tinycast/Features/Calendar/Model/*.swift",
        "Tinycast/Features/Calendar/UI/EventEditorSession.swift",
    ]),
    Harness("ClipboardTests", [
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
    ]),
    Harness("ClipboardSyncTests", [
        "Tinycast/Features/Clipboard/Service/ClipboardSyncSource.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
    ] + syncSources),
    Harness("ClipboardCoordinatorTests", [
        "Tinycast/Features/Clipboard/UI/ClipboardCoordinator.swift",
        "Tinycast/Features/Clipboard/Model/*.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Palette/PaletteState.swift", "Tinycast/Palette/PaletteMode.swift",
        "Tinycast/Palette/HoverArming.swift",
        "Tinycast/Features/Emoji/Model/EmojiCatalog.swift",
        "Tinycast/Features/FileSearch/Model/FileSearchFilter.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
    ]),
    Harness("ClipboardThumbnailTests", [
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
        "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Platform/Images/ImageThumbnail.swift",
        "Tinycast/Platform/Images/ThumbnailCache.swift",
    ]),
    Harness("ClipboardSearchTests", [
        "Tinycast/Features/Clipboard/Model/*.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        quicklinkDestination,
    ]),
    Harness("PasteSequenceTests", [
        "Tinycast/Features/Clipboard/Model/*.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        quicklinkDestination,
    ]),
    Harness("ClipboardTextTests", [
        "Tinycast/Features/Clipboard/Model/*.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        quicklinkDestination,
        "Tinycast/Features/Clipboard/Service/ClipboardTextExtractor.swift",
        "Tinycast/Features/Clipboard/Service/ClipboardTextIndexer.swift",
        "Tinycast/Features/Clipboard/Service/ClipboardTextWorker.swift",
        "Tinycast/Platform/ProcessExit.swift",
    ]),
    Harness("PasteboardTests", [
        "Tinycast/Platform/PasteboardFiles.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
        "Tinycast/Features/Clipboard/Service/ClipboardManager.swift",
        "Tinycast/Features/Clipboard/Service/Paster.swift",
    ]),
    Harness("ClipboardFilePerformanceTests", [
        "Tinycast/Platform/PasteboardFiles.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
        "Tinycast/Features/Clipboard/Service/ClipboardManager.swift",
    ], indexOnly: true),
    Harness("ClipboardThumbnailPerformanceTests", [
        "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Platform/Images/ImageThumbnail.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Platform/Images/ThumbnailCache.swift",
    ], indexOnly: true),
    Harness("EmojiTests", [
        "Tinycast/Features/Emoji/Model/EmojiCatalog.swift",
        "Tinycast/Features/Emoji/Model/EmojiGridGeometry.swift",
        "Tinycast/Features/Emoji/Model/EmojiData.generated.swift",
    ]),
    Harness("EmojiSearchTests", [
        "Tinycast/Features/Emoji/Model/EmojiCatalog.swift",
        "Tinycast/Features/Emoji/Model/EmojiData.generated.swift",
        "Tinycast/Features/Emoji/Service/EmojiIndex.swift",
        "Tinycast/Features/Emoji/Service/FrequentEmojiStore.swift",
        "Tinycast/Features/Emoji/Service/PinnedEmojiStore.swift",
        "\(lDir)/SearchRelevance.swift",
        "Tinycast/Platform/AppPaths.swift", "Tinycast/Platform/Memo.swift",
    ]),
    Harness("EmojiSearchPerformanceTests", [
        "Tinycast/Features/Emoji/Model/EmojiCatalog.swift",
        "Tinycast/Features/Emoji/Model/EmojiData.generated.swift",
        "Tinycast/Features/Emoji/Service/EmojiIndex.swift",
        "Tinycast/Features/Emoji/Service/FrequentEmojiStore.swift",
        "\(lDir)/SearchRelevance.swift",
        "Tinycast/Platform/AppPaths.swift", "Tinycast/Platform/Memo.swift",
    ], indexOnly: true),
    Harness("PaletteSelectionTests", [
        "Tinycast/Features/PaletteRowIndex.swift",
        "Tinycast/Features/Emoji/Model/EmojiGridGeometry.swift",
    ]),
    Harness("AppearanceTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Features/Settings/AppAppearance.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("LanguageTests", ["Tinycast/Features/Settings/AppLanguage.swift"]),
    Harness("LocalizedResourceTests", ["Tinycast/Platform/LocalizedResource.swift"]),
    Harness("RelaunchTests", ["Tinycast/App/AppDelegate.swift", "Tinycast/Platform/RelaunchRunner.swift"]),
    Harness("InterfaceSizeTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Features/Settings/InterfaceSize.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("PalettePlacementTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Features/Settings/InterfaceSize.swift",
        "Tinycast/Palette/PalettePlacement.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("PaletteMenuClickTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/Platform/WindowLevel.swift",
        "Tinycast/Platform/NotificationToken.swift",
        "Tinycast/DesignSystem/Interaction/KeyboardFocus.swift",
        "Tinycast/DesignSystem/Interaction/Motion.swift",
        "Tinycast/DesignSystem/Interaction/AnimatedPanel.swift",
        "Tinycast/Palette/PalettePanel.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("FormInputTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/DesignSystem/FormTextInput.swift",
        "Tinycast/DesignSystem/FormTextArea.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("ScrollRevealTests", ["Tinycast/DesignSystem/Scrolling/SelectionReveal.swift"]),
    Harness("RedactionTests", ["Tinycast/DesignSystem/RedactedPlaceholder.swift"]),
    Harness("KeyboardFocusTests", ["Tinycast/DesignSystem/Interaction/KeyboardFocus.swift"]),
    Harness("CommandEscapeTapTests", ["Tinycast/Palette/CommandEscapeTap.swift"]),
    Harness("PaletteEscapeTests", [
        "Tinycast/Palette/PaletteMode.swift",
        "Tinycast/Palette/PaletteEscapeAction.swift",
        "Tinycast/Palette/CommandEscapeTap.swift",
        "Tinycast/Features/Settings/EscapeKeyBehavior.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
    ]),
    Harness("PaletteNavigationTests", [
        "Tinycast/Palette/PaletteState.swift",
        "Tinycast/Palette/PaletteMode.swift",
        "Tinycast/Palette/HoverArming.swift",
        "Tinycast/Features/Emoji/Model/EmojiCatalog.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/FileSearch/Model/FileSearchFilter.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
    ]),
    Harness("PaletteFilterTests", [
        "Tinycast/Palette/PaletteMode.swift",
        "Tinycast/Palette/PaletteFilterAction.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
    ]),
    Harness("ActionMenuSearchTests", [
        "Tinycast/Palette/ActionMenuSearchQuery.swift",
        "\(lDir)/SearchRelevance.swift",
    ]),
    Harness("PaletteShortcutTests", ["Tinycast/Palette/PaletteShortcut.swift"]),
    Harness("ASCIILayoutTests", ["Tinycast/Platform/ASCIIKeyboardLayout.swift"]),
    Harness("PaletteTabTests", [
        "Tinycast/Palette/PaletteMode.swift",
        "Tinycast/Palette/PaletteTabAction.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
    ]),
    Harness("CompactBarTests", [
        "Tinycast/Features/Launcher/Model/CompactBarSelection.swift",
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/Settings/Model/*.swift",
        "\(lDir)/CommandID.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction.swift",
        "Tinycast/Features/QuickActions/Model/QuickAction.swift",
        "Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift",
        "Tinycast/Features/QuickActions/Model/CustomQuickAction.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/SystemActions/Model/SystemAction.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/Snippets/Model/Snippet.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("FallbackTests", [
        "\(lDir)/Fallback.swift",
        "\(lDir)/CommandID.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction.swift",
        "Tinycast/Features/QuickActions/Model/QuickAction.swift",
        "Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift",
        "Tinycast/Features/QuickActions/Model/CustomQuickAction.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/SystemActions/Model/SystemAction.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/Snippets/Model/Snippet.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("DictionaryTests", [
        "Tinycast/Features/Dictionary/Model/DictionaryEntry.swift",
        "Tinycast/Features/Dictionary/Model/DictionaryMarkup.swift",
    ]),
    Harness("DictationTests", [
        "Tinycast/Features/Dictation/Model/DictationModel.swift",
        "Tinycast/Features/Dictation/Model/DictationIdleRelease.swift",
        "Tinycast/Features/Dictation/Model/DictationLanguage.swift",
        "Tinycast/Features/Dictation/Model/DictationTextFormatter.swift",
    ]),
    Harness("DictationCueTests", ["Tinycast/Features/Dictation/Service/DictationCueRunner.swift"]),
    Harness("DictationFieldTests", [
        "Tinycast/Features/Dictation/Model/DictationModel.swift",
        "Tinycast/Features/Dictation/Model/DictationAudioChunks.swift",
        "Tinycast/Features/Dictation/Model/DictationMode.swift",
        "Tinycast/Features/Dictation/Model/DictationDestination.swift",
        "Tinycast/Features/Dictation/Model/DictationTextFormatter.swift",
        "Tinycast/Features/Dictation/Service/DictationCoordinator.swift",
        "Tinycast/Features/Dictation/Service/DictationInsertionContext.swift",
        "Tinycast/Features/AI/UI/ChatComposerTextView.swift",
        "Tinycast/Features/TextInjection/Service/*.swift",
        "Tinycast/Features/Snippets/Model/*.swift",
        "Tinycast/Platform/AccessibilityText.swift",
        "Tinycast/Platform/PasteboardFiles.swift",
        "Tinycast/Platform/Appearance.swift", "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("DictationVolumeTests", [
        "Tinycast/Features/Dictation/Model/DictationVolumeSnapshot.swift",
        "Tinycast/Features/Dictation/Service/DictationAudioDucker.swift",
        "Tinycast/Platform/AppPaths.swift",
    ]),
    Harness("DictationPerformanceTests", [
        "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Features/Dictation/Model/DictationModel.swift",
        "Tinycast/Features/Dictation/Service/DictationWire.swift",
        "Tinycast/Platform/PipeFraming.swift",
    ], optimize: true, indexOnly: true),
    Harness("DictationInferenceTests", [
        "Tinycast/Features/Dictation/Model/DictationAudioChunks.swift",
        "Tinycast/Features/Dictation/Service/DictationSpectrum.swift",
        "Tinycast/Features/Dictation/Helper/DictationTensor.swift",
        "Tinycast/Features/Dictation/Helper/DictationTokenizer.swift",
        "Tinycast/Features/Dictation/Helper/DictationMel.swift",
    ]),
    Harness("PipeFramingTests", [
        "Tinycast/Platform/PipeFraming.swift", "Tinycast/Platform/ProcessLink.swift",
        "Tinycast/Platform/ProcessExit.swift", "Tinycast/App/ProcessRole.swift",
        "Tinycast/App/ProcessLink+Role.swift", "Tinycast/Platform/LaunchedExecutable.swift",
    ]),
    Harness("SharedStateMirrorTests", [
        "Tinycast/App/SharedStateMirror.swift", "Tinycast/App/ProcessRole.swift",
        "Tinycast/Platform/NotificationToken.swift",
    ]),
    Harness("DictationWorkerTests", [
        "Tinycast/Features/Dictation/Model/DictationModel.swift",
        "Tinycast/Features/Dictation/Model/DictationIdleRelease.swift",
        "Tinycast/Features/Dictation/Service/DictationWire.swift",
        "Tinycast/Platform/PipeFraming.swift",
        "Tinycast/Features/Dictation/Service/DictationWorker.swift",
        "Tinycast/Features/Dictation/Service/DictationModelStore.swift",
        "Tinycast/Features/Dictation/Service/DictationModelDownloader.swift",
        "Tinycast/Platform/ProcessExit.swift", "Tinycast/Platform/AppPaths.swift",
    ]),
    Harness("HotKeyTests", [
        "Tinycast/Features/HotKeys/Model/DoubleTapModifier.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKey.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKeyDetector.swift",
        "Tinycast/Features/HotKeys/Model/DoubleTapDetector.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyBinding.swift",
        "Tinycast/Features/HotKeys/Model/HotKeySpelling.swift",
        "Tinycast/Features/HotKeys/Model/HyperKey.swift",
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Platform/ASCIIKeyboardLayout.swift",
        "Tinycast/Features/HotKeys/Service/KeyShortcut.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction.swift",
        "Tinycast/Features/QuickActions/Model/QuickAction.swift",
        "Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift",
        "Tinycast/Features/QuickActions/Model/CustomQuickAction.swift",
        "\(lDir)/CommandID.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/SystemActions/Model/SystemAction.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/Snippets/Model/Snippet.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("CalloutTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Features/HotKeys/UI/CalloutPlacement.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("IconCacheTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/Platform/Images/IconCache.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("EntryIconTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/Platform/Images/IconCache.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/Platform/Images/FileIconStamp.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("SystemActionTests", [
        "Tinycast/Features/SystemActions/Model/SystemAction.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("MicrophoneMuteTests", [
        "Tinycast/Features/SystemActions/Service/SystemActionFailure.swift",
        "Tinycast/Features/SystemActions/Service/SystemActionRunner+Microphone.swift",
    ]),
    Harness("VolumeTests", ["Tinycast/Features/SystemActions/Model/VolumeLevel.swift"]),
    Harness("WindowCommandTests", [
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCycle.swift",
        "Tinycast/Features/WindowManagement/Model/WindowPlacementEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowActionMemory.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("WindowPresetTests", [
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowShortcutPreset.swift",
        "Tinycast/Features/HotKeys/Model/DoubleTapModifier.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKey.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyBinding.swift",
        "Tinycast/Features/HotKeys/Model/HyperKey.swift",
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Platform/ASCIIKeyboardLayout.swift",
        "Tinycast/Features/HotKeys/Service/KeyShortcut.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("SpaceGestureTests", [
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/SpaceGesture.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("WindowLayoutTests", [
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCycle.swift",
        "Tinycast/Features/WindowManagement/Model/WindowPlacementEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutAnchor.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutDisplay.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayout.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutGeometry.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutPlan.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutStore.swift",
        "Tinycast/Features/WindowManagement/Model/CustomWindowSize.swift",
        "Tinycast/Features/WindowManagement/Model/CustomWindowSizeStore.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("DeepLinkTests", [
        "Tinycast/Features/DeepLinks/Model/DeepLink.swift",
        "Tinycast/Features/DeepLinks/Model/DeepLinkInput.swift",
        "Tinycast/Features/DeepLinks/Model/DeepLinkConsentPolicy.swift",
        "Tinycast/Features/DeepLinks/Model/DeepLinkSource.swift",
        "Tinycast/Features/DeepLinks/Model/CustomWindowSize+DeepLink.swift",
        "Tinycast/Features/Settings/SettingsTab.swift",
        "\(lDir)/CommandID.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction+EntryID.swift",
        "Tinycast/Features/QuickActions/Model/QuickAction.swift",
        "Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift",
        "Tinycast/Features/QuickActions/Model/CustomQuickAction.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/SystemActions/Model/SystemAction.swift",
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
        "Tinycast/Features/AppleShortcuts/Model/AppleShortcut.swift",
        "Tinycast/Features/Snippets/Model/Snippet.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCycle.swift",
        "Tinycast/Features/WindowManagement/Model/WindowPlacementEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutAnchor.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutDisplay.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayout.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutGeometry.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutKind.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutEngine.swift",
        "Tinycast/Features/WindowManagement/Model/RoomGrid.swift",
        "Tinycast/Features/WindowManagement/Model/RoomWindow.swift",
        "Tinycast/Features/WindowManagement/Model/Room.swift",
        "Tinycast/Features/WindowManagement/Model/CustomWindowSize.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("WindowRoomTests", [
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCycle.swift",
        "Tinycast/Features/WindowManagement/Model/WindowPlacementEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutAnchor.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutDisplay.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayout.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutGeometry.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutPlan.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutKind.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutEngine.swift",
        "Tinycast/Features/WindowManagement/Model/RoomGrid.swift",
        "Tinycast/Features/WindowManagement/Model/RoomWindow.swift",
        "Tinycast/Features/WindowManagement/Model/Room.swift",
        "Tinycast/Features/WindowManagement/Model/RoomWindowMatcher.swift",
        "Tinycast/Features/WindowManagement/Model/RoomParking.swift",
        "Tinycast/Features/WindowManagement/Model/RoomPlan.swift",
        "Tinycast/Features/WindowManagement/Model/RoomArrangement.swift",
        "Tinycast/Features/WindowManagement/Model/RoomStore.swift",
        "Tinycast/Features/WindowManagement/Model/RoomMinimumSizeStore.swift",
        "Tinycast/Features/WindowManagement/Model/RoomParkingLedger.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("WindowFileTests", [
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCycle.swift",
        "Tinycast/Features/WindowManagement/Model/WindowPlacementEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutAnchor.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutDisplay.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayout.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutGeometry.swift",
        "Tinycast/Features/WindowManagement/Model/CustomWindowSize.swift",
        "Tinycast/Features/WindowManagement/Model/Room.swift",
        "Tinycast/Features/WindowManagement/Model/RoomWindow.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutKind.swift",
        "Tinycast/Features/WindowManagement/Model/RoomGrid.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowManagementFileFormat.swift",
        "Tinycast/Features/Settings/Model/SettingsFileJSON.swift",
        "Tinycast/Features/Settings/Model/SettingsFileIdentity.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("CustomCommandTests", [
        "Tinycast/Platform/PseudoTerminal.swift",
        "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
        "Tinycast/Features/CustomCommands/Model/RaycastScriptImport.swift",
        "Tinycast/Features/CustomCommands/UI/CustomCommandEditorSession.swift",
        "Tinycast/Features/CustomCommands/Service/ShellCommandRunner.swift",
    ]),
    Harness("CustomCommandListTests", [
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
        "Tinycast/Features/CustomCommands/UI/CustomCommandListScreen.swift",
    ]),
    Harness("UninstallCoordinatorTests", [
        "Tinycast/Features/Uninstall/Model/*.swift",
        "Tinycast/Features/Uninstall/UI/UninstallCoordinator.swift",
    ]),
    Harness("UninstallTests", [
        "Tinycast/Features/Uninstall/Model/UninstallTarget.swift",
        "Tinycast/Features/Uninstall/Model/UninstallSearchRoot.swift",
        "Tinycast/Features/Uninstall/Model/UninstallRules.swift",
        "Tinycast/Features/Uninstall/Model/UninstallProtection.swift",
        "Tinycast/Features/Uninstall/Model/UninstallPlan.swift",
    ]),
    Harness("QuicklinkTests", [
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/Quicklinks/Model/QuicklinkStore.swift",
        "Tinycast/Features/Quicklinks/Model/QuicklinkArchive.swift",
        "Tinycast/Features/Quicklinks/Model/RaycastQuicklinkImport.swift",
        "Tinycast/Features/Quicklinks/UI/QuicklinkEditorSession.swift",
    ]),
    Harness("QuicklinkCoordinatorTests", [
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/Quicklinks/Model/QuicklinkStore.swift",
        "Tinycast/Features/Quicklinks/Model/QuicklinkArchive.swift",
        "Tinycast/Features/Quicklinks/UI/QuicklinkCoordinator.swift",
        "Tinycast/Features/Quicklinks/UI/QuicklinkEditorSession.swift",
        "Tinycast/Features/Quicklinks/UI/QuicklinkArgumentsAccessory.swift",
        "Tinycast/Features/Snippets/Model/Snippet.swift",
        "Tinycast/Features/Snippets/Model/SnippetTemplateEngine.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("SnippetsTests", [
        "Tinycast/Platform/NotificationToken.swift",
        "Tinycast/Platform/HealthTicker.swift",
        "Tinycast/Platform/AccessibilityText.swift",
        "Tinycast/Features/Snippets/Model/*.swift",
        "Tinycast/Features/Snippets/Service/*.swift",
    ] + syncSources + [
        "Tinycast/Features/Snippets/UI/SnippetEditorSession.swift",
        "Tinycast/Features/Snippets/UI/SnippetArgumentsState.swift",
        "Tinycast/Features/TextInjection/Service/*.swift",
    ], slow: true),
    Harness("NotesTests", [
        "Tinycast/Platform/Signposts.swift",
        "\(lDir)/SearchRelevance.swift",
        "Tinycast/Features/Notes/Model/*.swift",
        "Tinycast/Features/Notes/Service/*.swift",
    ] + syncSources),
    Harness("NotesEditorTests", [
        "Tinycast/Platform/Signposts.swift",
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Platform/NotificationToken.swift",
        "Tinycast/Features/TextInjection/Service/InjectableTextView.swift",
        "Tinycast/Features/Notes/Model/NoteDocument.swift",
        "Tinycast/Features/Notes/Model/NoteTitle.swift",
        "Tinycast/Features/Notes/Model/NoteMarkdown.swift",
        "Tinycast/Features/Notes/Model/NoteMarkdownParser.swift",
        "Tinycast/Features/Notes/Model/NoteInlineScanner.swift",
        "Tinycast/Features/Notes/Model/NoteEditPlan.swift",
        "Tinycast/Features/Notes/Model/NoteEditAction.swift",
        "Tinycast/Features/Notes/Model/NoteFormatting.swift",
        "Tinycast/Features/Notes/Model/NoteMarkdownEditing.swift",
        "Tinycast/Features/Notes/Model/NoteRevealPolicy.swift",
        "Tinycast/Features/Notes/UI/NoteMarkdownTypography.swift",
        "Tinycast/Features/Notes/UI/NoteBlockDecoration.swift",
        "Tinycast/Features/Notes/UI/NoteMarkdownStyler.swift",
        "Tinycast/Features/Notes/UI/NoteMarkdownRenderer.swift",
        "Tinycast/Features/Notes/UI/NoteCheckboxGeometry.swift",
        "Tinycast/Features/Notes/UI/NoteBlockLayoutFragment.swift",
        "Tinycast/Features/Notes/UI/NoteLayoutFragmentProvider.swift",
        "Tinycast/Features/Notes/UI/NoteTextViewEditing.swift",
        "Tinycast/Features/Notes/UI/NoteTextView.swift",
        "Tinycast/Features/Notes/UI/NoteEditorView.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("NotesEditorPerformanceTests", [
        "Tinycast/Platform/Signposts.swift",
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Platform/NotificationToken.swift",
        "Tinycast/Features/TextInjection/Service/InjectableTextView.swift",
        "Tinycast/Features/Notes/Model/NoteDocument.swift",
        "Tinycast/Features/Notes/Model/NoteTitle.swift",
        "Tinycast/Features/Notes/Model/NoteMarkdown.swift",
        "Tinycast/Features/Notes/Model/NoteMarkdownParser.swift",
        "Tinycast/Features/Notes/Model/NoteInlineScanner.swift",
        "Tinycast/Features/Notes/Model/NoteEditPlan.swift",
        "Tinycast/Features/Notes/Model/NoteEditAction.swift",
        "Tinycast/Features/Notes/Model/NoteFormatting.swift",
        "Tinycast/Features/Notes/Model/NoteMarkdownEditing.swift",
        "Tinycast/Features/Notes/Model/NoteRevealPolicy.swift",
        "Tinycast/Features/Notes/UI/NoteMarkdownTypography.swift",
        "Tinycast/Features/Notes/UI/NoteBlockDecoration.swift",
        "Tinycast/Features/Notes/UI/NoteMarkdownStyler.swift",
        "Tinycast/Features/Notes/UI/NoteMarkdownRenderer.swift",
        "Tinycast/Features/Notes/UI/NoteCheckboxGeometry.swift",
        "Tinycast/Features/Notes/UI/NoteBlockLayoutFragment.swift",
        "Tinycast/Features/Notes/UI/NoteLayoutFragmentProvider.swift",
        "Tinycast/Features/Notes/UI/NoteTextViewEditing.swift",
        "Tinycast/Features/Notes/UI/NoteTextView.swift",
        "Tinycast/Features/Notes/UI/NoteEditorView.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ], optimize: true, indexOnly: true),
    Harness("RaycastTests", [
        "Tinycast/Features/Backup/Model/RaycastImportError.swift",
        "Tinycast/Features/Backup/Service/RaycastDecoder.swift",
        "Tinycast/Features/Backup/Service/Scrypt.swift",
        "Tinycast/Platform/Compression/Zlib.swift",
        "Tinycast/Features/Clipboard/Model/RaycastClipboardImport.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardStore.swift",
        "Tinycast/Platform/Images/ImageDerivative.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFilter.swift",
        "Tinycast/Features/Clipboard/Model/ClipboardFileKind.swift",
        "Tinycast/Features/Clipboard/Model/ColorValue.swift",
        "Tinycast/Features/Clipboard/Model/ColorFormat.swift",
        "Tinycast/Features/Clipboard/Model/ColorSpaces.swift",
    ], optimize: true, slow: true),
    Harness("CloudSyncTests", [
        "Tinycast/Features/CloudSync/Model/*.swift",
        "Tinycast/Features/Settings/Model/SettingsFileKey.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("SettingsBackupTests", [
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/Backup/Model/SettingsBackupCoverage.swift",
    ]),
    Harness("HyperKeyEngineTests", [
        "Tinycast/Features/HotKeys/Model/HyperKeyEngine.swift",
        "Tinycast/Features/HotKeys/Model/PhysicalHyperKeyPress.swift",
        "Tinycast/Features/HotKeys/Model/HyperKey.swift",
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKey.swift",
        "Tinycast/Features/HotKeys/Model/DoubleTapModifier.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyBinding.swift",
        "Tinycast/Features/HotKeys/Service/KeyShortcut.swift",
        "Tinycast/Platform/ASCIIKeyboardLayout.swift",
    ]),
    Harness("HyperKeyTests", [
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Features/HotKeys/Model/HyperKeyConflictPolicy.swift",
        "Tinycast/Features/HotKeys/Service/KeyboardRemapper.swift",
        "Tinycast/Features/HotKeys/Service/RemapInstanceLock.swift",
        "Tests/HyperKeyFixtures.swift",
    ]),
    Harness("HotKeyDispatchTests", [
        "Tinycast/Features/HotKeys/Model/DoubleTapModifier.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKey.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyBinding.swift",
        "Tinycast/Features/HotKeys/Model/HyperKey.swift",
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyAction.swift",
        "Tinycast/Features/HotKeys/Service/KeyShortcut.swift",
        "Tinycast/Features/HotKeys/Service/HotKeyManager.swift",
        "Tinycast/Platform/ASCIIKeyboardLayout.swift",
        "Tests/HotKeyDispatchFixtures.swift",
    ]),
    Harness("SettingsFileTests", [
        "Tinycast/Features/Settings/Model/*.swift",
        "Tinycast/Features/Settings/Service/SettingsFileMonitor.swift",
        "Tinycast/Features/Settings/Service/SettingsFileRepository.swift",
        "Tinycast/Platform/AppPaths.swift",
    ]),
    Harness("BackupArchiveTests", [
        "Tinycast/Platform/AppPaths.swift",
        "Tinycast/Features/Backup/Model/BackupArchive.swift",
        "Tinycast/Features/Backup/Model/BackupBundle.swift",
        "Tinycast/Features/Backup/Model/BackupCategory.swift",
        "Tinycast/DesignSystem/IconTint.swift",
        "Tinycast/Features/Backup/Model/BackupClipboardItem.swift",
        "Tinycast/Features/Backup/Model/BackupManifest.swift",
        "Tinycast/Features/Backup/Service/BackupStaging.swift",
        "Tinycast/Features/Backup/Model/SettingsBackup.swift",
        "Tinycast/Features/CustomCommands/Model/CustomCommand.swift",
        "Tinycast/Features/Quicklinks/Model/Quicklink.swift",
        quicklinkDestination,
        "Tinycast/Features/WindowManagement/Model/WindowCommand.swift",
        "Tinycast/Features/WindowManagement/Model/WindowCycle.swift",
        "Tinycast/Features/WindowManagement/Model/WindowPlacementEngine.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutAnchor.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutDisplay.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayout.swift",
        "Tinycast/Features/WindowManagement/Model/WindowLayoutGeometry.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutKind.swift",
        "Tinycast/Features/WindowManagement/Model/RoomLayoutEngine.swift",
        "Tinycast/Features/WindowManagement/Model/RoomGrid.swift",
        "Tinycast/Features/WindowManagement/Model/RoomWindow.swift",
        "Tinycast/Features/WindowManagement/Model/Room.swift",
        "Tinycast/Features/WindowManagement/Model/CustomWindowSize.swift",
        "Tinycast/Features/HotKeys/Model/HotKeyBinding.swift",
        "Tinycast/Features/HotKeys/Model/ModifierKey.swift",
        "Tinycast/Features/HotKeys/Model/HyperKey.swift",
        "Tinycast/Features/HotKeys/Model/HIDKeyMapping.swift",
        "Tinycast/Features/HotKeys/Model/DoubleTapModifier.swift",
        "Tinycast/Features/HotKeys/Service/KeyShortcut.swift",
        "Tinycast/Platform/ASCIIKeyboardLayout.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("SettingsHistoryTests", [
        "Tinycast/Features/Settings/SettingsTab.swift",
        "Tinycast/Features/Settings/SettingsHistory.swift",
        "Tinycast/Features/Settings/SettingsAnchor.swift",
        "Tinycast/Features/Settings/SettingsNavigationState.swift",
        "Tinycast/Features/Settings/SettingsSearchCatalog.swift",
        "\(lDir)/SearchRelevance.swift",
        "Tinycast/Platform/LocalizedResource.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("UpdatesTests", [
        "Tinycast/Features/Updates/Model/*.swift",
        "Tinycast/Features/Updates/Service/BundleSignature.swift",
        "Tinycast/Features/Updates/Service/UpdateSignature.swift",
    ]),
    Harness("UpdateCheckTests", [
        "Tinycast/Features/Updates/Model/*.swift",
        "Tinycast/Features/Updates/Service/UpdateCheckStore.swift",
        "Tinycast/Platform/AppPaths.swift",
    ]),
    Harness("SupportTests", ["Tinycast/Features/Support/Model/*.swift"]),
    Harness("AIProviderTests", [
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/*.swift",
        "Tinycast/Features/AI/Settings/AISettingsStore.swift",
        "Tinycast/Features/AI/Service/CodexAppServerClient.swift",
        "Tinycast/Features/AI/Service/InstalledAIProbe.swift",
        "Tinycast/Platform/ExecutableLocator.swift", "Tinycast/Platform/ProcessExit.swift",
    ]),
    Harness("PlanUsageTests", [
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/*.swift",
        "Tinycast/Features/AI/Service/PlanUsageMonitor.swift",
        "Tinycast/Platform/NotificationToken.swift",
    ]),
    Harness("OpenCodeMCPTests", [
        "Tinycast/Features/AI/Model/*.swift",
        "Tinycast/Platform/ExecutableLocator.swift", "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Features/AI/Service/AIProvider.swift",
        "Tinycast/Features/AI/Service/AIToolLoopProvider.swift",
        "Tinycast/Features/AI/Service/InstalledCLIProvider.swift",
        "Tinycast/Features/AI/Service/OpenCodeMCPBridge.swift",
    ]),
    Harness("AIChatTests", [
        "Tinycast/Features/AI/Model/AIRequest.swift",
        "Tinycast/Features/AI/Model/AIConnection.swift",
        "Tinycast/Features/AI/Model/AIConversationOpenPolicy.swift",
        "Tinycast/Features/AI/Model/AppleIntelligence.swift",
        "Tinycast/Features/AI/Model/AIAttachmentPolicy.swift",
        "Tinycast/Features/AI/Model/AIRetention.swift",
        "Tinycast/Features/AI/Model/AITool.swift",
        "Tinycast/Features/AI/Model/JSONValue.swift",
        "Tinycast/Features/AI/Model/ChatMessage.swift",
        "Tinycast/Features/AI/Model/ChatSession.swift",
        "Tinycast/Features/AI/Model/ChatPreset.swift",
        "Tinycast/Features/AI/Model/ChatChoices.swift",
        "Tinycast/Features/AI/Model/ChatReferences.swift",
        "Tinycast/Features/AI/Model/ChatTitle.swift",
        "Tinycast/Features/AI/Model/ChatFind.swift",
        "Tinycast/Features/AI/Model/ChatCitations.swift",
        "Tinycast/Features/AI/Model/ChatToolScope.swift",
        "Tinycast/Features/AI/Model/MarkdownBlock.swift",
        "Tinycast/Features/AI/Model/MarkdownMath.swift",
        "Tinycast/Features/AI/Model/MathFormula.swift",
        "Tinycast/Features/AI/Model/MathNode.swift",
        "Tinycast/Features/AI/Model/MathSymbolCatalog.swift",
        "Tinycast/Features/AI/Service/AIProvider.swift",
        "Tinycast/Features/AI/Service/ChatHistoryStore.swift",
        "Tinycast/Features/AI/Model/ChatSyncPayload.swift",
        "Tinycast/Features/AI/Service/AIToolLoopProvider.swift",
        "Tinycast/Features/AI/UI/AIChatState.swift",
        "Tinycast/Features/AI/UI/AIChatSurfacesState.swift",
        "Tinycast/Features/AI/UI/ChatFindState.swift",
    ]),
    Harness("AIResponsesTests", [
        "Tinycast/Features/AI/Model/AIConnection.swift",
        "Tinycast/Features/AI/Model/AppleIntelligence.swift",
        "Tinycast/Features/AI/Model/AIModelDiscovery.swift",
        "Tinycast/Features/AI/Model/AIRequest.swift",
        "Tinycast/Features/AI/Model/AIRequestBody.swift",
        "Tinycast/Features/AI/Model/AIStreamDecoder.swift",
        "Tinycast/Features/AI/Model/AIResponsesDecoder.swift",
        "Tinycast/Features/AI/Model/ChatReferences.swift",
        "Tinycast/Features/AI/Model/AIThinkTagDecoder.swift",
        "Tinycast/Features/AI/Model/AIProviderFailure.swift",
        "Tinycast/Features/AI/Model/AITool.swift",
        "Tinycast/Features/AI/Model/JSONValue.swift",
        "Tinycast/Features/AI/Service/AIProvider.swift",
        "Tinycast/Features/AI/Service/AIToolLoopProvider.swift",
    ]),
    Harness("ChatMarkdownTests", [
        "Tinycast/Platform/Appearance.swift",
        "Tinycast/DesignSystem/Theme.swift",
        "Tinycast/Platform/Images/SystemIconTheme.swift",
        "Tinycast/DesignSystem/InterfaceMetrics.swift",
        "Tinycast/Features/Settings/InterfaceSize.swift",
        "Tinycast/Features/AI/Model/AIRequest.swift",
        "Tinycast/Features/AI/Model/AITool.swift",
        "Tinycast/Features/AI/Model/JSONValue.swift",
        "Tinycast/Features/AI/Model/ChatMessage.swift",
        "Tinycast/Features/AI/Model/ChatChoices.swift",
        "Tinycast/Features/AI/Model/ChatReferences.swift",
        "Tinycast/Features/AI/Model/ChatCitations.swift",
        "Tinycast/Features/AI/Model/ChatFind.swift",
        "Tinycast/Features/AI/Model/MarkdownBlock.swift",
        "Tinycast/Features/AI/Model/MarkdownMath.swift",
        "Tinycast/Features/AI/Model/MathFormula.swift",
        "Tinycast/Features/AI/Model/MathNode.swift",
        "Tinycast/Features/AI/Model/MathSymbolCatalog.swift",
        "Tinycast/Features/AI/Model/SyntaxGrammar.swift",
        "Tinycast/Features/AI/Model/SyntaxHighlighter.swift",
        "Tinycast/Features/AI/Model/SyntaxStructuredLexers.swift",
        "Tinycast/Features/AI/UI/ChatTextHighlight.swift",
        "Tinycast/Features/AI/UI/ChatMarkdownRenderer.swift",
        "Tinycast/Features/AI/UI/MathAttachmentCell.swift",
        "Tinycast/Features/AI/UI/MathBox.swift",
        "Tinycast/Features/AI/UI/MathFont.swift",
        "Tinycast/Features/AI/UI/MathLayoutEngine.swift",
        "Tinycast/DesignSystem/IconTint.swift",
    ]),
    Harness("SyntaxHighlightTests", [
        "Tinycast/Features/AI/Model/SyntaxGrammar.swift",
        "Tinycast/Features/AI/Model/SyntaxHighlighter.swift",
        "Tinycast/Features/AI/Model/SyntaxStructuredLexers.swift",
    ]),
    Harness("MCPTests", [
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/AIConnection.swift",
        "Tinycast/Features/AI/Model/AppleIntelligence.swift",
        "Tinycast/Features/AI/Model/AITool.swift",
        "Tinycast/Features/AI/Model/AIToolServer.swift",
        "Tinycast/Features/AI/Model/JSONValue.swift",
        "Tinycast/Features/MCP/Model/*.swift",
        "Tinycast/Features/MCP/Settings/MCPSettingsStore.swift",
    ]),
    Harness("TextDiffTests", ["Tinycast/Features/QuickActions/Model/TextDiffEngine.swift"], optimize: true),
    Harness("TextDiffPerformanceTests", ["Tinycast/Features/QuickActions/Model/TextDiffEngine.swift"], indexOnly: true),
    Harness("QuickActionTests", [
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/AIConnection.swift",
        "Tinycast/Features/AI/Model/AppleIntelligence.swift",
        "Tinycast/Features/AI/Model/ChatGPTSubscription.swift",
        "Tinycast/Features/AI/Model/InstalledAI.swift",
        "Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift",
        "Tinycast/Features/QuickActions/Model/CustomQuickAction.swift",
        "Tinycast/Features/QuickActions/Model/CustomQuickActionStore.swift",
        "Tinycast/Features/QuickActions/Model/QuickAction.swift",
        "Tinycast/Features/QuickActions/Model/QuickActionFailure.swift",
        "Tinycast/Features/QuickActions/Model/QuickActionPrompt.swift",
        "Tinycast/Features/QuickActions/Model/QuickActionSettings.swift",
        "Tinycast/Features/QuickActions/Settings/QuickActionSettingsStore.swift",
        "Tinycast/Platform/LocalizedResource.swift",
    ]),
    Harness("AppleIntelligenceTests", [
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/*.swift",
        "Tinycast/Features/AI/Service/AIProvider.swift",
        "Tinycast/Features/AI/Service/AppleIntelligenceProvider.swift",
    ]),
    Harness("MCPOAuthTests", [
        "Tinycast/Platform/ExecutableLocator.swift",
        "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Platform/KeychainSecretStore.swift",
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/AIConnection.swift",
        "Tinycast/Features/AI/Model/AppleIntelligence.swift",
        "Tinycast/Features/AI/Model/AITool.swift",
        "Tinycast/Features/AI/Model/AIToolServer.swift",
        "Tinycast/Features/AI/Model/AIStreamDecoder.swift",
        "Tinycast/Features/AI/Model/AIResponsesDecoder.swift",
        "Tinycast/Features/AI/Model/ChatReferences.swift",
        "Tinycast/Features/AI/Model/AIProviderFailure.swift",
        "Tinycast/Features/AI/Model/AIThinkTagDecoder.swift",
        "Tinycast/Features/AI/Model/AIRequest.swift",
        "Tinycast/Features/AI/Model/JSONValue.swift",
        "Tinycast/Features/MCP/Model/*.swift",
        "Tinycast/Features/MCP/Service/*.swift",
    ] + syncSources),
    Harness("MCPStdioTests", [
        "Tinycast/Platform/ExecutableLocator.swift",
        "Tinycast/Platform/ProcessExit.swift",
        "Tinycast/Platform/KeychainSecretStore.swift",
        "Tinycast/Features/Settings/AppSettingsKey.swift",
        "Tinycast/Features/AI/Model/AIConnection.swift",
        "Tinycast/Features/AI/Model/AppleIntelligence.swift",
        "Tinycast/Features/AI/Model/AITool.swift",
        "Tinycast/Features/AI/Model/AIToolServer.swift",
        "Tinycast/Features/AI/Model/AIStreamDecoder.swift",
        "Tinycast/Features/AI/Model/AIResponsesDecoder.swift",
        "Tinycast/Features/AI/Model/ChatReferences.swift",
        "Tinycast/Features/AI/Model/AIProviderFailure.swift",
        "Tinycast/Features/AI/Model/AIThinkTagDecoder.swift",
        "Tinycast/Features/AI/Model/AIRequest.swift",
        "Tinycast/Features/AI/Model/JSONValue.swift",
        "Tinycast/Features/MCP/Model/*.swift",
        "Tinycast/Features/MCP/Service/*.swift",
    ] + syncSources, slow: true),
]

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

func expandSources(_ patterns: [String], testFile: String) -> [String] {
    let fm = FileManager.default
    var expanded: [String] = []
    for pattern in patterns {
        if pattern.hasSuffix("/*.swift") {
            let dir = String(pattern.dropLast("/*.swift".count))
            let items = (try? fm.contentsOfDirectory(atPath: dir)) ?? []
            for item in items.sorted() where item.hasSuffix(".swift") {
                expanded.append("\(dir)/\(item)")
            }
        } else {
            expanded.append(pattern)
        }
    }
    expanded.append(testFile)
    return expanded
}

func runSync(_ executable: String, _ arguments: [String], environment: [String: String]) -> (Int32, String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    process.environment = environment
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    do {
        try process.run()
    } catch {
        return (127, "\(error)\n")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return (process.terminationStatus, String(data: data, encoding: .utf8) ?? "")
}

private final class CStringList {
    let pointers: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>
    private let count: Int

    init(_ values: [String]) {
        count = values.count
        pointers = .allocate(capacity: count + 1)
        for (index, value) in values.enumerated() { pointers[index] = strdup(value) }
        pointers[count] = nil
    }

    deinit {
        for index in 0..<count { free(pointers[index]) }
        pointers.deallocate()
    }
}

func runWithTimeout(
    _ executable: String,
    logURL: URL,
    environment: [String: String],
    timeoutSeconds: TimeInterval
) -> (status: Int32, timedOut: Bool, output: String) {
    let logFD = Darwin.open(logURL.path, O_WRONLY | O_CREAT | O_TRUNC, 0o644)
    guard logFD >= 0 else {
        return (1, false, "could not open log file \(logURL.path)\n")
    }
    defer { try? FileManager.default.removeItem(at: logURL) }

    var attrs: posix_spawnattr_t?
    posix_spawnattr_init(&attrs)
    var emptyMask = sigset_t()
    sigemptyset(&emptyMask)
    var defaultSignals = sigset_t()
    sigfillset(&defaultSignals)
    posix_spawnattr_setsigmask(&attrs, &emptyMask)
    posix_spawnattr_setsigdefault(&attrs, &defaultSignals)
    // Detach from any parent TTY so interactive shells (`zsh -i`) cannot stall on SIGTTOU.
    posix_spawnattr_setflags(
        &attrs, Int16(POSIX_SPAWN_SETSID | POSIX_SPAWN_SETSIGMASK | POSIX_SPAWN_SETSIGDEF))

    var actions: posix_spawn_file_actions_t?
    posix_spawn_file_actions_init(&actions)
    posix_spawn_file_actions_addopen(&actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0)
    posix_spawn_file_actions_adddup2(&actions, logFD, STDOUT_FILENO)
    posix_spawn_file_actions_adddup2(&actions, logFD, STDERR_FILENO)
    posix_spawn_file_actions_addclose(&actions, logFD)

    let argv = CStringList([executable])
    let envp = CStringList(environment.map { "\($0.key)=\($0.value)" })
    var pid: pid_t = 0
    let spawnStatus = posix_spawn(
        &pid, executable, &actions, &attrs, argv.pointers, envp.pointers)

    posix_spawnattr_destroy(&attrs)
    posix_spawn_file_actions_destroy(&actions)
    Darwin.close(logFD)

    guard spawnStatus == 0, pid > 0 else {
        return (127, false, "posix_spawn failed: \(spawnStatus)\n")
    }

    let deadline = Date().addingTimeInterval(timeoutSeconds)
    var rawStatus: Int32 = 0
    var timedOut = false

    while true {
        let waited = waitpid(pid, &rawStatus, WNOHANG)
        if waited == pid { break }
        if waited < 0 && errno != EINTR { break }
        if Date() >= deadline {
            timedOut = true
            kill(-pid, SIGKILL)
            kill(pid, SIGKILL)
            while waitpid(pid, &rawStatus, 0) < 0 && errno == EINTR {}
            break
        }
        Thread.sleep(forTimeInterval: 0.05)
    }

    let exitCode: Int32
    if rawStatus & 0x7F != 0 {
        exitCode = 128 + (rawStatus & 0x7F)
    } else {
        exitCode = (rawStatus >> 8) & 0xFF
    }

    let data = (try? Data(contentsOf: logURL)) ?? Data()
    let text = String(data: data, encoding: .utf8) ?? ""
    return (exitCode, timedOut, text)
}

let root = findRepoRoot()
let fm = FileManager.default
fm.changeCurrentDirectoryPath(root.path)
let env = makeEnvironment()

let arg = CommandLine.arguments.dropFirst().first ?? ""
let emitDB = arg == "--index"
let filterName = emitDB ? "" : arg

let selected = harnesses.filter { harness in
    if !filterName.isEmpty && harness.name != filterName { return false }
    if !emitDB && harness.indexOnly { return false }
    return true
}

if selected.isEmpty {
    FileHandle.standardError.write(Data("No harness named '\(filterName)'.\n".utf8))
    exit(2)
}

if emitDB {
    let sdkResult = runSync("/usr/bin/xcrun", ["--show-sdk-path", "--sdk", "macosx"], environment: env)
    let sdkPath = sdkResult.1.trimmingCharacters(in: .whitespacesAndNewlines)
    var entries: [[String: Any]] = []
    for harness in selected {
        let srcs = expandSources(harness.sources, testFile: "Tests/\(harness.name).swift")
            .map { "\(root.path)/\($0)" }
        let optFlag = harness.optimize ? "-O" : "-Onone"
        let cmd = "swiftc -swift-version 6 -sdk \(sdkPath) \(optFlag) " + srcs.joined(separator: " ")
        let claimed = srcs.filter { $0.contains("/Tests/") }
        entries.append(["directory": root.path, "command": cmd, "files": claimed])
    }
    let compileURL = root.appending(path: ".compile")
    var kept: [[String: Any]] = []
    if let existingData = try? Data(contentsOf: compileURL),
        let existing = try? JSONSerialization.jsonObject(with: existingData) as? [[String: Any]]
    {
        kept = existing.filter { entry in
            let files = entry["files"] as? [String] ?? []
            return !files.contains { $0.contains("/Tests/") }
        }
    }
    let merged = kept + entries
    let outData = try JSONSerialization.data(withJSONObject: merged, options: [.prettyPrinted])
    try outData.write(to: compileURL)
    print("\(entries.count) harness entries indexed into .compile")
    exit(0)
}

let tmpDir = ProcessInfo.processInfo.environment["TMPDIR"] ?? "/tmp"
let binDir = URL(fileURLWithPath: tmpDir).appending(path: "tinycast-harness")
try fm.createDirectory(at: binDir, withIntermediateDirectories: true)

let ordered = selected.filter(\.slow) + selected.filter { !$0.slow }
let total = ordered.count
let jobs = max(1, Int(env["TINYCAST_TEST_JOBS"] ?? "") ?? 4)
let timeoutSeconds = Double(env["TINYCAST_TEST_TIMEOUT"] ?? "") ?? 300.0
let startedAt = Date()

final class SuiteState: @unchecked Sendable {
    let lock = NSLock()
    var finished = 0
    var running: Set<String> = []
    var failures: [(name: String, log: String)] = []
}

let state = SuiteState()
let width = String(total).count
let semaphore = DispatchSemaphore(value: jobs)
let group = DispatchGroup()
let queue = DispatchQueue(label: "run-tests.workers", attributes: .concurrent)

let reporter = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "run-tests.reporter"))
reporter.schedule(deadline: .now() + 15, repeating: 15)
reporter.setEventHandler {
    state.lock.lock()
    let active = state.running.sorted().joined(separator: " ")
    let elapsed = Int(Date().timeIntervalSince(startedAt))
    state.lock.unlock()
    if !active.isEmpty {
        print("        \u{1B}[2mstill running after \(elapsed)s: \(active)\u{1B}[0m")
        fflush(stdout)
    }
}
reporter.resume()

for harness in ordered {
    group.enter()
    semaphore.wait()
    queue.async {
        defer {
            semaphore.signal()
            group.leave()
        }
        state.lock.lock()
        state.running.insert(harness.name)
        state.lock.unlock()

        defer {
            state.lock.lock()
            state.running.remove(harness.name)
            state.lock.unlock()
        }

        let sources = expandSources(harness.sources, testFile: "Tests/\(harness.name).swift")
        let outBinary = binDir.appending(path: harness.name).path
        let optFlag = harness.optimize ? "-O" : "-Onone"

        let compileStart = Date()
        let compileResult = runSync(
            "/usr/bin/swiftc",
            ["-swift-version", "6", optFlag] + sources + ["-o", outBinary],
            environment: env)
        let compileTime = Date().timeIntervalSince(compileStart)

        let verdictLine: String
        var failedLog: String?

        if compileResult.0 != 0 {
            verdictLine = String(format: "\u{1B}[31mFAIL\u{1B}[0m  %-25s did not compile", (harness.name as NSString).utf8String!)
            failedLog = compileResult.1
        } else {
            let runStart = Date()
            let logURL = binDir.appending(path: "\(harness.name).log")
            let runResult = runWithTimeout(
                outBinary, logURL: logURL, environment: env, timeoutSeconds: timeoutSeconds)
            let runTime = Date().timeIntervalSince(runStart)

            if runResult.timedOut {
                verdictLine = String(
                    format: "\u{1B}[31mFAIL\u{1B}[0m  %-25s timed out after %.0fs",
                    (harness.name as NSString).utf8String!, timeoutSeconds)
                failedLog = runResult.output + "\n[run-tests] killed after \(Int(timeoutSeconds))s without finishing\n"
            } else if runResult.status > 128 {
                verdictLine = String(
                    format: "\u{1B}[31mFAIL\u{1B}[0m  %-25s crashed (signal %d) after %.1fs",
                    (harness.name as NSString).utf8String!, runResult.status - 128, runTime)
                failedLog = runResult.output
            } else if runResult.status != 0 {
                verdictLine = String(
                    format: "\u{1B}[31mFAIL\u{1B}[0m  %-25s assertion failed after %.1fs",
                    (harness.name as NSString).utf8String!, runTime)
                failedLog = runResult.output
            } else {
                verdictLine = String(
                    format: "\u{1B}[32mok\u{1B}[0m    %-25s %5.1fs  \u{1B}[2m(compile %.1fs)\u{1B}[0m",
                    (harness.name as NSString).utf8String!, runTime, compileTime)
            }
        }

        state.lock.lock()
        state.finished += 1
        let idx = state.finished
        if let failedLog { state.failures.append((harness.name, failedLog)) }
        let idxStr = String(format: "%*d", width, idx)
        print("[\(idxStr)/\(total)] \(verdictLine)")
        fflush(stdout)
        state.lock.unlock()
    }
}

group.wait()
reporter.cancel()
let elapsed = Int(Date().timeIntervalSince(startedAt))

if !state.failures.isEmpty {
    for (name, log) in state.failures.sorted(by: { $0.name < $1.name }) {
        FileHandle.standardError.write(Data("\n\u{1B}[31m--- \(name) ---\u{1B}[0m\n\(log)\n".utf8))
    }
    FileHandle.standardError.write(
        Data("\n\u{1B}[31mFAILED\u{1B}[0m  \(state.failures.count) of \(total) harness(es) failed in \(elapsed)s: \(state.failures.map(\.name).joined(separator: " "))\n".utf8))
    exit(1)
}

print("\n\u{1B}[32mPASSED\u{1B}[0m  All \(total) harness(es) passed in \(elapsed)s.")
