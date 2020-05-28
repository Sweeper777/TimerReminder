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
    
}
