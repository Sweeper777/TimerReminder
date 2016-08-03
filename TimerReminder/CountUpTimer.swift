import AVFoundation

class CountUpTimer: Timer {
    var beepSoundPlayer: AVAudioPlayer?
    var timeMeasured: NSTimeInterval
    var timer: NSTimer?
    var paused = true
    var onEnd: ((Timer) -> Void)?
    var onTimerChange: ((Timer) -> Void)?
    
    var options: TimerOptions? {
        didSet {
            guard let enableBeep = options?.beepSounds?.boolValue else {
                return
            }
            
            if enableBeep && beepSoundPlayer == nil {
                beepSoundPlayer = try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("beep", withExtension: ".mp3")!)
                beepSoundPlayer?.prepareToPlay()
            }
        }
    }
    
    let canCountDown = false
    let canBeSet = false
    
    var ended: Bool {
        return false
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        timeMeasured = 0
        paused = true
        onTimerChange?(self)
    }
    
    func start() {
        timer = NSTimer.runThisEvery(seconds: 1) {
            _ in
            self.timeMeasured += 1
            
            if let enableBeep = self.options?.beepSounds?.boolValue {
                if enableBeep {
                    self.beepSoundPlayer?.play()
                }
            }
            
            self.onTimerChange?(self)
        }
        self.paused = false
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        paused = true
    }
    
    var description: String {
        get {
            let intInterval = Int(timeMeasured)
            if timeMeasured <= 3600 {
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
    
    private func setTimerOptions(options: TimerOptions) {
        self.options = options
    }
    
    init(options: TimerOptions? = nil, onTimerChange: ((Timer) -> Void)?) {
        self.timeMeasured = 0
        self.onEnd = nil
        self.onTimerChange = onTimerChange
        self.setTimerOptions(options ?? TimerOptions.defaultOptions)
        onTimerChange?(self)
    }
    
    deinit {
        timer?.invalidate()
    }
}