import Foundation

class DeviceSettingsViewModel : ObservableObject {
    @Published var autoSync: Bool = false
    
    func update(settings: DeviceSettings) {
        self.autoSync = settings.autoSync
    }
    
    func toModel() -> DeviceSettings {
        return DeviceSettings(autoSync: self.autoSync)
    }
}
