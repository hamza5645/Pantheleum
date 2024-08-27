import SwiftUI
import AVKit

struct FullScreenVideoPlayer: View {
    let player: AVPlayer
    @Environment(\.presentationMode) var presentationMode
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            player.play()
            isPlaying = true
        }
        .onDisappear {
            player.pause()
        }
    }
}