import Foundation
import CoreLocation
#if canImport(UIKit)
import UIKit
#endif

enum GPXExporter {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static func generateGPX(from locations: [CLLocation], trackName: String, settings: SettingsStore = .shared) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="GPXRecorder" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" xmlns:gprec="https://github.com/DrProton824/GPXRecorder">

        """
        
        if settings.includeDeviceMetadata {
            xml += "<metadata>\n"
            xml += "<gprec:device>\(deviceModel().xmlEscaped)</gprec:device>\n"
            xml += "<gprec:os>\(osVersion().xmlEscaped)</gprec:os>\n"
            xml += "<gprec:appVersion>\(appVersion().xmlEscaped)</gprec:appVersion>\n"
            xml += "</metadata>\n"
        }
        
        xml += "<trk><name>\(trackName.xmlEscaped)</name><trkseg>\n"
        
        for loc in locations {
            let lat = loc.coordinate.latitude
            let lon = loc.coordinate.longitude
            let ele = loc.altitude
            let time = isoFormatter.string(from: loc.timestamp)
            
            xml += "<trkpt lat=\"\(lat)\" lon=\"\(lon)\"><ele>\(ele)</ele><time>\(time)</time>"
            
            var extensionsBlock = ""
            if settings.recordSpeed, loc.speed >= 0 {
                extensionsBlock += "<gpxtpx:speed>\(loc.speed)</gpxtpx:speed>"
            }
            if settings.recordCourse, loc.course >= 0 {
                extensionsBlock += "<gpxtpx:course>\(loc.course)</gpxtpx:course>"
            }
            if settings.recordAccuracy {
                extensionsBlock += "<gprec:hAcc>\(loc.horizontalAccuracy)</gprec:hAcc>"
                extensionsBlock += "<gprec:vAcc>\(loc.verticalAccuracy)</gprec:vAcc>"
                if loc.speed >= 0 {
                    extensionsBlock += "<gprec:speedAccuracy>\(loc.speedAccuracy)</gprec:speedAccuracy>"
                }
                if loc.course >= 0 {
                    extensionsBlock += "<gprec:courseAccuracy>\(loc.courseAccuracy)</gprec:courseAccuracy>"
                }
            }
            if !extensionsBlock.isEmpty {
                xml += "<extensions>\(extensionsBlock)</extensions>"
            }
            
            xml += "</trkpt>\n"
        }
        xml += "</trkseg></trk></gpx>"
        return xml
    }
    
    static func writeTempFile(gpxString: String, filename: String) -> URL? {
        let safeName = filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "recording" : filename
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).gpx")
        do {
            try gpxString.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
    
    private static func deviceModel() -> String {
        #if canImport(UIKit)
        return UIDevice.current.model
        #else
        return "Unknown"
        #endif
    }
    
    private static func osVersion() -> String {
        #if canImport(UIKit)
        return UIDevice.current.systemVersion
        #else
        return "Unknown"
        #endif
    }
    
    private static func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }
}

private extension String {
    var xmlEscaped: String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
