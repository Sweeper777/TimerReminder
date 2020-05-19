import UIKit
import Eureka
import AVFoundation
import SCLAlertView

class CurrentOptionsViewController: FormViewController {
    var tableViewTopInset: CGFloat?
    var showNameField = false
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
        }
        
        form +++ ButtonRow() {
            row in
            row.title = "Hello"
        }.onCellSelection({ (cell, row) in
            let vc = UIStoryboard.main!.instantiateViewController(identifier: "timeIntervalPicker")
            self.present(vc, animated: true, completion: nil)
        })
        
        let section1 = Section(footer: "This is the language in which the reminder messages and the \"Time is up\" message will be spoken.".localised)
        
        if showNameField {
            section1 +++ TextRow(tagName) {
                row in
                row.title = "Name:".localised
                row.value = TimerOptions.default.name
            }
        }
        
        section1 <<< PickerInlineRow<Languages>(tagLanguage) {
            row in
            row.title = "Language".localised
            let langs: [Languages] = [.english, .mandarin, .cantonese, .japanese]
            row.options = langs
            row.value = Languages(rawValue: TimerOptions.default.language)
        }
        
        form +++ section1
        
        form +++ Section(footer: "Only applicable in Timer Mode".localised)
            <<< SwitchRow(tagCountDownEnabled) {
                row in
                row.title = "Countdown".localised
                row.value = true
            }
            <<< PickerInlineRow<CountDownTime>(tagStartCountDown) {
                row in
                row.title = "Start Countdown At".localised
                row.options = [
                    ._3, ._5, ._10, ._20, ._30, ._60
                ]
                row.value = ._10
                row.hidden = Condition.function([tagCountDownEnabled]) {
                    let enabled: SwitchRow = $0.rowBy(tag: tagCountDownEnabled)!
                    return !enabled.value!
                }
        }
        
        form +++ Section(footer: "Only applicable in Stopwatch Mode".localised)
            <<< SwitchRow(tagCounting) {
                row in
                row.title = "Counting".localised
                row.value = false
        }
        
        form +++ SwitchRow(tagBeepSounds) {
            row in
            row.title = "Beep Sounds".localised
            row.value = TimerOptions.default.beepSounds
        }
        
        form +++ Section(header: "time is up".localised, footer: "Only applicable in Timer Mode".localised)
            <<< SegmentedRow<String>(tagTimesUpAction) {
                row in
                row.options = ["Verbalize a Message".localised, "Play a Sound".localised]
                row.value = "Verbalize a Message".localised
                }.onChange {
                    row in
                    self.player?.stop()
            }
            <<< TextRow(tagTimesUpMessage) {
                row in
                row.title = "Message:".localised
                row.hidden = Condition.function([tagTimesUpAction]) {
                    let action: SegmentedRow<String> = $0.rowBy(tag: tagTimesUpAction)!
                    return action.value == "Play a Sound".localised
                }
                row.placeholder = "Leave blank for default".localised
                
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
            }
            <<< PickerInlineRow<String>(tagTimesUpSound) {
                row in
                row.title = "Sound".localised
                row.hidden = Condition.function([tagTimesUpAction]) {
                    let action: SegmentedRow<String> = $0.rowBy(tag: tagTimesUpAction)!
                    return action.value == "Verbalize a Message".localised
                }
                row.options = ["Radar", "Waves", "Radiate", "Night Owl", "Circuit", "Sencha", "Cosmic", "Presto", "Beacon", "Hillside"]
                row.value = "Radar"
                }.onChange {
                    row in
                    if row.isHidden {
                        return
                    }
                    
                    if let url = Bundle.main.url(forResource: row.value, withExtension: ".mp3") {
                        self.player?.stop()
                        self.player = try? AVAudioPlayer(contentsOf: url)
                        self.player?.prepareToPlay()
                        self.player?.play()
                    }
                }.onCellSelection {
                    cell, row in
                    self.player?.stop()
            }
            
            <<< SwitchRow(tagVibrate) {
                row in
                row.title = "Vibrate".localised
                row.value = TimerOptions.default.vibrate
        }
    }
}

let tagName = "name"
let tagLanguage = "language"
let tagCountDownEnabled = "countDownEnabled"
let tagStartCountDown = "startCountDown"
let tagCounting = "counting"
let tagBeepSounds = "beepSounds"
let tagTimesUpAction = "tagTimesUpAction"
let tagTimesUpMessage = "timesUpMessage"
let tagTimesUpSound = "timesUpSound"
let tagVibrate = "vibrate"
