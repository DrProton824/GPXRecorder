import Foundation
import CoreLocation

enum GPXExporter {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static func generateGPX(from locations: [CLLocation], trackName: String) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="GPXRecorder" xmlns="http://www.topografix.com/GPX/1/1">
        <trk><name>\(trackName.xmlEscaped)</name><trkseg>

        """
        for loc in locations {
            let lat = loc.coordinate.latitude
            let lon = loc.coordinate.longitude
            let ele = loc.altitude
            let time = isoFormatter.string(from: loc.timestamp)
            xml += "<trkpt lat=\"\(lat)\" lon=\"\(lon)\"><ele>\(ele)</ele><time>\(time)</time></trkpt>\n"
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
}

private extension String {
    var xmlEscaped: String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
