import Foundation

struct DeviceSettings: Hashable, Codable {
    var autoSync: Bool
    var notifyOutOfSync: Bool
    var notifyBirthdays: Bool
}
