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
    
}
