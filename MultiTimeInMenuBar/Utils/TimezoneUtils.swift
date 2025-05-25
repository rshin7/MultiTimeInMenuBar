import Foundation
import AppKit

struct TimezoneUtils {
    // Maps timezone IDs (e.g. "America/New_York") to ISO country codes (e.g. "us")
    static func countryCode(for timezoneID: String) -> String {
        let components = timezoneID.split(separator: "/")
        guard components.count >= 2 else { return "us" }
        let region = components[0].lowercased()
        let city = components[1].lowercased()

        let cityMap: [String: String] = [
            // Explicit mappings
            "hong_kong": "hk",
            "macau": "mo",
            "macao": "mo",
            "taipei": "tw",
            "tokyo": "jp",
            "seoul": "kr",
            "shanghai": "cn",
            "urumqi": "cn",
            "kashgar": "cn",
            "chongqing": "cn",
            "harbin": "cn",
            "singapore": "sg",
            "ho_chi_minh": "vn",
            "saigon": "vn",
            "bangkok": "th",
            "jakarta": "id",
            "manila": "ph",
            "kuala_lumpur": "my",
            "dubai": "ae",
            "jerusalem": "il",
            "tel_aviv": "il",
            "gaza": "ps",
            "hebron": "ps",
            "kolkata": "in",
            "karachi": "pk",
            "dhaka": "bd",
            "yangon": "mm",
            "tehran": "ir",
            "baghdad": "iq",
            "riyadh": "sa",
            "beirut": "lb",
            "amman": "jo",
            "damascus": "sy",
            "baku": "az",
            "tashkent": "uz",
            "almaty": "kz",
            "bishkek": "kg",
            "phnom_penh": "kh",
            "vientiane": "la",

            // North America
            "toronto": "ca", "vancouver": "ca", "montreal": "ca", "halifax": "ca",
            "winnipeg": "ca", "edmonton": "ca", "calgary": "ca",

            // Mexico
            "mexico_city": "mx", "tijuana": "mx", "monterrey": "mx", "chihuahua": "mx", "mazatlan": "mx",

            // South America
            "buenos_aires": "ar", "cordoba": "ar", "mendoza": "ar", "catamarca": "ar",
            "jujuy": "ar", "la_rioja": "ar", "salta": "ar", "tucuman": "ar",
            "sao_paulo": "br", "rio_branco": "br", "manaus": "br", "belem": "br",
            "fortaleza": "br", "recife": "br", "araguaina": "br",
            "santiago": "cl",
            "lima": "pe",
            "bogota": "co",
            "caracas": "ve",
            "guayaquil": "ec",
            "asuncion": "py",
            "montevideo": "uy",
            "la_paz": "bo",

            // Africa
            "cairo": "eg", "johannesburg": "za", "nairobi": "ke", "lagos": "ng",
            "casablanca": "ma", "accra": "gh", "addis_ababa": "et",

            // Europe
            "london": "gb", "paris": "fr", "berlin": "de", "rome": "it",
            "madrid": "es", "amsterdam": "nl", "brussels": "be", "vienna": "at",
            "moscow": "ru", "kyiv": "ua", "kiev": "ua",

            // Pacific
            "auckland": "nz", "guam": "gu", "fiji": "fj", "apiai": "ws"
        ]

        if let explicitCode = cityMap[city] {
            return explicitCode
        }

        // Region-based default fallback
        switch region {
        case "america":
            return "us"
        case "asia":
            return ""  // intentionally left blank, avoids incorrect assumption
        case "europe":
            return "eu"
        case "africa":
            return "za"
        case "australia":
            return "au"
        case "pacific":
            return ""
        case "atlantic":
            return "gb"
        default:
            return "us"
        }
    }

    
    static func formatTime(date: Date, timezone: String, use24Hour: Bool, showSeconds: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timezone)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if use24Hour {
            formatter.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = showSeconds ? "h:mm:ss a" : "h:mm a"
        }
        
        return formatter.string(from: date)
    }
    
    static func countryToFlag(_ countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            guard let scalarValue = UInt32(exactly: scalar.value) else { continue }
            guard let flagScalar = UnicodeScalar(base + scalarValue) else { continue }
            flag.append(String(flagScalar))
        }
        return flag
    }
    
    static func flagImage(for timezoneID: String) -> NSImage {
        let countryCode = countryCode(for: timezoneID).lowercased()
        if let image = NSImage(named: countryCode) {
            return image
        }
        return NSImage() // Return empty image if not found
    }
} 
