import Foundation
import CoreLocation

final class LocationRecorder: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isRecording = false
    @Published var pointCount = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private(set) var recordedLocations: [CLLocation] = []
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
    }
    
    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }
    
    func start() {
        recordedLocations = []
        pointCount = 0
        isRecording = true
        manager.startUpdatingLocation()
    }
    
    func stop() {
        isRecording = false
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRecording else { return }
        // Append every location CoreLocation delivers, unmodified and unfiltered —
        // no resampling, no fixed interval. This is exactly what the OS decided to report.
        recordedLocations.append(contentsOf: locations)
        DispatchQueue.main.async {
            self.pointCount = self.recordedLocations.count
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }
}
