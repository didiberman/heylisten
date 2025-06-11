import Cocoa

class ListeningIndicator {
    private var window: NSWindow?
    private var animationTimer: Timer?
    private var waveViews: [NSView] = []
    
    func show() {
        guard window == nil else { return }
        
        print("🟢 Showing listening indicator")
        
        // Create window at bottom center of screen
        let screenFrame = NSScreen.main?.frame ?? .zero
        let windowSize = CGSize(width: 200, height: 60)
        let windowOrigin = CGPoint(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.minY + 100
        )
        
        window = NSWindow(
            contentRect: NSRect(origin: windowOrigin, size: windowSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window?.isOpaque = false
        window?.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        window?.level = .floating
        window?.ignoresMouseEvents = true
        
        // Create content view
        let contentView = NSView(frame: NSRect(origin: .zero, size: windowSize))
        
        // Add microphone emoji and text
        let label = NSTextField(labelWithString: "🎙️ Listening...")
        label.textColor = .white
        label.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        label.alignment = .center
        label.frame = NSRect(x: 0, y: 15, width: windowSize.width, height: 30)
        contentView.addSubview(label)
        
        // Add simple sound wave bars
        createSoundWaves(in: contentView, containerSize: windowSize)
        
        window?.contentView = contentView
        window?.makeKeyAndOrderFront(nil)
        
        // Start simple animation
        startWaveAnimation()
    }
    
    func hide() {
        print("🔴 Hiding listening indicator")
        
        // Extremely defensive cleanup
        
        // 1. Stop and clear timer first
        if let timer = animationTimer {
            print("🔄 Invalidating timer...")
            timer.invalidate()
            animationTimer = nil
        }
        
        // 2. Clear all view references
        print("🧹 Clearing wave views...")
        waveViews.removeAll()
        
        // 3. Very defensive window cleanup
        if let window = window {
            print("🪟 Cleaning up window...")
            
            // Remove all animations and clear content
            window.contentView?.layer?.removeAllAnimations()
            window.contentView?.subviews.removeAll()
            window.contentView = nil
            
            // Hide and close safely
            window.orderOut(nil)
            
            // Small delay before closing to ensure everything is cleaned up
            DispatchQueue.main.async {
                window.close()
            }
        }
        
        // 4. Clear window reference
        window = nil
        
        print("✅ Listening indicator cleanup completed")
    }
    
    private func createSoundWaves(in container: NSView, containerSize: CGSize) {
        waveViews.removeAll()
        
        let waveCount = 5
        let waveWidth: CGFloat = 3
        let waveSpacing: CGFloat = 4
        let totalWidth = CGFloat(waveCount) * waveWidth + CGFloat(waveCount - 1) * waveSpacing
        let startX = (containerSize.width - totalWidth) / 2
        
        for i in 0..<waveCount {
            let waveView = NSView()
            waveView.wantsLayer = true
            waveView.layer?.backgroundColor = NSColor.systemBlue.cgColor
            waveView.layer?.cornerRadius = waveWidth / 2
            
            let x = startX + CGFloat(i) * (waveWidth + waveSpacing)
            waveView.frame = NSRect(x: x, y: 5, width: waveWidth, height: 10)
            
            container.addSubview(waveView)
            waveViews.append(waveView)
        }
    }
    
    private func startWaveAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.animateWaves()
        }
    }
    
    private func stopWaveAnimation() {
        if let timer = animationTimer {
            timer.invalidate()
            animationTimer = nil
            print("🔄 Animation timer invalidated")
        }
    }
    
    private func animateWaves() {
        for waveView in waveViews {
            let randomHeight = CGFloat.random(in: 5...20)
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.allowsImplicitAnimation = true
                
                var frame = waveView.frame
                frame.size.height = randomHeight
                frame.origin.y = 5 + (20 - randomHeight) / 2 // Center vertically
                waveView.frame = frame
            }
        }
    }
}