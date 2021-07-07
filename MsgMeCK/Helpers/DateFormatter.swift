
import Foundation

extension Date {
    
    //    DateFormatter() has 5 format style options for each of Date and Time. These are:
    //    .none .short .medium .long .full
    //
    //     DATE      TIME     DATE/TIME STRING
    //    "none"    "none"
    //    "none"    "short"   9:42 AM
    //    "none"    "medium"  9:42:27 AM
    //    "none"    "long"    9:42:27 AM EDT
    //    "none"    "full"    9:42:27 AM Eastern Daylight Time
    //    "short"   "none"    10/10/17
    //    "short"   "short"   10/10/17, 9:42 AM
    //    "short"   "medium"  10/10/17, 9:42:27 AM
    //    "short"   "long"    10/10/17, 9:42:27 AM EDT
    //    "short"   "full"    10/10/17, 9:42:27 AM Eastern Daylight Time
    //    "medium"  "none"    Oct 10, 2017
    //    "medium"  "short"   Oct 10, 2017, 9:42 AM
    //    "medium"  "medium"  Oct 10, 2017, 9:42:27 AM
    //    "medium"  "long"    Oct 10, 2017, 9:42:27 AM EDT
    //    "medium"  "full"    Oct 10, 2017, 9:42:27 AM Eastern Daylight Time
    //    "long"    "none"    October 10, 2017
    //    "long"    "short"   October 10, 2017 at 9:42 AM
    //    "long"    "medium"  October 10, 2017 at 9:42:27 AM
    //    "long"    "long"    October 10, 2017 at 9:42:27 AM EDT
    //    "long"    "full"    October 10, 2017 at 9:42:27 AM Eastern Daylight Time
    //    "full"    "none"    Tuesday, October 10, 2017
    //    "full"    "short"   Tuesday, October 10, 2017 at 9:42 AM
    //    "full"    "medium"  Tuesday, October 10, 2017 at 9:42:27 AM
    //    "full"    "long"    Tuesday, October 10, 2017 at 9:42:27 AM EDT
    //    "full"    "full"    Tuesday, October 10, 2017 at 9:42:27 AM Eastern Daylight Time
    
    //    Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
    //    09/12/2018                        --> MM/dd/yyyy
    //    09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
    //    Sep 12, 2:11 PM                   --> MMM d, h:mm a
    //    September 2018                    --> MMMM yyyy
    //    Sep 12, 2018                      --> MMM d, yyyy
    //    Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
    //    2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
    //    12.09.18                          --> dd.MM.yy
    //    10:41:02.112                      --> HH:mm:ss.SSS
    
    enum DateFormatType: String {
        case full = "EEEE, MMM d, yyyy"
        case fullNumeric = "MM/dd/yyyy"
        case fullNumericTimestamp = "MM-dd-yyyy HH:mm"
        case MM_dd_yyyy_T_HH_mm_ss_SSS_Z = "MM-dd-yyyy'T'HH:mm:ss:SSSZ"
        case monthDayTimestamp = "MMM d, h:mm a"
        case monthDayYearTimestamp = "MMM d, yyyy, h:mm a"
        case monthYear = "MMMM yyyy"
        case monthDayYear = "MMM d, yyyy"
        case fullWithTimezone = "E, d MMM yyyy HH:mm:ss Z"
        case fullNumericWithTimezone = "yyyy-MM-dd'T'HH:mm:ssZ"
        case short = "dd.MM.yy"
        case timestamp = "HH:mm:ss.SSS"
        case dbSafeTimestamp = "HH-mm-ss-SSS"
    }
    
    func convertToUTCString(format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
    
    func dateToString(format: DateFormatType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}    //  End of Extension

extension String {
    enum DateFormatType: String {
        case EEEE_MMM_d_yyyy = "EEEE, MMM d, yyyy"
        case MM_dd_yyyy = "MM/dd/yyyy"
        case MM_dd_yyyy_T_HH_mm_ss_SSS_Z = "MM-dd-yyyy'T'HH:mm:ss:SSSZ"
        case monthDayTimestamp = "MMM d, h:mm a"
        case monthDayYearTimestamp = "MMM d, yyyy, h:mm a"
        case monthYear = "MMMM yyyy"
        case monthDayYear = "MMM d, yyyy"
        case fullWithTimezone = "E, d MMM yyyy HH:mm:ss Z"
        case fullNumericWithTimezone = "yyyy-MM-dd'T'HH:mm:ssZ"
        case short = "dd.MM.yy"
        case timestamp = "HH:mm:ss.SSS"
        case dbSafeTimestamp = "HH-mm-ss-SSS"
    }
    
    func stringToDate(format: DateFormatType) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        
        let date: Date? = formatter.date(from: self)
        
        return date
    }
    
    func stringToLocalDate(format: DateFormatType) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = .current
        
        let date: Date? = formatter.date(from: self)
        
        return date
    }
}    //  End of Extension
