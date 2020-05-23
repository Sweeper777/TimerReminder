import UIKit
import Eureka
import AVFoundation
import SCLAlertView
import SplitRow
import MaterialComponents
import SnapKit
import KeyboardLayoutGuide
import LTMorphingLabel

class OptionsEditorViewController: FormViewController {
    var isCurrentOptions = false
    var tableViewTopInset: CGFloat?
    var showNameField = false
    var player: AVAudioPlayer?
    var doneButton: MDCFloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
            tableView.contentInset.bottom = 84
            
            doneButton = MDCFloatingButton(shape: .default)
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.imageView?.tintColor = .white
            doneButton.backgroundColor = UIColor(hex: "5abb5a")
            view.addSubview(doneButton)
            doneButton.snp.makeConstraints { (make) in
                make.width.equalTo(44).labeled("done button width = 44")
                make.height.equalTo(44).labeled("done button height = 44")
                make.right.equalToSuperview().offset(-20).labeled("done button on the rightmost of screen")
            }
            let constraint = doneButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
            constraint.constant = -40
            constraint.isActive = true
            
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        }
        
        setUpForm()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isEditing = true
    }
    
    @objc func doneTapped() {
        
    }
    
    private func setUpForm() {
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
        
        form +++ Section("Appearance".localised)
            <<< PickerInlineRow<FontStyle>(tagFontStyle) {
                row in
                row.title = "Font Style".localised
                row.options = [.thin, .regular, .light, .ultralight, .bodoni72, .chalkduster]
                row.value = TimerOptions.default.font
            }
            <<< PickerInlineRow<LTMorphingEffect>(tagAnimation) {
                row in
                row.title = "Timer Animation".localised
                row.value = TimerOptions.default.textAnimation
                row.options = [.evaporate, .scale, .pixelate, .fall, .burn]
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
        
        form +++ Section()
            <<< SwitchRow(tagReminderOnOff) {
                row in
                row.title = "Reminders".localised
                row.value = false
            }
            <<< SegmentedRow<String>(tagReminderStyle) {
                row in
                row.options = ["Regular".localised, "At Specific Times".localised]
                row.value = "At Specific Times".localised
                row.cell.segmentedControl.apportionsSegmentWidthsByContent = true
                
                row.hidden = Condition.function([tagReminderOnOff]) {
                    let onOff: SwitchRow = $0.rowBy(tag: tagReminderOnOff)!
                    return !onOff.value!
                }
        }
        
        form +++ Section {
            $0.hidden = .function([tagReminderStyle, tagReminderOnOff], { (form) -> Bool in
                let enabled: SwitchRow = form.rowBy(tag: tagReminderOnOff)!
                let style: SegmentedRow<String> = form.rowBy(tag: tagReminderStyle)!
                return !((enabled.value ?? false) && style.value == "Regular".localised)
            })
            }
            <<< TimeIntervalRow(tagRegularReminderInterval) {
                row in
                row.title = "Remind Every".localised
                row.value = 300
            }
            
            <<< TextRow(tagRegularReminderMessage) {
                row in
                row.title = "Message:".localised
                row.placeholder = "Leave blank for default".localised
            }.cellUpdate { cell, row in
                cell.textField.textAlignment = .left
        }
        
        form +++ MultivaluedSection(
            multivaluedOptions: [.Insert, .Delete],
            footer: "Please enter the remind time and reminder message.".localised) {
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Add Reminder".localised
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return SplitRow<TimeIntervalRow,TextRow>(){
                        $0.rowLeft = TimeIntervalRow(){
                            $0.title = ""
                            $0.value = 60 * (index + 1)
                        }.cellUpdate({ (cell, row) in
                            cell.selectionStyle = .none
                        })
                        
                        $0.rowRight = TextRow(){
                            $0.title = ""
                            $0.placeholder = "Default"
                        }
                        
                        $0.rowLeftPercentage = 0.48
                    }
                }
                $0 <<< SplitRow<TimeIntervalRow,TextRow>(){
                    $0.rowLeft = TimeIntervalRow(){
                        $0.title = ""
                        $0.value = 60
                    }.cellUpdate({ (cell, row) in
                        cell.selectionStyle = .none
                    })
                    
                    $0.rowRight = TextRow(){
                        $0.title = ""
                        $0.placeholder = "Default"
                    }
                    
                    $0.rowLeftPercentage = 0.48
                }
                $0.tag = tagReminders
                $0.hidden = .function([tagReminderStyle, tagReminderOnOff], { (form) -> Bool in
                    let enabled: SwitchRow = form.rowBy(tag: tagReminderOnOff)!
                    let style: SegmentedRow<String> = form.rowBy(tag: tagReminderStyle)!
                    return !((enabled.value ?? false) && style.value == "At Specific Times".localised)
                })
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
let tagReminderOnOff = "reminderOnOff"
let tagReminderStyle = "reminderStyle"
let tagRegularReminderInterval = "regularReminderInterval"
let tagRegularReminderMessage = "regularReminderMessage"
let tagReminders = "reminders"
let tagFontStyle = "fontStyle"
let tagAnimation = "animation"
