import Eureka

enum CountDownTime: Int, CustomStringConvertible {
    
    var description: String {
        return "\(rawValue) \(NSLocalizedString("Seconds", comment: ""))"
    }
    
    case _3 = 3
    case _5 = 5
    case _10 = 10
    case _20 = 20
    case _30 = 30
    case _60 = 60
}

enum TimeIsUpAction: String, CustomStringConvertible {
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    case PlaySound = "Play a Sound"
    case SayMessage = "Verbalize a Message"
}

enum ReminderStyle: String, CustomStringConvertible {
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    case Regular = "Regular"
    case AtSpecificTimes = "At Specific Times"
}

enum FontStyle: Int, CustomStringConvertible {
    case Thin = 0
    case Regular = 1
    case Light = 2
    case Ultralight = 3
    case Bodoni72 = 4
    case Chalkduster = 5
    
    var description: String {
        switch self {
        case .Bodoni72:
            return "Bodoni 72"
        case .Thin:
            return "Thin"
        case .Regular:
            return "Regular"
        case .Light:
            return "Light"
        case .Ultralight:
            return "Ultralight"
        case .Chalkduster:
            return "Chalkduster"
        }
    }
}
