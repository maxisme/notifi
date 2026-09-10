#if os(macOS) && canImport(Sparkle)
import Sparkle
import SwiftUI

private final class UpdaterDelegate: NSObject, SPUUpdaterDelegate {
    func updater(
        _ updater: SPUUpdater,
        willInstallUpdateOnQuit item: SUAppcastItem,
        immediateInstallationBlock: @escaping () -> Void
    ) -> Bool {
        immediateInstallationBlock()
        return true
    }
}

@MainActor
@Observable
final class Updater {
    static let shared = Updater()

    private let controller: SPUStandardUpdaterController
    private let delegate = UpdaterDelegate()
    private(set) var canCheck = false

    private(set) var automaticallyInstalls = false

    private init() {
        controller = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: delegate,
            userDriverDelegate: nil
        )
        controller.updater.automaticallyChecksForUpdates = true
        if UserDefaults.standard.object(forKey: "SUAutomaticallyUpdate") == nil {
            controller.updater.automaticallyDownloadsUpdates = true
        }
        controller.startUpdater()
        automaticallyInstalls = controller.updater.automaticallyDownloadsUpdates
        observation = controller.updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] updater, _ in
            Task { @MainActor in self?.canCheck = updater.canCheckForUpdates }
        }
    }

    private var observation: NSKeyValueObservation?

    func setAutomaticallyInstalls(_ enabled: Bool) {
        controller.updater.automaticallyDownloadsUpdates = enabled
        automaticallyInstalls = controller.updater.automaticallyDownloadsUpdates
    }

    func refresh() {
        automaticallyInstalls = controller.updater.automaticallyDownloadsUpdates
    }

    var lastCheck: Date? { controller.updater.lastUpdateCheckDate }

    func checkInBackground() {
        controller.updater.checkForUpdatesInBackground()
    }

    func checkForUpdates() {
        controller.updater.checkForUpdates()
    }
}
#endif
