import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var recorder = LocationRecorder()
    @State private var showFilenamePrompt = false
    @State private var filename = ""
    @State private var exportURL: URL? = nil
    @State private var showExporter = false
    @State private var recordingStartTime: Date? = nil
    @State private var elapsedSeconds: Int = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(recorder.isRecording ? "Recording…" : "Ready")
                .font(.title2)
                .foregroundColor(recorder.isRecording ? .red : .secondary)
            
            if recorder.isRecording {
                Text(formattedElapsedTime)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
            
            Text("\(recorder.pointCount) points recorded")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: toggleRecording) {
                Circle()
                    .fill(recorder.isRecording ? Color.red : Color.green)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: recorder.isRecording ? "stop.fill" : "record.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            recorder.requestPermission()
        }
        .onReceive(timer) { _ in
            guard let start = recordingStartTime else { return }
            elapsedSeconds = Int(Date().timeIntervalSince(start))
        }
        .alert("Save Recording", isPresented: $showFilenamePrompt) {
            TextField("Filename", text: $filename)
            Button("Save") { finalizeExport() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for this GPX file.")
        }
        .sheet(isPresented: $showExporter) {
            if let url = exportURL {
                DocumentExporter(url: url)
            }
        }
    }
    
    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stop()
            recordingStartTime = nil
            filename = "recording-\(Int(Date().timeIntervalSince1970))"
            showFilenamePrompt = true
        } else {
            recordingStartTime = Date()
            elapsedSeconds = 0
            recorder.start()
        }
    }
    
    private var formattedElapsedTime: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
    
    private func finalizeExport() {
        let gpx = GPXExporter.generateGPX(from: recorder.recordedLocations, trackName: filename)
        if let url = GPXExporter.writeTempFile(gpxString: gpx, filename: filename) {
            exportURL = url
            showExporter = true
        }
    }
}

struct DocumentExporter: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        UIDocumentPickerViewController(forExporting: [url])
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
