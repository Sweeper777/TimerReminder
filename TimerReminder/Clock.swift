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
    
    let formatter = NSDateFormatter()
    
    var timer: NSTimer?
    
    init(options: TimerOptions? = nil, onTimerChange: ((Timer) -> Void)?) {
        self.options = options
        self.onTimerChange = onTimerChange
        formatter.dateFormat = "hh:mm"
        let date = NSDate()
        description = formatter.stringFromDate(date)
        let secondsUntilMinute = 60 - NSCalendar.currentCalendar().component(.Second, fromDate: date)
        if secondsUntilMinute != 0 {
            NSTimer.runThisAfterDelay(seconds: Double(secondsUntilMinute)) {
                [weak self] in
                let date = NSDate()
                self?.description = (self?.formatter.stringFromDate(date)) ?? ""
                if let myself = self {
                    myself.timer = NSTimer.runThisEvery(seconds: 60) {
                        [weak self] t in
                        if self == nil {
                            t.invalidate()
                        }
                        let date = NSDate()
                        self?.description = self?.formatter.stringFromDate(date) ?? ""
                    }
                }
            }
        } else {
            self.timer = NSTimer.runThisEvery(seconds: 60) {
                [weak self] t in
                if self == nil {
                    t.invalidate()
                }
                let date = NSDate()
                self?.description = self?.formatter.stringFromDate(date) ?? ""
            }
        }
    }
}