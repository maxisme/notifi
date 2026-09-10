import Foundation
import SwiftData

@Model
final class SyncState {
    var hasSynced: Bool = false
    var failureFirstSeen: [String: Double]

    init(hasSynced: Bool = false, failureFirstSeen: [String: Double] = [:]) {
        self.hasSynced = hasSynced
        self.failureFirstSeen = failureFirstSeen
    }
}
