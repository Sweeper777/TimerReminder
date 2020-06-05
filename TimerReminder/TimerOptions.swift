
import Foundation
import LTMorphingLabel

struct Reminder : Codable {
    let remindTime: Int
    let message: String?
}

extension Reminder {
    init(reminderObject: ReminderObject) {
        self.init(remindTime: reminderObject.remindTime, message: reminderObject.message)
    }
}

struct TimerOptions : Codable {
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
    var objectRef: TimerOptionsObject?
    
    init(name: String = "Default", language: String = "en-us",
         countDown: CountDownOption = .yes(startsAt: 10), countSeconds: Bool = false,
         beepSounds: Bool = false, vibrate: Bool = false,
         timeUpOption: TimeUpOption = .speakDefaultMessage,
         reminderOption: ReminderOption = .no,
         font: FontStyle = .regular, textAnimation: LTMorphingEffect = .scale,
         objectRef: TimerOptionsObject? = nil) {
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
        self.objectRef = objectRef
    }
    
    enum CodingKeys: CodingKey {
        case name
        case language
        case countDownTime
        case countSeconds
        case beepSounds
        case vibrate
        case font
        case textAnimation
        case timeUpMessage
        case timeUpSound
        case regularReminders
        case reminders
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(language, forKey: .language)
        if case .yes(let countDownTime) = countDown {
            try container.encode(countDownTime, forKey: .countDownTime)
        }
        try container.encode(countSeconds, forKey: .countSeconds)
        try container.encode(beepSounds, forKey: .beepSounds)
        try container.encode(vibrate, forKey: .vibrate)
        try container.encode(font.rawValue, forKey: .font)
        try container.encode(textAnimation.rawValue, forKey: .textAnimation)
        switch timeUpOption {
        case .playSound(let s):
            try container.encode(s, forKey: .timeUpSound)
        case .speak(let s):
            try container.encode(s, forKey: .timeUpMessage)
        case .speakDefaultMessage:
            break
        }
        switch reminderOption {
        case .regularInterval(let reminder):
            try container.encode(true, forKey: .regularReminders)
            try container.encode([reminder], forKey: .reminders)
        case .specificTimes(let reminders):
            try container.encode(false, forKey: .regularReminders)
            try container.encode(reminders, forKey: .reminders)
        case .no:
            try container.encode(false, forKey: .regularReminders)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        language = try container.decode(String.self, forKey: .language)
        countDown = (try container.decodeIfPresent(Int.self, forKey: .countDownTime)).map { .yes(startsAt: $0) } ?? .no
        countSeconds = try container.decode(Bool.self, forKey: .countSeconds)
        beepSounds = try container.decode(Bool.self, forKey: .beepSounds)
        vibrate = try container.decode(Bool.self, forKey: .vibrate)
        font = FontStyle(rawValue: try container.decode(Int.self, forKey: .font))!
        textAnimation = LTMorphingEffect(rawValue: try container.decode(Int.self, forKey: .textAnimation))!
        if let sound = try container.decodeIfPresent(String.self, forKey: .timeUpSound) {
            timeUpOption = .playSound(sound)
        } else if let message = try container.decodeIfPresent(String.self, forKey: .timeUpMessage) {
            timeUpOption = .speak(message)
        } else {
            timeUpOption = .speakDefaultMessage
        }
        if try container.decode(Bool.self, forKey: .regularReminders) {
            reminderOption = .regularInterval((try container.decode([Reminder].self, forKey: .reminders))[0])
        } else if let reminders = try container.decodeIfPresent([Reminder].self, forKey: .reminders) {
            reminderOption = .specificTimes(reminders)
        } else {
            reminderOption = .no
        }
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
            textAnimation: LTMorphingEffect(rawValue: timerOptionsObject.textAnimation)!,
            objectRef: timerOptionsObject
        )
    }
}

extension TimerOptions {
    mutating func synchroniseWithRealmObject() {
        objectRef.map { self = TimerOptions(timerOptionsObject: $0) }
    }
}
