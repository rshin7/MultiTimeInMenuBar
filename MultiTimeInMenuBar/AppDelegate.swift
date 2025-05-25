import Cocoa
import SwiftUI
import os.log

// Helper extension for safe array access
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: DispatchSourceTimer?
    private var notificationObserver: NSObjectProtocol?
    
    private let timezoneManager = TimezoneManager.shared
    private var timezones: [TimezoneItem] { timezoneManager.timezones }
    private var formatters: [String: DateFormatter] = [:]
    
    @AppStorage("use24Hour") private var use24Hour: Bool = false {
        didSet { 
            formatters.removeAll() // Clear cached formatters when format changes
            updateMenuTitle()
            synchronizeTimer()
        }
    }
    @AppStorage("showSeconds") private var showSeconds: Bool = true {
        didSet { 
            // Clear formatters since the time format is changing
            formatters.removeAll()
            
            // Cancel existing timer before switching
            timer?.cancel()
            timer = nil
            
            // Update display immediately with new format
            updateMenuTitle()
            
            // Then adjust the timer for the new setting
            if showSeconds {
                synchronizeTimer()
            } else {
                startBasicTimer()
            }
        }
    }
    @AppStorage("showFlags") private var showFlags: Bool = true {
        didSet { updateMenuTitle() }
    }
    @AppStorage("showDayDiff") private var showDayDiff: Bool = false {
        didSet { updateMenuTitle() }
    }
    @AppStorage("stackClocks") private var stackClocks: Bool = false {
        didSet { updateMenuTitle() }
    }
    
    private func getFormatter(for timezone: String) -> DateFormatter {
        let key = "\(timezone)_\(use24Hour)_\(showSeconds)" // Include settings in cache key
        if let cached = formatters[key] {
            return cached
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        if use24Hour {
            formatter.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = showSeconds ? "h:mm:ss a" : "h:mm a"
        }
        
        formatter.timeZone = TimeZone(identifier: timezone)
        formatters[key] = formatter
        return formatter
    }

    private func synchronizeTimer() {
        print("⏰ Synchronizing timer...")
        timer?.cancel()
        timer = nil
        
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond], from: now)
        
        // Calculate next second boundary
        components.second = (components.second ?? 0) + 1
        components.nanosecond = 0
        
        guard let nextSecond = calendar.date(from: components) else {
            print("⚠️ Failed to calculate next second, falling back to immediate start")
            startBasicTimer()
            return
        }
        
        let delay = nextSecond.timeIntervalSince(now)
        let timer = DispatchSource.makeTimerSource(queue: .main)
        
        // First update immediately
        updateMenuTitle()
        
        // Then schedule the timer for precise updates
        timer.schedule(wallDeadline: .now() + delay, repeating: 1.0, leeway: .milliseconds(1))
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.updateMenuTitle()
        }
        
        timer.resume()
        self.timer = timer
        print("✅ Timer synchronized with system clock")
    }
    
    private func startBasicTimer() {
        print("⏰ Starting basic timer...")
        timer?.cancel()
        timer = nil
        
        let timer = DispatchSource.makeTimerSource(queue: .main)
        
        // First update immediately
        updateMenuTitle()
        
        // Calculate delay to next minute
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute], from: now)
        components.minute = (components.minute ?? 0) + 1
        components.second = 0
        
        if let nextMinute = calendar.date(from: components) {
            let delay = nextMinute.timeIntervalSince(now)
            // Schedule first update at next minute boundary, then every 60 seconds
            timer.schedule(wallDeadline: .now() + delay, repeating: 60.0)
        } else {
            // Fallback if date calculation fails
            timer.schedule(deadline: .now(), repeating: 60.0)
        }
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.updateMenuTitle()
        }
        
        timer.resume()
        self.timer = timer
        print("✅ Basic timer started")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App launching...")
        setupNotificationObserver()
        setupStatusItem()
        if showSeconds {
            synchronizeTimer()
        } else {
            startBasicTimer()
        }
        print("✅ App launched with \(timezones.count) timezone(s)")
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.cancel()
        timer = nil
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupNotificationObserver() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .timezonesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🔄 Received timezone change notification")
            self?.updateMenuTitle()
        }
    }

    private func setupStatusItem() {
        print("🔧 Setting up status item...")
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let menu = NSMenu()
        menu.addItem(withTitle: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(withTitle: "About", action: #selector(openAbout), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        statusItem.menu = menu
        
        // Configure button for stacked layout
        if let button = statusItem.button {
            button.setAccessibilityElement(true)
            button.setAccessibilityRole(.button)
            button.setAccessibilityLabel("MultiTimeInMenuBar")
            
            // Enable multi-line text and adjust vertical alignment
            if let cell = button.cell as? NSButtonCell {
                cell.wraps = true
                cell.lineBreakMode = .byWordWrapping
                cell.baseWritingDirection = .leftToRight
                cell.alignment = .center
            }
        }
        
        updateMenuTitle()
        print("✅ Status item setup complete")
    }

    @objc private func statusItemClicked() {
        guard let button = statusItem.button else { return }
        let menu = createMenu()

        if let window = button.window {
            let buttonFrame = button.convert(button.bounds, to: nil)
            let screenRect = window.convertToScreen(buttonFrame)
            let menuOrigin = CGPoint(x: screenRect.minX, y: screenRect.minY)
            menu.popUp(positioning: nil, at: menuOrigin, in: nil)
        }
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func updateMenuTitle() {
        guard let statusItem = statusItem else { return }
        
        let now = Date()
        var components: [(prefix: String, time: String, flagImage: NSImage?, dayDiff: Int)] = []
        
        // Get the day component of the local time for comparison
        var calendar = Calendar.current
        let localDay = calendar.component(.day, from: now)
        
        for timezone in timezones {
            var prefix = ""
            var flagImage: NSImage? = nil
            
            if showFlags {
                flagImage = TimezoneUtils.flagImage(for: timezone.timezoneID)
            }
            
            if let customPrefix = timezone.customPrefix {
                prefix += customPrefix + " "
            }
            
            if let tz = TimeZone(identifier: timezone.timezoneID) {
                let formatter = getFormatter(for: timezone.timezoneID)
                
                // Calculate day difference
                var dayDiff = 0
                if showDayDiff {
                    calendar.timeZone = tz
                    let tzDay = calendar.component(.day, from: now)
                    dayDiff = tzDay - localDay
                    
                    // Handle month boundaries
                    if abs(dayDiff) > 15 {
                        dayDiff = dayDiff > 0 ? -1 : 1
                    }
                }
                
                components.append((
                    prefix: prefix,
                    time: formatter.string(from: now),
                    flagImage: flagImage,
                    dayDiff: dayDiff
                ))
            }
        }
        
        // Create attributed string with monospaced font for the time
        let result = NSMutableAttributedString()
        let monoFont = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        
        if stackClocks && components.count > 1 {
            // Create paragraph style for consistent alignment
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 1  // Reduced line spacing
            
            // Calculate number of columns needed
            let numColumns = (components.count + 1) / 2
            
            // Add extra top padding to prevent cutoff (3 lines of padding)
            result.append(NSAttributedString(string: "\n\n"))  // Reduced from 6 to 2 newlines for top padding
            
            // First row
            result.append(NSAttributedString(string: " "))
            for columnIndex in 0..<numColumns {
                let index = columnIndex * 2
                if index < components.count {
                    if columnIndex > 0 {
                        result.append(NSAttributedString(string: "      ")) // Column spacing (6 spaces)
                    }
                    appendStackedComponent(components[index], to: result, monoFont: monoFont, paragraphStyle: paragraphStyle)
                }
            }
            
            // Second row
            result.append(NSAttributedString(string: "\n "))
            for columnIndex in 0..<numColumns {
                let index = columnIndex * 2 + 1
                if index < components.count {
                    if columnIndex > 0 {
                        result.append(NSAttributedString(string: "      ")) // Column spacing (6 spaces)
                    }
                    appendStackedComponent(components[index], to: result, monoFont: monoFont, paragraphStyle: paragraphStyle)
                }
            }
        } else {
            // Original single-row layout
            for (index, component) in components.enumerated() {
                if index > 0 {
                    result.append(NSAttributedString(string: "  "))
                }
                appendComponent(component, to: result, monoFont: monoFont)
            }
        }
        
        statusItem.button?.attributedTitle = result
    }
    
    private func appendStackedComponent(_ component: (prefix: String, time: String, flagImage: NSImage?, dayDiff: Int),
                                      to result: NSMutableAttributedString,
                                      monoFont: NSFont,
                                      paragraphStyle: NSParagraphStyle) {
        // Add flag or padding
        if showFlags {
            if let flagImage = component.flagImage {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = flagImage
                let imageSize = NSSize(width: 12, height: 8) // Slightly smaller flags
                imageAttachment.bounds = NSRect(origin: NSPoint(x: 0, y: -1), size: imageSize)
                result.append(NSAttributedString(attachment: imageAttachment))
                result.append(NSAttributedString(string: " "))
            } else {
                result.append(NSAttributedString(string: "   "))  // Consistent spacing when no flag
            }
        }
        
        // Add prefix
        if !component.prefix.isEmpty {
            result.append(NSAttributedString(
                string: component.prefix,
                attributes: [.font: monoFont, .paragraphStyle: paragraphStyle]
            ))
        }
        
        // Add time with monospaced font
        if use24Hour {
            result.append(NSAttributedString(
                string: component.time,
                attributes: [.font: monoFont, .paragraphStyle: paragraphStyle]
            ))
        } else {
            let timeComponents = component.time.split(separator: " ")
            if timeComponents.count == 2 {
                result.append(NSAttributedString(
                    string: String(timeComponents[0]),
                    attributes: [.font: monoFont, .paragraphStyle: paragraphStyle]
                ))
                result.append(NSAttributedString(
                    string: " " + timeComponents[1],
                    attributes: [.font: monoFont, .paragraphStyle: paragraphStyle]
                ))
            } else {
                result.append(NSAttributedString(
                    string: component.time,
                    attributes: [.font: monoFont, .paragraphStyle: paragraphStyle]
                ))
            }
        }
        
        // Add day difference if needed
        if showDayDiff && component.dayDiff != 0 {
            let dayDiffText = component.dayDiff > 0 ? " (+\(component.dayDiff)d)" : " (\(component.dayDiff)d)"
            result.append(NSAttributedString(
                string: dayDiffText,
                attributes: [.font: monoFont, .foregroundColor: NSColor.secondaryLabelColor, .paragraphStyle: paragraphStyle]
            ))
        }
    }

    private func appendComponent(_ component: (prefix: String, time: String, flagImage: NSImage?, dayDiff: Int),
                               to result: NSMutableAttributedString,
                               monoFont: NSFont) {
        // Add flag image if available
        if showFlags {
            if let flagImage = component.flagImage {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = flagImage
                let imageSize = NSSize(width: 14, height: 10)
                imageAttachment.bounds = NSRect(origin: NSPoint(x: 0, y: -1), size: imageSize)
                result.append(NSAttributedString(attachment: imageAttachment))
                result.append(NSAttributedString(string: " "))
            } else {
                result.append(NSAttributedString(string: "   "))  // Consistent spacing when no flag
            }
        }
        
        // Add prefix with regular font
        if !component.prefix.isEmpty {
            result.append(NSAttributedString(
                string: component.prefix,
                attributes: [.font: monoFont]
            ))
        }
        
        // Create paragraph style for left alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: monoFont,
            .paragraphStyle: paragraphStyle
        ]
        
        if use24Hour {
            result.append(NSAttributedString(
                string: component.time,
                attributes: timeAttributes
            ))
        } else {
            let timeComponents = component.time.split(separator: " ")
            if timeComponents.count == 2 {
                result.append(NSAttributedString(
                    string: String(timeComponents[0]),
                    attributes: timeAttributes
                ))
                result.append(NSAttributedString(
                    string: " " + timeComponents[1],
                    attributes: [.font: monoFont, .paragraphStyle: paragraphStyle]
                ))
            } else {
                result.append(NSAttributedString(
                    string: component.time,
                    attributes: timeAttributes
                ))
            }
        }
        
        if showDayDiff && component.dayDiff != 0 {
            let dayDiffText = component.dayDiff > 0 ? " (+\(component.dayDiff)d)" : " (\(component.dayDiff)d)"
            result.append(NSAttributedString(
                string: dayDiffText,
                attributes: [.font: monoFont, .foregroundColor: NSColor.secondaryLabelColor, .paragraphStyle: paragraphStyle]
            ))
        }
    }

    @objc private func openAbout() {
        AboutWindowController.shared.showWindow()
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.showWindow()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
