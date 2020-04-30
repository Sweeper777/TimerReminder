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
    
    var currentTimerEvent: TimerEvent {
        timerEvent(forState: currentState)
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
            return TimerEvent(displayString: displayString, state: currentState, reminder: reminder, beep: beep, countDown: countDown, countSeconds: countSeconds, language: language)
        default:
            fatalError()
        }
    }
    
    func reset() {
        ended = false
        currentState = resetState
        pause()
        switch mode {
        case .countDown:
            timerEvents = rxPaused.asObservable()
                .flatMapLatest {  isRunning in
                    isRunning ? .empty() : Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                }
                .enumerated().flatMap { (index, int) in Observable.just(index) }
            .map { [weak self] x in (self?.timerEvent(forState: (self?.resetState ?? x) - x) ?? .default) }
                .take(self.resetState)
            timerEvents.subscribe(onNext: { [weak self]
                timerEvent in
                self?.currentState -= 1
                }, onCompleted: {
                    [weak self] in
                    self?.ended = true
            }).disposed(by: disposeBag)
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
    
    static let `default` = TimerEvent(displayString: "", state: 0, reminder: nil, beep: false, countDown: false, countSeconds: false, language: "")
}
