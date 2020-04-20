
import Foundation
import LTMorphingLabel

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
}

