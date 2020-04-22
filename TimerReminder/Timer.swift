import RxSwift
import RxCocoa

enum TimerMode {
    case countDown
    case countUp
    case clock
}

class Timer {
    var paused = true
    var ended = false
    var options: TimerOptions
    let mode: TimerMode
    
    
    private var currentState: Int
    private let resetState: Int
    
    private let observable: Observable<Int>
    
    private init(options: TimerOptions, mode: TimerMode, currentState: Int, resetState: Int, observable: Observable<Int>) {
        self.options = options
        self.mode = mode
        self.currentState = currentState
        self.resetState = resetState
        self.observable = observable
    }
    
    static func newCountDownInstance(countDownTime: Int, options: TimerOptions = .default) -> Timer {
        Timer(options: options,
              mode: .countDown,
              currentState: countDownTime,
              resetState: countDownTime,
              observable: Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .map { _ in return 0 })
    }
    
    var timerEvents: Observable<TimerEvent> {
        Observable.create { (observer) in
            self.observable.subscribe { (event) in
                if self.paused || self.ended {
                    return
                }
                
                switch event {
                case .next:
                    switch self.mode {
                    case .countDown:
                        self.currentState -= 1
                        if self.currentState == 0 {
                            self.ended = true
                        }
                        observer.onNext(self.currentTimerEvent)
                    default:
                        fatalError()
                    }
                default:
                    observer.onCompleted()
                    self.ended = true
                }
            }
        }
    }
    
    var currentTimerEvent: TimerEvent {
        let displayString: String
        let reminder: Reminder?
        let beep = options.beepSounds
        let countDown: Bool
        let countSeconds = options.countSeconds
        let language = options.language
        switch mode {
        case .countDown:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en")
            formatter.timeZone = TimeZone(identifier: "UTC")
            if currentState < 60 * 60 {
                formatter.dateFormat = "mm:ss"
            } else {
                formatter.dateFormat = "HH:mm:ss"
            }
            displayString = formatter.string(from: Date(timeIntervalSince1970: Double(currentState)))
            switch options.reminderOption {
            case .no:
                reminder = nil
            case .regularInterval(let r):
                reminder = currentState % r.remindTime == 0 ? r : nil
            case .specificTimes(let rs):
                reminder = rs.first(where: { $0.remindTime == currentState })
            }
            switch options.countDown {
            case .no:
                countDown = false
            case .yes(startsAt: let time):
                countDown = currentState <= time
            }
            return TimerEvent(displayString: displayString, state: currentState, reminder: reminder, beep: beep, countDown: countDown, countSeconds: countSeconds, language: language, ended: ended)
        default:
            fatalError()
        }
    }
    
}

struct TimerEvent {
    let displayString: String
    let state: Int
    let reminder: Reminder?
    let beep: Bool
    let countDown: Bool
    let countSeconds: Bool
    let language: String
    let ended: Bool
}
