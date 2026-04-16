import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraVM = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraVM.session)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                if cameraVM.suggestions.isEmpty {
                    Text("Point camera at a person")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(cameraVM.suggestions, id: \.bodyPart) { s in
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(s.suggestion)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear { cameraVM.startSession() }
    }
}
