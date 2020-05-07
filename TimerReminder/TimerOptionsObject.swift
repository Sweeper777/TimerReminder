import RealmSwift

class ReminderObject : Object {
    @objc dynamic var remindTime = 0
    @objc dynamic var message: String? = nil
    
    init(reminder: Reminder) {
        super.init()
        remindTime = reminder.remindTime
        message = reminder.message
    }
    
    required init() {
        super.init()
    }
}

class TimerOptionsObject : Object {
    @objc dynamic var name = "Default"
    @objc dynamic var language = "en"
    let countDownTime = RealmOptional<Int>(10)
    @objc dynamic var countSeconds = false
    @objc dynamic var beepSounds = false
    @objc dynamic var vibrate = false
    @objc dynamic var font = 1
    @objc dynamic var textAnimation = 0
    @objc dynamic var timeUpMessage: String? = nil
    @objc dynamic var timeUpSound: String? = nil
    @objc dynamic var regularReminders = false
    let reminders = List<ReminderObject>()
    
    init(timerOptions: TimerOptions) {
        super.init()
        name = timerOptions.name
        language = timerOptions.language
        switch timerOptions.countDown {
        case .no:
            countDownTime.value = nil
        case .yes(startsAt: let x):
            countDownTime.value = x
        }
        countSeconds = timerOptions.countSeconds
        beepSounds = timerOptions.beepSounds
        vibrate = timerOptions.vibrate
        font = timerOptions.font.rawValue
        textAnimation = timerOptions.textAnimation.rawValue
        switch timerOptions.timeUpOption {
        case .playSound(let s):
            timeUpSound = s
        case .speak(let s):
            timeUpMessage = s
        case .speakDefaultMessage:
            break
        }
        
        switch timerOptions.reminderOption {
        case .regularInterval(let reminder):
            regularReminders = true
            reminders.append(ReminderObject(reminder: reminder))
        case .specificTimes(let reminders):
            regularReminders = false
            self.reminders.append(objectsIn: reminders.map(ReminderObject.init))
        case .no:
            break
        }
    }
    
    required init() {
        super.init()
    }
}
