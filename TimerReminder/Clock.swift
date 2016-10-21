import Foundation

class Clock: Timer {
    func reset() {
        
    }
    
    func start() {
        
    }
    
    func pause() {
        
    }
    
    var onTimerChange: ((Timer) -> Void)?
    var onEnd: ((Timer) -> Void)?
    
    var options: TimerOptions?
    
    let paused = true
    let ended = true
    
    let canBeSet = false
    let canCountDown = false
    
    var description: String = "" {
        didSet {
            if oldValue != description {
                onTimerChange?(self)
            }
        }
    }
    
    let formatter = DateFormatter()
    
    var timer: Foundation.Timer?
    
    init(options: TimerOptions? = nil, onTimerChange: ((Timer) -> Void)?) {
        self.options = options
        self.onTimerChange = onTimerChange
        formatter.dateFormat = "HH:mm"
        let date = Date()
        description = formatter.string(from: date)
        onTimerChange?(self)
        let secondsUntilMinute = 60 - (Calendar.current as NSCalendar).component(.second, from: date)
        if secondsUntilMinute != 0 {
            Foundation.Timer.runThisAfterDelay(seconds: Double(secondsUntilMinute)) {
                [weak self] in
                let date = Date()
                self?.description = (self?.formatter.string(from: date)) ?? ""
                if let myself = self {
                    myself.timer = Foundation.Timer.runThisEvery(seconds: 60) {
                        [weak self] t in
                        if self == nil {
                            self?.timer?.invalidate()
                        }
                        let date = Date()
                        self?.description = self?.formatter.string(from: date) ?? ""
                    }
                }
            }
        } else {
            self.timer = Foundation.Timer.runThisEvery(seconds: 60) {
                [weak self] t in
                if self == nil {
                    self?.timer?.invalidate()
                }
                let date = Date()
                self?.description = self?.formatter.string(from: date) ?? ""
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
