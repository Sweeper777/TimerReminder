
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
}

struct TimerOptions {
    static let `default` = TimerOptions()
    
    let name: String = "Default"
    let language: String = "en"
    let countDown: CountDownOption = .yes(startsAt: 10)
    let countSeconds: Bool = false
    let beepSounds: Bool = false
    let vibrate: Bool = false
    let timeUpOption: TimeUpOption = .speakDefaultMessage
    let reminderOption: ReminderOption = .no
    let font: FontStyle = .regular
    let textAnimation: LTMorphingEffect = .scale
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
