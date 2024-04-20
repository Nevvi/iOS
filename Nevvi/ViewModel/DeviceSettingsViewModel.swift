import Foundation

class DeviceSettingsViewModel : ObservableObject {
    @Published var autoSync: Bool = false
    @Published var notifyOutOfSync: Bool = false
    @Published var notifyBirthdays: Bool = false
    
    func update(settings: DeviceSettings) {
        self.autoSync = settings.autoSync
        self.notifyOutOfSync = settings.notifyOutOfSync
        self.notifyBirthdays = settings.notifyBirthdays
    }
    
    func toModel() -> DeviceSettings {
        return DeviceSettings(
            autoSync: self.autoSync,
            notifyOutOfSync: self.notifyOutOfSync,
            notifyBirthdays: self.notifyBirthdays
        )
    }
}
