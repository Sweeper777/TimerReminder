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
    
}
