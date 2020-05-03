import RxSwift
import RxCocoa

class Timer {
    private enum Action { case pause, reset, tick }
    enum Mode {
        case countDown
        case countUp
        case clock
    }
    
    struct Event {
        let displayString: String
        let state: Int
        let reminder: Reminder?
        let beep: Bool
        let countDown: Bool
        let countSeconds: Bool
        let language: String
        let ended: Bool
        
        static let `default` = Event(displayString: "",
                                     state: 0,
                                     reminder: nil,
                                     beep: false,
                                     countDown: false,
                                     countSeconds: false,
                                     language: "",
                                     ended: false)
    }
    
    var options: TimerOptions
    let mode: Mode
    
    private init(options: TimerOptions, mode: Mode) {
        self.options = options
        self.mode = mode
    }
    
    static func newCountDownInstance(options: TimerOptions = .default) -> Timer {
        Timer(options: options, mode: .countDown)
    }
    
    static func newCountUpInstance(options: TimerOptions = .default) -> Timer {
        Timer(options: options, mode: .countUp)
    }
    
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
    
    func timerEvent(forState currentState: Int) -> Event {
        let displayString = self.displayString(forState: currentState)
        let reminder: Reminder?
        switch options.reminderOption {
        case .no:
            reminder = nil
        case .regularInterval(let r):
            reminder = currentState % r.remindTime == 0 ? r : nil
        case .specificTimes(let rs):
            reminder = rs.first(where: { $0.remindTime == currentState })
        }
        let beep = options.beepSounds
        let countDown: Bool
        let countSeconds = options.countSeconds && mode == .countUp
        let language = options.language
        switch mode {
        case .countDown:
            switch options.countDown {
            case .no:
                countDown = false
            case .yes(startsAt: let time):
                countDown = currentState <= time
            }
        case .countUp:
            countDown = false
        default:
            fatalError()
        }
        return Event(displayString: displayString,
                          state: currentState,
                          reminder: reminder,
                          beep: beep,
                          countDown: countDown,
                          countSeconds: countSeconds,
                          language: language,
                          ended: currentState <= 0 && mode == .countDown)
    }
    
    func events(initial: Int, pause: Observable<Void>, reset: Observable<Void>, scheduler: SchedulerType) -> Observable<Event> {
        switch mode {
        case .countDown:
            return countDownEvents(initial: initial, pause: pause, reset: reset, scheduler: scheduler)
        case .countUp:
            return countUpEvents(pause: pause, reset: reset, scheduler: scheduler)
        case .clock:
            fatalError()
        }
    }
    
    private func countDownEvents(initial: Int, pause: Observable<Void>, reset: Observable<Void>, scheduler: SchedulerType) -> Observable<Event> {
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
