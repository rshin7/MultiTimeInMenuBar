import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("MultiTimeInMenuBar")
                .font(.title2)
                .bold()
            Text("MultiTimeInMenuBar is a lightweight, free to use application that allows you to add additional clocks to your menu bar.")
                           .font(.footnote)
                           .multilineTextAlignment(.center)
                           .fixedSize(horizontal: false, vertical: true)
            VStack {
                Text("By Richard Shin (www.rshin.org), released under MIT License.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .frame(width: 250, height: 150)
        .padding()
    }
}

// Window management
class AboutWindowController {
    static let shared = AboutWindowController()
    private var windowController: NSWindowController?
    
    func showWindow() {
        if let windowController = self.windowController {
            windowController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let aboutView = AboutView()
        let hostingView = NSHostingView(rootView: aboutView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 150),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "About"
        window.contentView = hostingView
        window.center()
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        self.windowController = windowController
    }
} 
