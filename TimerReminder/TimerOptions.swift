
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

struct Reminder {
    let remindTime: Int
    let message: String?
}

extension Reminder {
    init(reminderObject: ReminderObject) {
        self.init(remindTime: reminderObject.remindTime, message: reminderObject.message)
    }
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
    
    var fontName: String {
        switch self {
        case .thin:
            return "SFUIDisplay-Thin"
        case .regular:
            return "SFUIDisplay-Regular"
        case .light:
            return "SFUIDisplay-Light"
        case .ultralight:
            return "SFUIDisplay-Ultralight"
        case .bodoni72:
            return "Bodoni 72"
        case .chalkduster:
            return "Chalkduster"
        }
    }
}

struct TimerOptions {
    static let `default` = TimerOptions()
    
    let name: String
    let language: String
    let countDown: CountDownOption
    let countSeconds: Bool
    let beepSounds: Bool
    let vibrate: Bool
    let timeUpOption: TimeUpOption
    let reminderOption: ReminderOption
    let font: FontStyle
    let textAnimation: LTMorphingEffect
    
    init(name: String = "Default", language: String = "en-us",
         countDown: CountDownOption = .yes(startsAt: 10), countSeconds: Bool = false,
         beepSounds: Bool = false, vibrate: Bool = false,
         timeUpOption: TimeUpOption = .speakDefaultMessage,
         reminderOption: ReminderOption = .no,
         font: FontStyle = .regular, textAnimation: LTMorphingEffect = .scale) {
        self.name = name
        self.language = language
        self.countDown = countDown
        self.countSeconds = countSeconds
        self.beepSounds = beepSounds
        self.vibrate = vibrate
        self.timeUpOption = timeUpOption
        self.reminderOption = reminderOption
        self.font = font
        self.textAnimation = textAnimation
    }
}

extension TimerOptions {
    init(timerOptionsObject: TimerOptionsObject) {
        let timeUpOption: TimeUpOption
        let reminderOption: ReminderOption
        if timerOptionsObject.timeUpMessage == nil && timerOptionsObject.timeUpSound == nil {
            timeUpOption = .speakDefaultMessage
        } else if timerOptionsObject.timeUpMessage != nil {
            timeUpOption = .speak(timerOptionsObject.timeUpMessage!)
        } else {
            timeUpOption = .playSound(timerOptionsObject.timeUpSound!)
        }
        if timerOptionsObject.regularReminders {
            reminderOption = .regularInterval(Reminder(reminderObject: timerOptionsObject.reminders.first!))
        } else if timerOptionsObject.reminders.isEmpty {
            reminderOption = .no
        } else {
            reminderOption = .specificTimes(timerOptionsObject.reminders.map(Reminder.init))
        }
        self.init(
            name: timerOptionsObject.name,
            language: timerOptionsObject.language,
            countDown: timerOptionsObject.countDownTime.value.map(CountDownOption.yes(startsAt:)) ?? CountDownOption.no,
            countSeconds: timerOptionsObject.countSeconds,
            beepSounds: timerOptionsObject.beepSounds,
            vibrate: timerOptionsObject.vibrate,
            timeUpOption: timeUpOption,
            reminderOption: reminderOption,
            font: FontStyle(rawValue: timerOptionsObject.font)!,
            textAnimation: LTMorphingEffect(rawValue: timerOptionsObject.textAnimation)!
        )
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
            return NSLocalizedString("Mandarin", comment: "")
        case .cantonese:
            return NSLocalizedString("Cantonese", comment: "")
        case .japanese:
            return NSLocalizedString("Japanese", comment: "")
        case .english:
            return NSLocalizedString("English", comment: "")
        }
    }
}
