//
//  TimezoneItem.swift
//  MultiTimeInMenuBar
//
//  Created by Richard Shin on 4/6/25.
//

import Foundation

struct TimezoneItem: Codable, Identifiable, Equatable {
    let id: UUID
    var timezoneID: String        // e.g. "America/New_York"
    var customPrefix: String?     // Takes precedence over flag
    var order: Int
    var cityName: String?        // The user's selected city name
    
    var flag: String? {
        let countryCode = TimezoneUtils.countryCode(for: timezoneID)
        return TimezoneUtils.countryToFlag(countryCode)
    }
}
