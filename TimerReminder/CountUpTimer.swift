import AVFoundation
import MVSpeechSynthesizer

class CountUpTimer: Timer {
    var beepSoundPlayer: AVAudioPlayer?
    var timeMeasured: NSTimeInterval
    var timer: NSTimer?
    var paused = true
    var onEnd: ((Timer) -> Void)?
    var onTimerChange: ((Timer) -> Void)?
    
    let synthesizer = AVSpeechSynthesizer()
    let mvSynthesizer = MVSpeechSynthesizer()
    
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
            
            let enableBeep = self.options?.beepSounds?.boolValue
            let shouldRemind = self.shouldInvokeReminder()
            
            if shouldRemind.should {
                if shouldRemind.customMessage == nil {
                    let utteranceString = String(format: NSLocalizedString("%@ passed", comment: ""), self.timeMeasured.normalized())
                    let utterance = AVSpeechUtterance(string: utteranceString)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-us")
                    self.synthesizer.stopSpeakingAtBoundary(.Immediate)
                    self.synthesizer.speakUtterance(utterance)
                } else {
                    self.mvSynthesizer.stopReading()
                    self.mvSynthesizer.speechString = shouldRemind.customMessage!
                    self.mvSynthesizer.startRead()
                }
            } else if enableBeep == true {
                self.beepSoundPlayer?.play()
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
    
    private func shouldInvokeReminder() -> (should: Bool, customMessage: String?) {
        if options?.reminders?.count > 0 {
            if let specificReminders = options?.reminders {
                let reminders = specificReminders.map { Int(($0 as! Reminder).remindTimeFrame!) }
                let should = reminders.contains(Int(timeMeasured))
                if should {
                    let index = reminders.indexOf(Int(timeMeasured))
                    let message = (specificReminders.array[index!] as! Reminder).customRemindMessage
                    return (should, message)
                }
                return (should, nil)
            }
        }
        
        if let regularReminders = options?.regularReminderInterval {
            return (Int(timeMeasured) % Int(regularReminders) == 0, nil)
        }
        
        return (false, nil)
    }
    
    init(options: TimerOptions? = nil, onTimerChange: ((Timer) -> Void)?) {
        self.timeMeasured = 0
        self.onEnd = nil
        self.onTimerChange = onTimerChange
        self.setTimerOptions(options ?? TimerOptions.defaultOptions)
        self.mvSynthesizer.uRate = CGFloat(AVSpeechUtteranceDefaultSpeechRate)
        self.mvSynthesizer.pitchMultiplier = 1
        onTimerChange?(self)
    }
    
    deinit {
        timer?.invalidate()
    }
}