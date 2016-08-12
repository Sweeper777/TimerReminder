import AVFoundation

class CountDownTimer: Timer {
    var beepSoundPlayer: AVAudioPlayer?
    var timeLeft: NSTimeInterval
    let timeToMeasure: NSTimeInterval
    let synthesizer = AVSpeechSynthesizer()
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
    
    let canCountDown = true
    let canBeSet = true
    
    var ended: Bool {
        return timeLeft <= 0
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        timeLeft = timeToMeasure
        paused = true
        onTimerChange?(self)
    }
    
    func start() {
        if ended {
            return
        }
        
        timer = NSTimer.runThisEvery(seconds: 1) {
            [unowned self]
            _ in
            self.timeLeft -= 1
            
            let enableBeep = self.options?.beepSounds?.boolValue
            let shouldRemind = self.shouldInvokeReminder()
            
            if self.timeLeft <= 0 {
                // time's up
                let utterance = AVSpeechUtterance(string: self.options!.localizedTimesUpMessage)
                utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                self.synthesizer.stopSpeakingAtBoundary(.Immediate)
                self.synthesizer.speakUtterance(utterance)
            } else if Int(self.timeLeft) <= Int(self.options!.countDownTime!) {
                // countdown
                let utterance = AVSpeechUtterance(string: String(Int(self.timeLeft)))
                utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                self.synthesizer.stopSpeakingAtBoundary(.Immediate)
                self.synthesizer.speakUtterance(utterance)
            } else if shouldRemind.should {
                // remind
                if shouldRemind.customMessage == nil {
                    let utteranceString = String(format: self.options!.localizedLeftFormat, normalize(timeInterval: self.timeLeft, with: self.options!))
                    let utterance = AVSpeechUtterance(string: utteranceString)
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeakingAtBoundary(.Immediate)
                    self.synthesizer.speakUtterance(utterance)
                } else {
                    // custom message
                    let utterance = AVSpeechUtterance(string: shouldRemind.customMessage!)
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeakingAtBoundary(.Immediate)
                    self.synthesizer.speakUtterance(utterance)
                }
            } else if enableBeep == true {
                self.beepSoundPlayer?.play()
            }
            
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
    
    private func setTimerOptions(options: TimerOptions) {
        self.options = options
    }
    
    private func shouldInvokeReminder() -> (should: Bool, customMessage: String?) {
        if options?.reminders?.count > 0 {
            if let specificReminders = options?.reminders {
                let reminders = specificReminders.map { Int(($0 as! Reminder).remindTimeFrame!) }
                let should = reminders.contains(Int(timeLeft))
                if should {
                    let index = reminders.indexOf(Int(timeLeft))
                    let message = (specificReminders.array[index!] as! Reminder).customRemindMessage
                    return (should, message)
                }
                return (should, nil)
            }
        }
        
        if let regularReminders = options?.regularReminderInterval {
            return (Int(timeToMeasure - timeLeft) % Int(regularReminders) == 0, nil)
        }
        
        return (false, nil)
    }
    
    init(time: NSTimeInterval, options: TimerOptions? = nil, onTimerChange: ((Timer) -> Void)?, onEnd: ((Timer) -> Void)?) {
        self.timeLeft = time
        self.timeToMeasure = time
        self.onEnd = onEnd
        self.onTimerChange = onTimerChange
        self.setTimerOptions(options ?? TimerOptions.defaultOptions)
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

func normalize(timeInterval timeInterval: NSTimeInterval, with options: TimerOptions) -> String {
    let hours = Int(timeInterval) % 86400 / 60 / 60
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    
    var normalized = ""
    
    if hours == 1 {
        normalized += "\(hours) \(options.localizedHour) "
    } else if hours != 0 {
        normalized += "\(hours) \(options.localizedHours) "
    }
    
    if minutes == 1 {
        normalized += "\(minutes) \(options.localizedMinute) "
    } else if minutes != 0 {
        normalized += "\(minutes) \(options.localizedMinutes) "
    }
    
    if seconds == 1 {
        normalized += "\(seconds) \(options.localizedSecond) "
    } else if seconds != 0 {
        normalized += "\(seconds) \(options.localizedSeconds) "
    }
    
    return normalized
}

func normalize(timeInterval timeInterval: NSTimeInterval) -> String {
    let hours = Int(timeInterval) % 86400 / 60 / 60
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    
    var normalized = ""
    
    if hours == 1 {
        normalized += "\(hours) \(NSLocalizedString("Hour", comment: "")) "
    } else if hours != 0 {
        normalized += "\(hours) \(NSLocalizedString("Hours", comment: "")) "
    }
    
    if minutes == 1 {
        normalized += "\(minutes) \(NSLocalizedString("Minute", comment: "")) "
    } else if minutes != 0 {
        normalized += "\(minutes) \(NSLocalizedString("Minutes", comment: "")) "
    }
    
    if seconds == 1 {
        normalized += "\(seconds) \(NSLocalizedString("Second", comment: "")) "
    } else if seconds != 0 {
        normalized += "\(seconds) \(NSLocalizedString("Seconds", comment: "")) "
    }
    
    return normalized
}