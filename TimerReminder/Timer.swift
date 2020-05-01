import RxSwift
import RxCocoa

enum TimerMode {
    case countDown
    case countUp
    case clock
}

class Timer {
    var options: TimerOptions
    let mode: TimerMode
    
    private init(options: TimerOptions, mode: TimerMode) {
        self.options = options
        self.mode = mode
    }
    
    static func newCountDownInstance(options: TimerOptions = .default) -> Timer {
        Timer(options: options,
              mode: .countDown)
    }
    
//        Observable<TimerEvent>.create { [weak self] (observer) in
//            guard let `self` = self else { return Disposables.create() }
//            return self.observable.subscribe { [weak self] (event) in
//                guard let `self` = self else { return }
//                if self.paused || self.ended {
//                    return
//                }
//
//                switch event {
//                case .next:
//                    switch self.mode {
//                    case .countDown:
//                        self.currentState -= 1
//                        if self.currentState == 0 {
//                            self.ended = true
//                        }
//                        observer.onNext(self.currentTimerEvent)
//                    default:
//                        fatalError()
//                    }
//                default:
//                    observer.onCompleted()
//                    self.ended = true
//                }
//            }
//        }
    
    func displayString(forState currentState: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.timeZone = TimeZone(identifier: "UTC")
        if currentState < 60 * 60 {
            formatter.dateFormat = "mm:ss"
        } else {
            formatter.dateFormat = "HH:mm:ss"
        }
        return formatter.string(from: Date(timeIntervalSince1970: Double(currentState)))
    }
    
    func timerEvent(forState currentState: Int) -> TimerEvent {
        let displayString: String
        let reminder: Reminder?
        let beep = options.beepSounds
        let countDown: Bool
        let countSeconds = options.countSeconds
        let language = options.language
        switch mode {
        case .countDown:
            displayString = self.displayString(forState: currentState)
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
            return TimerEvent(displayString: displayString, state: currentState, reminder: reminder, beep: beep, countDown: countDown, countSeconds: countSeconds, language: language, ended: currentState <= 0)
        default:
            fatalError()
        }
    }
    
    func timerEvents(initial: Int, pause: Observable<Void>, reset: Observable<Void>, scheduler: SchedulerType) -> Observable<TimerEvent> {
        enum Action { case pause, reset, tick }
        let intent = Observable.merge(
            pause.map { Action.pause },
            reset.map { Action.reset }
        )

        let isPaused = intent
            .scan(true) { isPaused, action in
                switch action {
                case .pause:
                    return !isPaused
                case .reset:
                    return true
                case .tick:
                    fatalError()
                }
            }
            .startWith(true)

        let tick = isPaused
            .flatMapLatest { $0 ? .empty() : Observable<Int>.interval(.seconds(1), scheduler: scheduler) }

        return Observable.merge(tick.map { _ in Action.tick }, reset.map { Action.reset })
            .scan(initial) { (current, action) -> Int in
                switch action {
                case .pause:
                    fatalError()
                case .reset:
                    return initial
                case .tick:
                    return current == -1 ? -1 : current - 1
                }

            }
            .filter { 0 <= $0 && $0 <= initial }
            .map {
                [weak self] x in
                self?.timerEvent(forState: x) ?? .default
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
    
    static let `default` = TimerEvent(displayString: "", state: 0, reminder: nil, beep: false, countDown: false, countSeconds: false, language: "", ended: false)
}
