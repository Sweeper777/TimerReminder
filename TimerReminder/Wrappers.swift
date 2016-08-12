import Eureka

class CountDownTimeWrapper: Equatable, CustomStringConvertible {
    let innerValue: Int
    
    var description: String {
        if innerValue == 0 {
            return NSLocalizedString("No Countdown", comment: "")
        } else {
            return "\(innerValue) \(NSLocalizedString("Seconds", comment: ""))"
        }
    }
    
    init(value: Int) {
        innerValue = value
    }
    
    static let noCountdown = CountDownTimeWrapper(value: 0)
    static let _3 = CountDownTimeWrapper(value: 3)
    static let _5 = CountDownTimeWrapper(value: 5)
    static let _10 = CountDownTimeWrapper(value: 10)
    static let _20 = CountDownTimeWrapper(value: 20)
    static let _30 = CountDownTimeWrapper(value: 30)
    static let _60 = CountDownTimeWrapper(value: 60)
}

class TimeIsUpActionWrapper: Equatable, CustomStringConvertible {
    let innerValue: String
    
    var description: String {
        return NSLocalizedString(innerValue, comment: "")
    }
    
    init(value: String) {
        innerValue = value
    }
    
    static let playSound = TimeIsUpActionWrapper(value: "Play a Sound")
    static let sayMessage = TimeIsUpActionWrapper(value: "Say a Message")
}

class ReminderStyleWrapper: Equatable, CustomStringConvertible {
    let innerValue: String
    
    var description: String {
        return NSLocalizedString(innerValue, comment: "")
    }
    
    init(value: String) {
        innerValue = value
    }
    
    static let regular = ReminderStyleWrapper(value: "Regular")
    static let atSpecificTimes = ReminderStyleWrapper(value: "At Specific Times")
}

func ==(lhs: TimeIsUpActionWrapper, rhs: TimeIsUpActionWrapper) -> Bool {
    return lhs.innerValue == rhs.innerValue
}

func ==(lhs: CountDownTimeWrapper, rhs: CountDownTimeWrapper) -> Bool {
    return lhs.innerValue == rhs.innerValue
}

func ==(lhs: ReminderStyleWrapper, rhs: ReminderStyleWrapper) -> Bool {
    return lhs.innerValue == rhs.innerValue
}