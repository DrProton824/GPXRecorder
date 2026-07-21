import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsStore.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recorded Data"), footer: Text("Latitude, longitude, altitude, and time are always recorded. These fields are added as GPX extensions.")) {
                    Toggle("Speed", isOn: $settings.recordSpeed)
                    Toggle("Course (Heading)", isOn: $settings.recordCourse)
                    Toggle("Accuracy (Horizontal & Vertical)", isOn: $settings.recordAccuracy)
                }
                Section(header: Text("Metadata"), footer: Text("Adds device model, iOS version, and app version to the GPX file header.")) {
                    Toggle("Include Device Info", isOn: $settings.includeDeviceMetadata)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
