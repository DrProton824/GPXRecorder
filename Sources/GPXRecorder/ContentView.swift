import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var recorder = LocationRecorder()
    @State private var showFilenamePrompt = false
    @State private var filename = ""
    @State private var exportURL: URL? = nil
    @State private var showExporter = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(recorder.isRecording ? "Recording…" : "Ready")
                .font(.title2)
                .foregroundColor(recorder.isRecording ? .red : .secondary)
            
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
            filename = "recording-\(Int(Date().timeIntervalSince1970))"
            showFilenamePrompt = true
        } else {
            recorder.start()
        }
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
