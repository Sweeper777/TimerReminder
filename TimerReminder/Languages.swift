import Foundation
import XLForm

enum Languages: String {
    case English = "en-us"
    case Mandarin = "zh-cn"
    case Cantonese = "zh-hk"
    case Japanese = "ja"
}

class LanguageWrapper: NSObject, XLFormOptionObject {
    var language: Languages
    
    init(language: Languages) {
        self.language = language
    }
    
    @objc func formValue() -> AnyObject {
        return language.rawValue
    }
    
    @objc func formDisplayText() -> String {
        switch language {
        case .Mandarin:
            return NSLocalizedString("Mandarin", comment: "")
        case .Cantonese:
            return NSLocalizedString("Cantonese", comment: "")
        case .Japanese:
            return NSLocalizedString("Japanese", comment: "")
        case .English:
            return NSLocalizedString("English", comment: "")
        }
    }
}

extension TimerOptions {
    var localizedTimesUpMessage: String {
        if let customMsg = self.timesUpMessage {
            return customMsg
        }
        
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese:
            return "時間到"
        case .Japanese:
            return "時間です"
        default:
            return "Time is up"
        }
    }
    
    var localizedSecond: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese, .Japanese:
            return "秒"
        default:
            return "Second"
        }
    }
    
    var localizedMinute: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese:
            return "分鐘"
        case .Japanese:
            return "分"
        default:
            return "Minute"
        }
    }
    
    var localizedHour: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese:
            return "小時"
        case .Japanese:
            return "時間"
        default:
            return "Hour"
        }
    }
    
    var localizedSeconds: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese, .Japanese:
            return "秒"
        default:
            return "Seconds"
        }
    }
    
    var localizedMinutes: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese:
            return "分鐘"
        case .Japanese:
            return "分"
        default:
            return "Minutes"
        }
    }
    
    var localizedHours: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese:
            return "小時"
        case .Japanese:
            return "時間"
        default:
            return "Hours"
        }
    }
    
    var localizedLeftFormat: String {
        switch Languages(rawValue: self.language!)! {
        case .Mandarin, .Cantonese:
            return "剩餘 %@"
        case .Japanese:
            return "残り時間 %@"
        default:
            return "%@ Left"
        }
    }
}