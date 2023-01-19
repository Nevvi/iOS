import Foundation

class DeviceSettingsViewModel : ObservableObject {
    @Published var autoSync: Bool = false
    @Published var syncAllInformation: Bool = false
    
    func update(settings: DeviceSettings) {
        self.autoSync = settings.autoSync
        self.syncAllInformation = settings.syncAllInformation
    }
    
    func toModel() -> DeviceSettings {
        return DeviceSettings(autoSync: self.autoSync, syncAllInformation: self.syncAllInformation)
    }
}
