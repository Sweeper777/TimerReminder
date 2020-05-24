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
    
    
    init(language: String, timeUpOption: TimeUpOption) {
        self.language = language
        self.timeUpOption = timeUpOption
    }
    
}
