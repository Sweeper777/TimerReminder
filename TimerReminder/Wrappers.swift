import XLForm

class CountDownTimeWrapper: NSObject, XLFormOptionObject {
    private let innerValue: Int
    
    func formValue() -> AnyObject {
        return innerValue
    }
    
    func formDisplayText() -> String {
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

class TimeIsUpActionWrapper: NSObject, XLFormOptionObject {
    private let innerValue: String
    
    func formValue() -> AnyObject {
        return innerValue
    }
    
    func formDisplayText() -> String {
        return NSLocalizedString(innerValue, comment: "")
    }
    
    init(value: String) {
        innerValue = value
    }
    
    static let playSound = TimeIsUpActionWrapper(value: "Play a Sound")
    static let sayMessage = TimeIsUpActionWrapper(value: "Say a Message")
}

func ==(a: TimeIsUpActionWrapper, b: TimeIsUpActionWrapper) -> Bool {
    return a.innerValue == b.innerValue
}