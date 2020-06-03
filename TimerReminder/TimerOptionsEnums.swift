import UIKit
enum CountDownOption {
    case no
    case yes(startsAt: Int)
}

enum ReminderOption {
    case no
    case regularInterval(Reminder)
    case specificTimes([Reminder])
}

enum TimeUpOption {
    case speakDefaultMessage
    case speak(String)
    case playSound(String)
}

enum FontStyle: Int, CustomStringConvertible {
    case thin = 0
    case regular = 1
    case light = 2
    case ultralight = 3
    case bodoni72 = 4
    case chalkduster = 5
    
    var description: String {
        switch self {
        case .bodoni72:
            return "Bodoni 72"
        case .thin:
            return "Thin"
        case .regular:
            return "Regular"
        case .light:
            return "Light"
        case .ultralight:
            return "Ultralight"
        case .chalkduster:
            return "Chalkduster"
        }
    }
    
    var uiFont: UIFont {
        switch self {
        case .thin:
            return UIFont.systemFont(ofSize: 10, weight: .thin)
        case .regular:
            return UIFont.systemFont(ofSize: 10, weight: .regular)
        case .light:
            return UIFont.systemFont(ofSize: 10, weight: .light)
        case .ultralight:
            return UIFont.systemFont(ofSize: 10, weight: .ultraLight)
        case .bodoni72:
            return UIFont(name: "Bodoni 72", size: 10)!
        case .chalkduster:
            return UIFont(name: "Chalkduster", size: 10)!
        }
    }
}

enum CountDownTime: Int, CustomStringConvertible {
    
    var description: String {
        return "\(rawValue) \("Seconds".localised)"
    }
    
    case _3 = 3
    case _5 = 5
    case _10 = 10
    case _20 = 20
    case _30 = 30
    case _60 = 60
}

enum Languages: String, CustomStringConvertible {
    case english = "en-us"
    case mandarin = "zh-cn"
    case cantonese = "zh-hk"
    case japanese = "ja"
    
    var description: String {
        switch self {
        case .mandarin:
            return "Mandarin".localised
        case .cantonese:
            return "Cantonese".localised
        case .japanese:
            return "Japanese".localised
        case .english:
            return "English".localised
        }
    }
}
