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
    
    var optionsDisplayed = TimerOptions.default {
        didSet {
            form.removeAll()
            setUpForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
            tableView.contentInset.bottom = 84
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isEditing = true
    }
    
    @objc func doneTapped() {
        let values = form.values()
        let name = values[tagName] as? String ?? TimerOptions.default.name
        let language = (values[tagLanguage] as? Languages)?.rawValue ?? TimerOptions.default.language
        let countDown: CountDownOption
        if let countDownTime = (values[tagStartCountDown] as? CountDownTime)?.rawValue {
            countDown = .yes(startsAt: countDownTime)
        } else {
            countDown = .no
        }
        let countSeconds = values[tagCounting] as? Bool ?? TimerOptions.default.countSeconds
        let beepSounds = values[tagBeepSounds] as? Bool ?? TimerOptions.default.beepSounds
        let font = values[tagFontStyle] as? FontStyle ?? TimerOptions.default.font
        let animation = values[tagAnimation] as? LTMorphingEffect ?? TimerOptions.default.textAnimation
        let timeUpOption: TimeUpOption
        if let timesUpAction = values[tagTimesUpAction] as? String {
            if timesUpAction == "Verbalize a Message".localised {
                let message = values[tagTimesUpMessage] as? String ?? ""
                if message.isEmpty {
                    timeUpOption = .speakDefaultMessage
                } else {
                    timeUpOption = .speak(message)
                }
            } else if timesUpAction == "Play a Sound".localised {
                if let sound = values[tagTimesUpSound] as? String {
                    timeUpOption = .playSound(sound)
                } else {
                    timeUpOption = TimerOptions.default.timeUpOption
                }
            } else {
                timeUpOption = TimerOptions.default.timeUpOption
            }
        } else {
            timeUpOption = TimerOptions.default.timeUpOption
        }
        let vibrate = values[tagVibrate] as? Bool ?? TimerOptions.default.vibrate
        let reminderOption: ReminderOption
        if let reminderStyle = values[tagReminderStyle] as? String {
            if reminderStyle == "Regular".localised {
                let interval = values[tagRegularReminderInterval] as? Int ?? 300
                let message = values [tagRegularReminderMessage] as? String
                reminderOption = .regularInterval(Reminder(remindTime: interval, message: message))
            } else if reminderStyle == "At Specific Times".localised {
                let reminders = (values[tagReminders] as? [Any] ?? []).compactMap { $0 as? SplitRowValue<Int, String> }
                if reminders.isEmpty {
                    reminderOption = .no
                } else {
                    func transformSplitValue(_ splitValue: SplitRowValue<Int, String>) -> (Int, String?)? {
                        guard let int = splitValue.left else { return nil }
                        if splitValue.right.isNilOrEmpty {
                            return (int, nil)
                        } else {
                            return (int, splitValue.right)
                        }
                    }
                    reminderOption = .specificTimes(
                        reminders.compactMap(transformSplitValue(_:))
                            .map { Reminder(remindTime: $0, message: $1) }
                    )
                }
            } else {
                reminderOption = TimerOptions.default.reminderOption
            }
        } else {
            reminderOption = TimerOptions.default.reminderOption
        }
        
        let options = TimerOptions(
            name: name,
            language: language,
            countDown: countDown,
            countSeconds: countSeconds,
            beepSounds: beepSounds,
            vibrate: vibrate,
            timeUpOption: timeUpOption,
            reminderOption: reminderOption,
            font: font,
            textAnimation: animation)
        if isCurrentOptions {
            (parent?.slideMenuController()?.mainViewController as? TimerViewController)?.currentOptions = options
        }
    }
    
    fileprivate func metadataRows() {
        let section1 = Section(footer: "This is the language in which the reminder messages and the \"Time is up\" message will be spoken.".localised)
        
        if showNameField {
            section1 +++ TextRow(tagName) {
                row in
                row.title = "Name:".localised
                row.value = optionsDisplayed.name
            }
        }
        
        section1 <<< PickerInlineRow<Languages>(tagLanguage) {
            row in
            row.title = "Language".localised
            let langs: [Languages] = [.english, .mandarin, .cantonese, .japanese]
            row.options = langs
            row.value = Languages(rawValue: optionsDisplayed.language)
        }
        
        form +++ section1
    }
    
    fileprivate func perSecondOptionRows() {
        form +++ Section(footer: "Only applicable in Timer Mode".localised)
            <<< SwitchRow(tagCountDownEnabled) {
                row in
                row.title = "Countdown".localised
                switch optionsDisplayed.countDown {
                case .no:
                    row.value = false
                case .yes:
                    row.value = true
                }
            }.cellSetup({ (cell, row) in
                cell.switchControl.onTintColor = UIColor(named: "tint")
            })
            <<< PickerInlineRow<CountDownTime>(tagStartCountDown) {
                row in
                row.title = "Start Countdown At".localised
                row.options = [
                    ._3, ._5, ._10, ._20, ._30, ._60
                ]
                if case .yes(let startsAt) = optionsDisplayed.countDown {
                    row.value = CountDownTime(rawValue: startsAt)
                } else {
                    row.value = ._10
                }
                row.hidden = Condition.function([tagCountDownEnabled]) {
                    let enabled: SwitchRow = $0.rowBy(tag: tagCountDownEnabled)!
                    return !enabled.value!
                }
        }
        
        form +++ Section(footer: "Only applicable in Stopwatch Mode".localised)
            <<< SwitchRow(tagCounting) {
                row in
                row.title = "Counting".localised
                row.value = optionsDisplayed.countSeconds
        }.cellSetup({ (cell, row) in
            cell.switchControl.onTintColor = UIColor(named: "tint")
        })
        
        form +++ SwitchRow(tagBeepSounds) {
            row in
            row.title = "Beep Sounds".localised
            row.value = optionsDisplayed.beepSounds
        }.cellSetup({ (cell, row) in
            cell.switchControl.onTintColor = UIColor(named: "tint")
        })
    }
    
    fileprivate func appearanceRows() {
        form +++ Section("Appearance".localised)
            <<< PickerInlineRow<FontStyle>(tagFontStyle) {
                row in
                row.title = "Font Style".localised
                row.options = [.thin, .regular, .light, .ultralight, .bodoni72, .chalkduster]
                row.value = optionsDisplayed.font
            }
            <<< PickerInlineRow<LTMorphingEffect>(tagAnimation) {
                row in
                row.title = "Timer Animation".localised
                row.value = optionsDisplayed.textAnimation
                row.options = [.evaporate, .scale, .pixelate, .fall, .burn]
        }
    }
    
    fileprivate func timeIsUpRows() {
        form +++ Section(header: "time is up".localised, footer: "Only applicable in Timer Mode".localised)
            <<< SegmentedRow<String>(tagTimesUpAction) {
                row in
                row.options = ["Verbalize a Message".localised, "Play a Sound".localised]
                switch optionsDisplayed.timeUpOption {
                case .playSound:
                    row.value = "Play a Sound".localised
                case .speak, .speakDefaultMessage:
                    row.value = "Verbalize a Message".localised
                }
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
                if case .speak(let message) = optionsDisplayed.timeUpOption {
                    row.value = message
                }
                
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
                if case .playSound(let sound) = optionsDisplayed.timeUpOption {
                    row.value = sound
                } else {
                    row.value = "Radar"
                }
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
                row.value = optionsDisplayed.vibrate
        }.cellSetup({ (cell, row) in
            cell.switchControl.onTintColor = UIColor(named: "tint")
        })
    }
    
    fileprivate func reminderRows() {
        form +++ Section()
            <<< SwitchRow(tagReminderOnOff) {
                row in
                row.title = "Reminders".localised
                if case .no = optionsDisplayed.reminderOption {
                    row.value = false
                } else {
                    row.value = true
                }
            }.cellSetup({ (cell, row) in
                cell.switchControl.onTintColor = UIColor(named: "tint")
            })
            <<< SegmentedRow<String>(tagReminderStyle) {
                row in
                row.options = ["Regular".localised, "At Specific Times".localised]
                if case .regularInterval = optionsDisplayed.reminderOption {
                    row.value = "Regular".localised
                } else {
                    row.value = "At Specific Times".localised
                }
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
                if case .regularInterval(let reminder) = optionsDisplayed.reminderOption {
                    row.value = reminder.remindTime
                } else {
                    row.value = 300
                }
            }
            
            <<< TextRow(tagRegularReminderMessage) {
                row in
                row.title = "Message:".localised
                row.placeholder = "Leave blank for default".localised
                if case .regularInterval(let reminder) = optionsDisplayed.reminderOption {
                    row.value = reminder.message
                }
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
                            $0.placeholder = "Default".localised
                        }
                        
                        $0.rowLeftPercentage = 0.48
                    }
                }
                if case .specificTimes(let reminders) = optionsDisplayed.reminderOption {
                    for reminder in reminders {
                        $0 <<< SplitRow<TimeIntervalRow,TextRow>(){
                            $0.rowLeft = TimeIntervalRow(){
                                $0.title = ""
                                $0.value = reminder.remindTime
                            }.cellUpdate({ (cell, row) in
                                cell.selectionStyle = .none
                            })
                            
                            $0.rowRight = TextRow(){
                                $0.title = ""
                                $0.placeholder = "Default".localised
                                $0.value = reminder.message
                            }
                            
                            $0.rowLeftPercentage = 0.48
                        }
                    }
                } else {
                    $0 <<< SplitRow<TimeIntervalRow,TextRow>(){
                        $0.rowLeft = TimeIntervalRow(){
                            $0.title = ""
                            $0.value = 60
                        }.cellUpdate({ (cell, row) in
                            cell.selectionStyle = .none
                        })
                        
                        $0.rowRight = TextRow(){
                            $0.title = ""
                            $0.placeholder = "Default".localised
                        }
                        
                        $0.rowLeftPercentage = 0.48
                    }
                }
                
                $0.tag = tagReminders
                $0.hidden = .function([tagReminderStyle, tagReminderOnOff], { (form) -> Bool in
                    let enabled: SwitchRow = form.rowBy(tag: tagReminderOnOff)!
                    let style: SegmentedRow<String> = form.rowBy(tag: tagReminderStyle)!
                    return !((enabled.value ?? false) && style.value == "At Specific Times".localised)
                })
        }
    }
    
    private func setUpForm() {
        metadataRows()
        timeIsUpRows()
        perSecondOptionRows()
        appearanceRows()
        reminderRows()
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
