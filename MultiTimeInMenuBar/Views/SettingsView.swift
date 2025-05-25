// SettingsView.swift
// MultiTimeInMenuBar

import SwiftUI
import Combine

struct AutocompleteField: View {
    @Binding var text: String
    let suggestions: [String]
    let onCommit: () -> Void
    
    @FocusState private var isFocused: Bool
    @State private var selectedSuggestionIndex: Int = 0
    
    var currentSuggestion: String? {
        guard !text.isEmpty,
              let suggestion = suggestions.first,
              suggestion.lowercased().hasPrefix(text.lowercased()) else {
            return nil
        }
        return suggestion
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background TextField (invisible, for layout)
            if let suggestion = currentSuggestion,
               isFocused {
                Text(suggestion)
                    .foregroundColor(.clear)
                    .allowsHitTesting(false)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
            }
            
            // Main content
            HStack(spacing: 0) {
                TextField("Enter city", text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        if let suggestion = currentSuggestion {
                            text = suggestion
                        }
                        onCommit()
                    }
                    .onChange(of: text) { oldValue, newValue in
                        selectedSuggestionIndex = 0
                    }
                    .onKeyPress(.downArrow) {
                        if selectedSuggestionIndex < suggestions.count - 1 {
                            selectedSuggestionIndex += 1
                            if !suggestions.isEmpty {
                                text = suggestions[selectedSuggestionIndex]
                            }
                        }
                        return .handled
                    }
                    .onKeyPress(.upArrow) {
                        if selectedSuggestionIndex > 0 {
                            selectedSuggestionIndex -= 1
                            text = suggestions[selectedSuggestionIndex]
                        }
                        return .handled
                    }
                    .onKeyPress(.tab) {
                        if let suggestion = currentSuggestion {
                            text = suggestion
                        }
                        return .handled
                    }
                
                if let suggestion = currentSuggestion,
                   isFocused {
                    Text(suggestion.dropFirst(text.count))
                        .foregroundColor(.gray)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
    }
}

// Create a shared state manager
class TimezoneManager: ObservableObject {
    static let shared = TimezoneManager()
    
    @AppStorage("timezoneItems") private var rawTimezoneItems: Data = Data()
    @Published var timezones: [TimezoneItem] = []
    
    init() {
        loadTimezones()
    }
    
    func loadTimezones() {
        if let decoded = try? JSONDecoder().decode([TimezoneItem].self, from: rawTimezoneItems) {
            timezones = decoded.sorted(by: { $0.order < $1.order })
        }
        
        // Always ensure we have at least NY time
        if timezones.isEmpty {
            let defaultTimezone = TimezoneItem(
                id: UUID(),
                timezoneID: "America/New_York",
                customPrefix: nil,
                order: 0
            )
            timezones = [defaultTimezone]
            saveTimezones()
        }
    }
    
    func saveTimezones() {
        if let encoded = try? JSONEncoder().encode(timezones) {
            rawTimezoneItems = encoded
            NotificationCenter.default.post(name: .timezonesDidChange, object: nil)
        }
    }
    
    func addTimezone(_ timezone: TimezoneItem) {
        timezones.append(timezone)
        saveTimezones()
    }
    
    func deleteTimezone(_ item: TimezoneItem) {
        timezones.removeAll { $0.id == item.id }
        saveTimezones()
    }
    
    func reorderTimezones(from: IndexSet, to: Int) {
        timezones.move(fromOffsets: from, toOffset: to)
        for (i, _) in timezones.enumerated() {
            timezones[i].order = i
        }
        saveTimezones()
    }
}

struct SettingsView: View {
    @StateObject private var timezoneManager = TimezoneManager.shared
    @AppStorage("use24Hour") private var use24Hour: Bool = false
    @AppStorage("showSeconds") private var showSeconds: Bool = true
    @AppStorage("showFlags") private var showFlags: Bool = true
    @AppStorage("showDayDiff") private var showDayDiff: Bool = false
    @State private var stackClocks: Bool = UserDefaults.standard.bool(forKey: "stackClocks")
    
    @State private var newCityInput: String = ""

    private var isValidCityInput: Bool {
        !newCityInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        CityToTimezone.mapping.keys.contains(where: { $0.caseInsensitiveCompare(newCityInput) == .orderedSame })
    }

    private var filteredCities: [String] {
        if newCityInput.isEmpty { 
            return [] 
        }
        
        let searchTerm = newCityInput.lowercased()
        let allCities = Array(CityToTimezone.mapping.keys)
        
        let filtered = allCities.filter { city in
            city.lowercased().hasPrefix(searchTerm)
        }
        return filtered.sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("MultiTimeInMenuBar")
                        .font(.title2)
                        .bold()

                    Text("v1.0.2")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.top)

                // Display Settings Section
                GroupBox("Display Settings") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Use 24-hour format", isOn: $use24Hour)
                    Toggle("Show seconds", isOn: $showSeconds)
                    Toggle("Show flags", isOn: $showFlags)
                    Toggle("Show day difference", isOn: $showDayDiff)
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            
            // Add New Timezone Section
            GroupBox("Add New Timezone") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        AutocompleteField(
                            text: $newCityInput,
                            suggestions: filteredCities,
                            onCommit: addTimezone
                        )
                        .frame(width: 200)
                        
                        Button("Add Clock", action: addTimezone)
                            .disabled(!isValidCityInput)
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal)
            
            // Timezone List Section
            GroupBox("Timezones") {
                List {
                    ForEach(timezoneManager.timezones.indices, id: \.self) { index in
                        TimezoneRowView(
                            item: Binding(
                                get: { timezoneManager.timezones[index] },
                                set: { newValue in
                                    timezoneManager.timezones[index] = newValue
                                    timezoneManager.saveTimezones()
                                }
                            ),
                            deleteAction: {
                                timezoneManager.deleteTimezone(timezoneManager.timezones[index])
                            }
                        )
                    }
                    .onMove(perform: timezoneManager.reorderTimezones)
                }
                .frame(height: 200)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .padding()
        .frame(width: 500, height: 540)
    }

    // MARK: Mutators
    func addTimezone() {
        guard let tzID = CityToTimezone.mapping.first(where: { $0.key.caseInsensitiveCompare(newCityInput) == .orderedSame })?.value else { return }
        let new = TimezoneItem(
            id: UUID(),
            timezoneID: tzID,
            customPrefix: nil,
            order: (timezoneManager.timezones.map { $0.order }.max() ?? 0) + 1,
            cityName: newCityInput
        )
        timezoneManager.addTimezone(new)
        newCityInput = ""
    }
}

// Window management
class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var windowController: NSWindowController?
    
    func showWindow() {
        if let windowController = self.windowController {
            windowController.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 540),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.contentView = hostingView
        window.center()
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        self.windowController = windowController
    }
}

struct CityToTimezone {
    static let mapping: [String: String] = {
        guard let url = Bundle.main.url(forResource: "city_to_timezone", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            print("⚠️ Failed to load city_to_timezone.json")
            return [:]
        }
        return decoded
    }()
}
