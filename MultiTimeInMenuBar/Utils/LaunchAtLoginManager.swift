import Foundation
import ServiceManagement
import os.log

class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()
    
    private let logger = Logger(subsystem: "org.rshin.MultiTimeInMenuBar", category: "LaunchAtLogin")
    
    @Published private(set) var isEnabled = false
    
    private init() {
        updateStatus()
    }
    
    /// Check current login item status
    func updateStatus() {
        let service = SMAppService.mainApp
        isEnabled = service.status == .enabled
    }
    
    /// Enable or disable launch at login
    func setEnabled(_ enabled: Bool) {
        let service = SMAppService.mainApp
        
        do {
            if enabled {
                if service.status == .enabled {
                    logger.info("Launch at login already enabled")
                    return
                }
                
                try service.register()
                logger.info("Successfully registered for launch at login")
            } else {
                if service.status != .enabled {
                    logger.info("Launch at login already disabled")
                    return
                }
                
                try service.unregister()
                logger.info("Successfully unregistered from launch at login")
            }
        } catch {
            logger.error("Failed to \(enabled ? "register" : "unregister") launch at login: \(error.localizedDescription)")
        }
        
        // Update the published status
        updateStatus()
    }
} 
