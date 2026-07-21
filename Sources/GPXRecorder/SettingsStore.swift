import Foundation
import Combine

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @Published var recordSpeed: Bool {
        didSet { UserDefaults.standard.set(recordSpeed, forKey: Keys.recordSpeed) }
    }
    @Published var recordCourse: Bool {
        didSet { UserDefaults.standard.set(recordCourse, forKey: Keys.recordCourse) }
    }
    @Published var recordAccuracy: Bool {
        didSet { UserDefaults.standard.set(recordAccuracy, forKey: Keys.recordAccuracy) }
    }
    @Published var includeDeviceMetadata: Bool {
        didSet { UserDefaults.standard.set(includeDeviceMetadata, forKey: Keys.includeDeviceMetadata) }
    }
    
    private enum Keys {
        static let recordSpeed = "settings.recordSpeed"
        static let recordCourse = "settings.recordCourse"
        static let recordAccuracy = "settings.recordAccuracy"
        static let includeDeviceMetadata = "settings.includeDeviceMetadata"
    }
    
    private init() {
        let defaults = UserDefaults.standard
        self.recordSpeed = defaults.object(forKey: Keys.recordSpeed) as? Bool ?? true
        self.recordCourse = defaults.object(forKey: Keys.recordCourse) as? Bool ?? true
        self.recordAccuracy = defaults.object(forKey: Keys.recordAccuracy) as? Bool ?? true
        self.includeDeviceMetadata = defaults.object(forKey: Keys.includeDeviceMetadata) as? Bool ?? true
    }
}
