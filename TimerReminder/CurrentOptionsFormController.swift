import UIKit
import Eureka
import SlideMenuControllerSwift
import AVFoundation

class CurrentOptionsFormController: FormViewController {
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        title = NSLocalizedString("Current Options", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func syncTimerOptions() {
        let options = (self.slideMenuController()?.mainViewController as? TimerViewController)?.appliedOptions ?? TimerOptions.defaultOptions
        form.rowBy(tag: tagName)?.baseValue = options.name
        form.rowBy(tag: tagLanguage)?.baseValue = Languages(rawValue: options.language!)
        form.rowBy(tag: tagCountDownEnabled)?.baseValue = options.countDownTime != 0
        form.rowBy(tag: tagStartCountDown)?.baseValue = CountDownTime(rawValue: Int(options.countDownTime!)) ?? ._10
        form.rowBy(tag: tagCounting)?.baseValue = options.counting?.boolValue
        form.rowBy(tag: tagBeepSounds)?.baseValue = options.beepSounds!.boolValue
        form.rowBy(tag: tagTimesUpAction)?.baseValue = options.timesUpSound == nil ? TimeIsUpAction.SayMessage : .PlaySound
        form.rowBy(tag: tagTimesUpMessage)?.baseValue = options.timesUpMessage ?? ""
        form.rowBy(tag: tagTimesUpSound)?.baseValue = options.timesUpSound == nil ? "Radar" : options.timesUpSound
        form.rowBy(tag: tagVibrate)?.baseValue = options.vibrate?.boolValue ?? false
        form.rowBy(tag: tagReminderOnOff)?.baseValue = options.reminders!.count != 0 || options.regularReminderInterval != nil
        form.rowBy(tag: tagReminderStyle)?.baseValue = options.regularReminderInterval == nil ? ReminderStyle.AtSpecificTimes : .Regular
        if options.reminders!.count != 0 {
            form.rowBy(tag: tagReminderCount)?.baseValue = Double(options.reminders!.count)
        } else {
            form.rowBy(tag: tagReminderCount)?.baseValue = 1.0
        }
        form.rowBy(tag: tagRegularReminderInterval)?.baseValue = Int(options.regularReminderInterval ?? 300)
        form.rowBy(tag: tagRegularReminderMessage)?.baseValue = options.regularReminderMessage ?? ""
        for i in 1...10 {
            if options.reminders != nil && options.reminders!.count >= i {
                form.rowBy(tag: tagRemindAt + String(i))?.baseValue = Int((options.reminders!.array[i - 1] as! Reminder).remindTimeFrame!)
                form.rowBy(tag: tagRemindMessage + String(i))?.baseValue = (options.reminders!.array[i - 1] as! Reminder).customRemindMessage ?? ""
            }
        }
        
        form.allRows.forEach { $0.updateCell() }
    }
    
    func initializeForm() {
        form +++ Section(footer: NSLocalizedString("This is the language in which the reminder messages and the \"Time is up\" message will be spoken.", comment: ""))
            <<< TextRow(tagName) {
                row in
                row.title = NSLocalizedString("Name:", comment: "")
                row.cell.textField.textAlignment = .left
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
            }
            <<< PickerInlineRow<Languages>(tagLanguage) {
                row in
                row.title = NSLocalizedString("Language", comment: "")
                let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
                row.options = langs
        }
        
        form +++ Section(footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SwitchRow(tagCountDownEnabled) {
                row in
                row.title = NSLocalizedString("Countdown", comment: "")
                row.value = true
            }
            <<< PickerInlineRow<CountDownTime>(tagStartCountDown) {
                row in
                row.title = NSLocalizedString("Start Countdown At", comment: "")
                row.options = [
                    ._3, ._5, ._10, ._20, ._30, ._60
                ]
                row.hidden = Condition.function([tagCountDownEnabled]) {
                    let enabled: SwitchRow = $0.rowBy(tag: tagCountDownEnabled)!
                    return !enabled.value!
                }
        }
        
        form +++ Section(footer: NSLocalizedString("Only applicable in Stopwatch Mode", comment: ""))
            <<< SwitchRow(tagCounting) {
                row in
                row.title = NSLocalizedString("Counting", comment: "")
                row.value = false
        }
        
        form +++ SwitchRow(tagBeepSounds) {
            row in
            row.title = NSLocalizedString("Beep Sounds", comment: "")
            row.value = false
        }
        
        form +++ Section(header: NSLocalizedString("time is up", comment: ""), footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SegmentedRow<TimeIsUpAction>(tagTimesUpAction) {
                row in
                row.options = [.SayMessage, .PlaySound]
                }.onChange {
                    row in
                    self.player?.stop()
            }
            <<< TextRow(tagTimesUpMessage) {
                row in
                row.title = NSLocalizedString("Message:", comment: "")
                row.hidden = Condition.function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpAction> = $0.rowBy(tag: tagTimesUpAction)!
                    return action.value == .PlaySound
                }
                row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
                
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
            }
            <<< PickerInlineRow<String>(tagTimesUpSound) {
                row in
                row.title = NSLocalizedString("Sound", comment: "")
                row.hidden = Condition.function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpAction> = $0.rowBy(tag: tagTimesUpAction)!
                    return action.value == .SayMessage
                }
                row.options = ["Radar", "Waves", "Radiate", "Night Owl", "Circuit", "Sencha", "Cosmic", "Presto", "Beacon", "Hillside"]
                }.onChange {
                    row in
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
                row.title = NSLocalizedString("Vibrate", comment: "")
                row.value = false
        }
        
        form +++ Section()
            <<< SwitchRow(tagReminderOnOff) {
                row in
                row.title = NSLocalizedString("Reminders", comment: "")
                row.value = false
            }
            <<< SegmentedRow<ReminderStyle>(tagReminderStyle) {
                row in
                row.options = [.Regular, .AtSpecificTimes]
                row.value = .AtSpecificTimes
                
                row.hidden = Condition.function([tagReminderOnOff]) {
                    let onOff: SwitchRow = $0.rowBy(tag: tagReminderOnOff)!
                    return !onOff.value!
                }
            }
            <<< StepperRow(tagReminderCount) {
                row in
                row.value = 1
                row.title = NSLocalizedString("No. of Reminders", comment: "")
                row.cell.stepper.maximumValue = 10
                row.cell.stepper.minimumValue = 1
                row.cell.valueLabel.textColor = UIApplication.shared.keyWindow!.tintColor
                
                row.hidden = Condition.function([tagReminderOnOff, tagReminderStyle]) {
                    let enabled: SwitchRow = $0.rowBy(tag: tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowBy(tag: tagReminderStyle)!
                    
                    return !enabled.value! || style.value! == .Regular
                }
            }
            
            <<< TimeIntervalRow(tag: tagRegularReminderInterval) {
                row in
                row.title = NSLocalizedString("Remind Every", comment: "")
                row.value = 300
                row.hidden = Condition.function([tagReminderOnOff, tagReminderStyle]) {
                    let enabled: SwitchRow = $0.rowBy(tag: tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowBy(tag: tagReminderStyle)!
                    
                    return !enabled.value! || style.value! == .AtSpecificTimes
                }
            }
            
            <<< TextRow(tagRegularReminderMessage) {
                row in
                row.title = NSLocalizedString("Message:", comment: "")
                row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
                
                row.hidden = Condition.function([tagReminderOnOff, tagReminderStyle]) {
                    let enabled: SwitchRow = $0.rowBy(tag: tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowBy(tag: tagReminderStyle)!
                    
                    return !enabled.value! || style.value! == .AtSpecificTimes
                }
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
        }
        
        for i in 1...10 {
            form +++ Section("\(NSLocalizedString("Reminder", comment: "")) \(i)") {
                section in
                section.hidden = Condition.function([tagReminderCount, tagReminderOnOff, tagReminderStyle]) {
                    let count: StepperRow = $0.rowBy(tag: tagReminderCount)!
                    let onOff: SwitchRow = $0.rowBy(tag: tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowBy(tag: tagReminderStyle)!
                    
                    if !onOff.value! {
                        return true
                    }
                    
                    if style.value! == .Regular {
                        return true
                    }
                    
                    if count.isHidden {
                        return true
                    }
                    
                    if Int(count.value!) < i {
                        return true
                    }
                    return false
                }
                }
                <<< TimeIntervalRow(tag: tagRemindAt + String(i)) {
                    row in
                    row.title = NSLocalizedString("Remind At", comment: "")
                    row.value = i * 60
                }
                <<< TextRow(tagRemindMessage + String(i)) {
                    row in
                    row.title = NSLocalizedString("Message:", comment: "")
                    row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
                    }.cellUpdate { cell, row in
                        cell.textField.textAlignment = .left
            }
        }

    }
}
