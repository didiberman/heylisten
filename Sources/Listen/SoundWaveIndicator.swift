import SwiftUI
import Cocoa

class SoundWaveIndicator: NSObject {
    private var window: NSWindow?
    private var hostingController: NSHostingController<SoundWaveView>?
    private var animationTimer: Timer?
    
    func show() {
        guard window == nil else { return }
        
        let soundWaveView = SoundWaveView()
        hostingController = NSHostingController(rootView: soundWaveView)
        
        // Get screen dimensions
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        // Position at bottom center of screen
        let windowWidth: CGFloat = 120
        let windowHeight: CGFloat = 60
        let xPosition = (screenFrame.width - windowWidth) / 2
        let yPosition: CGFloat = 100 // 100px from bottom
        
        window = NSWindow(
            contentRect: NSRect(x: xPosition, y: yPosition, width: windowWidth, height: windowHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window?.contentViewController = hostingController
        window?.backgroundColor = NSColor.clear
        window?.isOpaque = false
        window?.level = .floating
        window?.ignoresMouseEvents = true
        window?.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window?.hasShadow = false
        
        window?.makeKeyAndOrderFront(nil)
        
        // Start animation
        soundWaveView.startAnimating()
    }
    
    func hide() {
        // Stop animation before closing window
        if let controller = hostingController {
            controller.rootView.stopAnimating()
        }
        
        window?.close()
        window = nil
        hostingController = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct SoundWaveView: View {
    @State private var animationPhase: Double = 0
    @State private var isAnimating = false
    @State private var animationTimer: Timer?
    
    let barCount = 5
    let barWidth: CGFloat = 4
    let barSpacing: CGFloat = 6
    let maxHeight: CGFloat = 30
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .cyan]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: barWidth)
                    .frame(height: barHeight(for: index))
                    .animation(
                        .easeInOut(duration: 0.3)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: animationPhase
                    )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 8
        let animatedHeight = maxHeight * (0.3 + 0.7 * abs(sin(animationPhase + Double(index) * 0.5)))
        return baseHeight + animatedHeight * (isAnimating ? 1.0 : 0.0)
    }
    
    func startAnimating() {
        stopAnimating() // Stop any existing timer first
        isAnimating = true
        animationPhase = 0
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            animationPhase += 0.3
        }
    }
    
    func stopAnimating() {
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    SoundWaveView()
        .frame(width: 120, height: 60)
}