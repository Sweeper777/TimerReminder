import RealmSwift

class ReminderObject : Object {
    @objc dynamic var remindTime = 0
    @objc dynamic var message: String? = nil
}

