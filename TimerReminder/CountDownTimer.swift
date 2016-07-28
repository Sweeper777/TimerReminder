import Foundation

class CountDownTimer: Timer {
    var timeLeft: NSTimeInterval
    let timeToMeasure: NSTimeInterval
    var timer: NSTimer?
    
    func reset() {
        timer?.invalidate()
        timer = nil
        timeLeft = timeToMeasure
        paused = true
        onTimerChange?(self)
    }
    
    func start() {
        if timeLeft <= 0 {
            return
        }
        
        timer = NSTimer.runThisEvery(seconds: 1) {
            _ in
            self.timeLeft -= 1
            self.onTimerChange?(self)
            if self.timeLeft <= 0 {
                self.onEnd?(self)
                self.paused = true
                self.timer?.invalidate()
            }
        }
        self.paused = false
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        paused = true
    }
    
    var paused = true
    
    var onEnd: ((Timer) -> Void)?
    var onTimerChange: ((Timer) -> Void)?
    
    var description: String {
        get {
            let intInterval = Int(timeLeft)
            if timeToMeasure <= 3600 {
                let minutes = intInterval / 60
                let seconds = intInterval % 60
                let paddedMinutes = minutes.description.padLeft(character: "0", length: 2)
                let paddedSeconds = seconds.description.padLeft(character: "0", length: 2)
                return "\(paddedMinutes):\(paddedSeconds)"
            } else {
                let hours = intInterval / 60 / 60
                let minutes = intInterval % 3600 / 60
                let seconds = intInterval % 60
                
                let paddedHours = hours.description.padLeft(character: "0", length: 2)
                let paddedMinutes = minutes.description.padLeft(character: "0", length: 2)
                let paddedSeconds = seconds.description.padLeft(character: "0", length: 2)
                return "\(paddedHours):\(paddedMinutes):\(paddedSeconds)"
            }
        }
    }
    
    init(time: NSTimeInterval, onTimerChange: ((Timer) -> Void)?, onEnd: ((Timer) -> Void)?) {
        self.timeLeft = time
        self.timeToMeasure = time
        self.onEnd = onEnd
        self.onTimerChange = onTimerChange
        onTimerChange?(self)
    }
    
    deinit {
        timer?.invalidate()
    }
}

extension String {
    func padLeft(character character: Character, length: Int) -> String {
        if self.length < length {
            let characterToAdd = length - self.length
            let string = String(count: characterToAdd, repeatedValue: character)
            return string + self
        }
        return self
    }
}