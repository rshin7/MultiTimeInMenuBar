import Foundation
import AppKit

struct TimezoneUtils {
    // Maps timezone IDs (e.g. "America/New_York") to ISO country codes (e.g. "us")
    static func countryCode(for timezoneID: String) -> String {
        let components = timezoneID.split(separator: "/")
        guard components.count >= 2 else { return "" }
        _ = components[0].lowercased()
        let city = components[1].lowercased()

        let cityMap: [String: String] = [
            // Asia
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
            "beijing": "cn", "new_delhi": "in", "mumbai": "in", "islamabad": "pk",
            "kabul": "af", "kathmandu": "np", "thimphu": "bt", "colombo": "lk",
            "male": "mv", "muscat": "om", "doha": "qa", "kuwait": "kw",
            "manama": "bh", "abu_dhabi": "ae", "sanaa": "ye", "aden": "ye",
            "tbilisi": "ge", "yerevan": "am", "ashgabat": "tm", "dushanbe": "tj",
            "astana": "kz", "nur-sultan": "kz", "ulaanbaatar": "mn", "pyongyang": "kp",
            "bandar_seri_begawan": "bn", "dili": "tl", "jakarta": "id",

            // North America
            "toronto": "ca", "vancouver": "ca", "montreal": "ca", "halifax": "ca",
            "winnipeg": "ca", "edmonton": "ca", "calgary": "ca", "ottawa": "ca",
            "washington": "us", "new_york": "us", "los_angeles": "us", "chicago": "us",

            // Mexico & Central America & Caribbean
            "mexico_city": "mx", "tijuana": "mx", "monterrey": "mx", "chihuahua": "mx", "mazatlan": "mx",
            "guatemala": "gt", "belize": "bz", "san_salvador": "sv", "tegucigalpa": "hn",
            "managua": "ni", "san_jose": "cr", "panama": "pa", "havana": "cu",
            "kingston": "jm", "port-au-prince": "ht", "santo_domingo": "do", "san_juan": "pr",
            "bridgetown": "bb", "port_of_spain": "tt", "st_georges": "gd", "roseau": "dm",
            "castries": "lc", "kingstown": "vc", "st_johns": "ag", "basseterre": "kn",

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
            "casablanca": "ma", "accra": "gh", "addis_ababa": "et", "tripoli": "ly",
            "tunis": "tn", "algiers": "dz", "khartoum": "sd", "juba": "ss",
            "mogadishu": "so", "djibouti": "dj", "asmara": "er", "kampala": "ug",
            "kigali": "rw", "bujumbura": "bi", "dar_es_salaam": "tz", "dodoma": "tz",
            "lusaka": "zm", "harare": "zw", "gaborone": "bw", "maseru": "ls",
            "mbabane": "sz", "maputo": "mz", "antananarivo": "mg", "moroni": "km",
            "victoria": "sc", "port_louis": "mu", "windhoek": "na", "luanda": "ao",
            "kinshasa": "cd", "brazzaville": "cg", "bangui": "cf", "ndjamena": "td",
            "libreville": "ga", "malabo": "gq", "sao_tome": "st", "praia": "cv",
            "bissau": "gw", "conakry": "gn", "freetown": "sl", "monrovia": "lr",
            "abidjan": "ci", "yamoussoukro": "ci", "bamako": "ml", "ouagadougou": "bf",
            "niamey": "ne", "porto-novo": "bj", "lome": "tg", "nouakchott": "mr",
            "dakar": "sn", "banjul": "gm",

            // Europe
            "london": "gb", "paris": "fr", "berlin": "de", "rome": "it",
            "madrid": "es", "amsterdam": "nl", "brussels": "be", "vienna": "at",
            "moscow": "ru", "kyiv": "ua", "kiev": "ua", "athens": "gr", "lisbon": "pt",
            "dublin": "ie", "copenhagen": "dk", "stockholm": "se", "oslo": "no",
            "helsinki": "fi", "warsaw": "pl", "prague": "cz", "budapest": "hu",
            "bucharest": "ro", "sofia": "bg", "zagreb": "hr", "ljubljana": "si",
            "bratislava": "sk", "vilnius": "lt", "riga": "lv", "tallinn": "ee",
            "minsk": "by", "chisinau": "md", "belgrade": "rs", "sarajevo": "ba",
            "skopje": "mk", "podgorica": "me", "tirane": "al", "valletta": "mt",
            "nicosia": "cy", "reykjavik": "is", "luxembourg": "lu", "monaco": "mc",
            "andorra": "ad", "san_marino": "sm", "vatican": "va", "zurich": "ch",

            // Pacific & Oceania
            "auckland": "nz", "guam": "gu", "fiji": "fj", "apiai": "ws", "kiritimati": "ki",
            "wellington": "nz", "sydney": "au", "melbourne": "au", "canberra": "au",
            "suva": "fj", "nuku_alofa": "to", "apia": "ws", "port_vila": "vu",
            "honiara": "sb", "port_moresby": "pg", "funafuti": "tv", "tarawa": "ki",
            "majuro": "mh", "palikir": "fm", "ngerulmud": "pw", "yaren": "nr"
        ]

        if let explicitCode = cityMap[city] {
            return explicitCode
        }

        // No fallback flags - return empty string if no explicit mapping exists
        return ""
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
        // Only try to load image if we have a valid country code
        if !countryCode.isEmpty, let image = NSImage(named: countryCode) {
            return image
        }
        return NSImage() // Return empty image if no country code or image not found
    }
} 
