import AVFoundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CountUpTimer: Timer {
    var beepSoundPlayer: AVAudioPlayer?
    var timeMeasured: TimeInterval
    var timer: Foundation.Timer?
    var paused = true
    var onEnd: ((Timer) -> Void)?
    var onTimerChange: ((Timer) -> Void)?
    
    let synthesizer = AVSpeechSynthesizer()
    
    var options: TimerOptions? {
        didSet {
            guard let enableBeep = options?.beepSounds?.boolValue else {
                return
            }
            
            if enableBeep && beepSoundPlayer == nil {
                beepSoundPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "beep", withExtension: ".mp3")!)
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
        synthesizer.stopSpeaking(at: .immediate)
        onTimerChange?(self)
    }
    
    func start() {
        timer = Foundation.Timer.every(1) {
            [unowned self] _ in
            self.timeMeasured += 1
            
            let enableBeep = self.options?.beepSounds?.boolValue
            let counting = self.options?.counting?.boolValue
            let shouldRemind = self.shouldInvokeReminder()
            
            if shouldRemind.should {
                if shouldRemind.customMessage == nil {
                    let utterance = AVSpeechUtterance(string: normalize(timeInterval: self.timeMeasured, with: self.options!))
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
                } else {
                    let remindMessage = shouldRemind.customMessage!.replacingOccurrences(of: "$TIMEELAPSED$", with: normalize(timeInterval: self.timeMeasured, with: self.options!))
                    let utterance = AVSpeechUtterance(string: remindMessage)
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
                }
            } else if counting == true {
                let utterance = AVSpeechUtterance(string: Int(self.timeMeasured) % 60 == 0 ? normalize(timeInterval: self.timeMeasured) : String(Int(self.timeMeasured) % 60))
                utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                utterance.rate = AVSpeechUtteranceMaximumSpeechRate * 0.61
                self.synthesizer.stopSpeaking(at: .immediate)
                self.synthesizer.speak(utterance)
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
        synthesizer.stopSpeaking(at: .immediate)
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
    
    fileprivate func setTimerOptions(_ options: TimerOptions) {
        self.options = options
    }
    
    fileprivate func shouldInvokeReminder() -> (should: Bool, customMessage: String?) {
        if options?.reminders?.count > 0 {
            if let specificReminders = options?.reminders {
                let reminders = specificReminders.map { Int(($0 as! Reminder).remindTimeFrame!) }
                let should = reminders.contains(Int(timeMeasured))
                if should {
                    let index = reminders.index(of: Int(timeMeasured))
                    let message = (specificReminders.array[index!] as! Reminder).customRemindMessage
                    return (should, message)
                }
                return (should, nil)
            }
        }
        
        if let regularReminders = options?.regularReminderInterval {
            return (Int(timeMeasured) % Int(regularReminders) == 0, options?.regularReminderMessage)
        }
        
        return (false, nil)
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
