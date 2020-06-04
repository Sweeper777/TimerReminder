import RealmSwift

class TimerOptionsManager {
    private let timerOptions: Results<TimerOptionsObject>
    private let realm: Realm!
    var allTimerOptions: [TimerOptions] {
        Array(timerOptions).map(TimerOptions.init(timerOptionsObject:))
    }
    private init() {
        do {
            realm = try Realm()
            timerOptions = realm.objects(TimerOptionsObject.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }
    
    private static var _shared: TimerOptionsManager?
    
    static var shared: TimerOptionsManager {
        _shared = _shared ?? TimerOptionsManager()
        return _shared!
    }
    
    func addTimerOptions(_ timerOptions: inout TimerOptions) throws {
        try realm.write {
            let timerOptionsObject = TimerOptionsObject(timerOptions: timerOptions)
            realm.add(timerOptionsObject)
            timerOptions.objectRef = timerOptionsObject
        }
    }
    
    func queryTimerOptions(_ query: String, args: Any...) -> [TimerOptions] {
        realm.objects(TimerOptionsObject.self).filter(NSPredicate(format: query, argumentArray: args))
            .map(TimerOptions.init(timerOptionsObject:))
    }
    
    func deleteTimerOptions(_ timerOptions: TimerOptions) throws {
        if let obj = timerOptions.objectRef {
            try realm.write {
                realm.delete(obj.reminders)
                realm.delete(obj)
            }
        }
    }
    
    func updateTimerOptions(from oldTimerOptions: TimerOptions, to newTimerOptions: inout TimerOptions) throws {
        guard let obj = oldTimerOptions.objectRef else { return }
        try realm.write {
            realm.delete(obj.reminders)
            let newObj = TimerOptionsObject(timerOptions: newTimerOptions)
            realm.add(newObj.reminders)
            obj.name = newObj.name
            obj.language = newObj.language
            obj.countDownTime.value = newObj.countDownTime.value
            obj.countSeconds = newObj.countSeconds
            obj.beepSounds = newObj.beepSounds
            obj.vibrate = newObj.vibrate
            obj.font = newObj.font
            obj.textAnimation = newObj.textAnimation
            obj.timeUpMessage = newObj.timeUpMessage
            obj.timeUpSound = newObj.timeUpSound
            obj.regularReminders = newObj.regularReminders
        }
    }
}
