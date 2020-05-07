import RealmSwift

class ReminderObject : Object {
    @objc dynamic var remindTime = 0
    @objc dynamic var message: String? = nil
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
    
}
