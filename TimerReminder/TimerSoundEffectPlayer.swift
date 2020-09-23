import AVFoundation
import CoreHaptics

class TimerSoundEffectPlayer {
    private let beepSoundPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "beep", withExtension: "mp3")!)
    private var endSoundPlayer: AVAudioPlayer!
    private let speechSynthesiser = AVSpeechSynthesizer()
    
    var language: String
    var timeUpOption: TimeUpOption {
        didSet {
            switch timeUpOption {
            case .playSound(let sound):
                endSoundPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: sound, withExtension: "mp3")!)
                endSoundPlayer.prepareToPlay()
                endSoundPlayer.numberOfLoops = -1
            default:
                break
            }
        }
    }
    
    private var localisedReminderMessage: String {
        switch language {
        case "zh-cn", "zh-hk":
            return "剩餘 %@"
        case "ja":
            return "残り %@"
        default:
            return "%@ Left"
        }
    }
    
    private var localisedTimeUpMessage: String {
        switch language {
        case "zh-cn", "zh-hk":
            return "時間到"
        case "ja":
            return "時間切れです"
        default:
            return "Time is up."
        }
    }
    
    init(language: String, timeUpOption: TimeUpOption) {
        self.language = language
        self.timeUpOption = timeUpOption
    }
    
    private func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesiser.stopSpeaking(at: .immediate)
        speechSynthesiser.speak(utterance)
    }
    
    func countSecond(_ second: Int) {
        speak("\(second)")
    }
    
    func beep() {
        beepSoundPlayer.play()
    }
    
    func vibrate() {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
    }
    
    func performTimeUpAction() {
        switch timeUpOption {
        case .speakDefaultMessage:
            speak(localisedTimeUpMessage)
        case .speak(let message):
            speak(message)
        case .playSound:
            endSoundPlayer.play()
        }
    }
    
    func remind(_ reminder: Reminder, timerMode: Timer.Mode, remindTime: Int? = nil) {
        if let message = reminder.message {
            speak(message)
        } else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .dropAll
            formatter.unitsStyle = .full
            formatter.calendar?.locale = Locale(identifier: language)
            let timeString = formatter.string(from: TimeInterval(remindTime ?? reminder.remindTime))!
            if timerMode == .countDown {
                speak(String(format: localisedReminderMessage, timeString))
            } else {
                speak(timeString)
            }
        }
    }
    
    func stopPlaying() {
        beepSoundPlayer.stop()
        endSoundPlayer?.stop()
        speechSynthesiser.stopSpeaking(at: .immediate)
    }
}
