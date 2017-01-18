import UIKit
import Eureka
import SlideMenuControllerSwift
import AVFoundation

class CurrentOptionsFormController: FormViewController {
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func initializeForm() {
        form +++ Section(footer: NSLocalizedString("This is the language in which the reminder messages and the \"Time is up\" message will be spoken.", comment: ""))
            <<< TextRow(tagName) {
                row in
                row.title = NSLocalizedString("Name:", comment: "")
                row.cell.textField.textAlignment = .left
//                row.value = self.options == nil ? "" : self.options.name
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
            }
            <<< PickerInlineRow<Languages>(tagLanguage) {
                row in
                row.title = NSLocalizedString("Language", comment: "")
                let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
                row.options = langs
//                row.value = self.options == nil ? .English : Languages(rawValue: self.options.language!)
        }
        
        form +++ Section(footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SwitchRow(tagCountDownEnabled) {
                row in
                row.title = NSLocalizedString("Countdown", comment: "")
                row.value = true
                
//                if self.options != nil {
//                    row.value = self.options.countDownTime != 0
//                }
            }
            <<< PickerInlineRow<CountDownTime>(tagStartCountDown) {
                row in
                row.title = NSLocalizedString("Start Countdown At", comment: "")
//                row.value = self.options == nil ? ._10 : (CountDownTime(rawValue: Int(self.options.countDownTime!)) ?? ._10)
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
                
//                if self.options != nil {
//                    row.value = self.options.counting?.boolValue
//                }
        }
        
        form +++ SwitchRow(tagBeepSounds) {
            row in
            row.title = NSLocalizedString("Beep Sounds", comment: "")
            row.value = false
            
//            if self.options != nil {
//                row.value = self.options.beepSounds!.boolValue
//            }
        }
        
        form +++ Section(header: NSLocalizedString("time is up", comment: ""), footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SegmentedRow<TimeIsUpAction>(tagTimesUpAction) {
                row in
                row.options = [.SayMessage, .PlaySound]
//                row.value = self.options == nil ? .SayMessage : (self.options.timesUpSound == nil ? .SayMessage : .PlaySound)
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
//                row.value = self.options == nil ? "" : self.options.timesUpMessage ?? ""
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
//                row.value = self.options?.timesUpSound == nil ? "Radar" : self.options.timesUpSound
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
                
//                if let newValue = options?.vibrate?.boolValue {
//                    row.value = newValue
//                }
        }
        
        form +++ Section()
            <<< SwitchRow(tagReminderOnOff) {
                row in
                row.title = NSLocalizedString("Reminders", comment: "")
                row.value = false
                
//                if self.options != nil {
//                    row.value = self.options.reminders!.count != 0 || self.options.regularReminderInterval != nil
//                }
            }
            <<< SegmentedRow<ReminderStyle>(tagReminderStyle) {
                row in
                row.options = [.Regular, .AtSpecificTimes]
                row.value = .AtSpecificTimes
                
//                if self.options != nil {
//                    row.value = self.options.regularReminderInterval == nil ? .AtSpecificTimes : .Regular
//                }
                
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
                
//                if self.options != nil && self.options.reminders!.count != 0 {
//                    row.value = Double(self.options.reminders!.count)
//                } else {
//                    row.value = 1
//                }
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
                
//                if self.options?.regularReminderInterval != nil {
//                    row.value = Int(options.regularReminderInterval!)
//                }
                
            }
            
            <<< TextRow(tagRegularReminderMessage) {
                row in
                row.title = NSLocalizedString("Message:", comment: "")
                row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
//                if let newValue = self.options?.regularReminderMessage {
//                    row.value = newValue
//                }
                
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
                    
//                    if self.options?.reminders != nil && self.options.reminders!.count >= i {
//                        row.value = Int((self.options.reminders!.array[i - 1] as! Reminder).remindTimeFrame!)
//                    }
                }
                <<< TextRow(tagRemindMessage + String(i)) {
                    row in
                    row.title = NSLocalizedString("Message:", comment: "")
                    row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
//                    if self.options?.reminders != nil && self.options.reminders!.count >= i {
//                        row.value = (self.options.reminders!.array[i - 1] as! Reminder).customRemindMessage ?? ""
//                    }
                    }.cellUpdate { cell, row in
                        cell.textField.textAlignment = .left
            }
        }

    }
}
