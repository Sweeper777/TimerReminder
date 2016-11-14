import AVFoundation


class CountDownTimer: Timer {
    var beepSoundPlayer: AVAudioPlayer?
    var timesUpSoundPlayer: AVAudioPlayer?
    var timeLeft: TimeInterval
    let timeToMeasure: TimeInterval
    let synthesizer = AVSpeechSynthesizer()
    var timer: Foundation.Timer?
    var paused = true
    var onEnd: ((Timer) -> Void)?
    var onTimerChange: ((Timer) -> Void)?
    
    var options: TimerOptions? {
        didSet {
            guard let enableBeep = options?.beepSounds?.boolValue else {
                return
            }
            
            if let timesUpSound = options?.timesUpSound {
                timesUpSoundPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: timesUpSound, withExtension: ".mp3")!)
                timesUpSoundPlayer?.prepareToPlay()
                timesUpSoundPlayer?.numberOfLoops = -1
            }
            
            if enableBeep && beepSoundPlayer == nil {
                beepSoundPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "beep", withExtension: ".mp3")!)
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
        timesUpSoundPlayer?.stop()
        synthesizer.stopSpeaking(at: .immediate)
        onTimerChange?(self)
    }
    
    func start() {
        if ended {
            return
        }
        
        timer = Foundation.Timer.runThisEvery(seconds: 1) {
            [unowned self]
            _ in
            self.timeLeft -= 1
            
            let enableBeep = self.options?.beepSounds?.boolValue
            let shouldRemind = self.shouldInvokeReminder()
            
            if self.timeLeft <= 0 {
                // time's up
                if (self.options?.timesUpSound) != nil {
                    self.timesUpSoundPlayer?.play()
                } else {
                    let utterance = AVSpeechUtterance(string: self.options!.localizedTimesUpMessage)
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
                }
                
                if self.options!.vibrate?.boolValue ?? false {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }
            } else if Int(self.timeLeft) <= Int(self.options!.countDownTime!) {
                // countdown
                let utterance = AVSpeechUtterance(string: String(Int(self.timeLeft)))
                utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                self.synthesizer.stopSpeaking(at: .immediate)
                self.synthesizer.speak(utterance)
            } else if shouldRemind.should {
                // remind
                if shouldRemind.customMessage == nil {
                    let utteranceString = String(format: self.options!.localizedLeftFormat, normalize(timeInterval: self.timeLeft, with: self.options!))
                    let utterance = AVSpeechUtterance(string: utteranceString)
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
                } else {
                    // custom message
                    let remindMessage = shouldRemind.customMessage!.replacingOccurrences(of: "$TIMELEFT$", with: normalize(timeInterval: self.timeLeft, with: self.options!))
                    let utterance = AVSpeechUtterance(string: remindMessage)
                    utterance.voice = AVSpeechSynthesisVoice(language: self.options!.language!)
                    self.synthesizer.stopSpeaking(at: .immediate)
                    self.synthesizer.speak(utterance)
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
        timesUpSoundPlayer?.stop()
        synthesizer.stopSpeaking(at: .immediate)
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
    
    fileprivate func setTimerOptions(_ options: TimerOptions) {
        self.options = options
    }
    
    fileprivate func shouldInvokeReminder() -> (should: Bool, customMessage: String?) {
        if let specificReminders = options?.reminders {
            let reminders = specificReminders.map { Int(($0 as! Reminder).remindTimeFrame!) }
            let should = reminders.contains(Int(timeLeft))
            if should {
                let index = reminders.index(of: Int(timeLeft))
                let message = (specificReminders.array[index!] as! Reminder).customRemindMessage
                return (should, message)
            }
            if reminders.count != 0 {
                return (should, nil)
            }
        }
        
        if let regularReminders = options?.regularReminderInterval {
            if Int(regularReminders) <= 0 {
                return (false, nil)
            }
            
            return (Int(timeToMeasure - timeLeft) % Int(regularReminders) == 0, options?.regularReminderMessage)
        }
        
        return (false, nil)
    }
    
    init(time: TimeInterval, options: TimerOptions? = nil, onTimerChange: ((Timer) -> Void)?, onEnd: ((Timer) -> Void)?) {
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
    func padLeft(character: Character, length: Int) -> String {
        if self.length < length {
            let characterToAdd = length - self.length
            let string = String(repeating: String(character), count: characterToAdd)
            return string + self
        }
        return self
    }
}

func normalize(timeInterval: TimeInterval, with options: TimerOptions) -> String {
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

func normalize(timeInterval: TimeInterval) -> String {
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
