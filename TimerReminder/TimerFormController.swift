import Eureka
import UIKit
import CoreData

class TimerFormController: FormViewController {
    var options: TimerOptions!
    
    @IBAction func cancel(sender: AnyObject) {
        dismissVC(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.title = ""
        
        title = NSLocalizedString("Add Settings", comment: "")
        
        initializeForm()
    }
    
    func initializeForm() {
        
        form +++ Section(footer: NSLocalizedString("This is the language in which the reminder messages and the \"Time is up\" message will be spoken.", comment: ""))
            <<< TextRow(tagName) {
                row in
                row.title = NSLocalizedString("Name:", comment: "")
                row.cell.textField.textAlignment = .Left
        }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .Left
        }
            <<< PickerInlineRow<Languages>(tagLanguage) {
                row in
                row.title = NSLocalizedString("Language", comment: "")
                let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
                row.options = langs
                row.value = .English
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
                row.value = ._10
                row.options = [
                    ._3, ._5, ._10, ._20, ._30, ._60
                ]
                row.hidden = Condition.Function([tagCountDownEnabled]) {
                    let enabled: SwitchRow = $0.rowByTag(tagCountDownEnabled)!
                    return !enabled.value!
                }
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
                row.value = .SayMessage
        }
            <<< TextRow(tagTimesUpMessage) {
                row in
                row.title = NSLocalizedString("Message:", comment: "")
                row.hidden = Condition.Function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpAction> = $0.rowByTag(tagTimesUpAction)!
                    return action.value == .PlaySound
                }
                row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
                
        }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .Left
        }
            <<< PickerInlineRow<String>(tagTimesUpSound) {
                row in
                row.title = NSLocalizedString("Sound", comment: "")
                row.hidden = Condition.Function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpAction> = $0.rowByTag(tagTimesUpAction)!
                    return action.value == .SayMessage
                }
                row.options = ["xxx", "yyy", "zzz"]
                row.value = "xxx"
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
                row.hidden = Condition.Function([tagReminderOnOff]) {
                    let onOff: SwitchRow = $0.rowByTag(tagReminderOnOff)!
                    return !onOff.value!
                }
        }
            <<< StepperRow(tagReminderCount) {
                row in
                row.value = 1
                row.title = NSLocalizedString("No. of Reminders", comment: "")
                row.cell.stepper.maximumValue = 10
                row.cell.stepper.minimumValue = 1
                row.cell.valueLabel.textColor = UIApplication.sharedApplication().keyWindow!.tintColor
                
                row.hidden = Condition.Function([tagReminderOnOff, tagReminderStyle]) {
                    let enabled: SwitchRow = $0.rowByTag(tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowByTag(tagReminderStyle)!
                    
                    return !enabled.value! || style.value! == .Regular
                }
        }
        
            <<< TimeIntervalRow(tag: tagRegularReminderInterval) {
                row in
                row.title = NSLocalizedString("Remind Every", comment: "")
                row.value = 300
                row.hidden = Condition.Function([tagReminderOnOff, tagReminderStyle]) {
                    let enabled: SwitchRow = $0.rowByTag(tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowByTag(tagReminderStyle)!
                    
                    return !enabled.value! || style.value! == .AtSpecificTimes
                }
        }
        
        for i in 1...10 {
            form +++ Section("\(NSLocalizedString("Reminder", comment: "")) \(i)") {
                section in
                section.hidden = Condition.Function([tagReminderCount, tagReminderOnOff, tagReminderStyle]) {
                    let count: StepperRow = $0.rowByTag(tagReminderCount)!
                    let onOff: SwitchRow = $0.rowByTag(tagReminderOnOff)!
                    let style: SegmentedRow<ReminderStyle> = $0.rowByTag(tagReminderStyle)!
                    
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
                        cell.textField.textAlignment = .Left
            }
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let options = TimerOptions.init(entity: NSEntityDescription.entityForName("TimerOptions", inManagedObjectContext: context)!, insertIntoManagedObjectContext: nil)
        options.initializeWithDefValues()
        var values = form.values(includeHidden: false)
        values = values.filter {
            if let value = $0.1 as? String {
                return value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != ""
            }
            return true
        }
        
        if let name = values[tagName] as? String {
            options.name = name
        }
        
        if let language = values[tagLanguage] as? Languages {
            options.language = language.rawValue
        }
        
        if let countDown = values[tagStartCountDown] as? CountDownTime {
            options.countDownTime = countDown.rawValue
        }
        
        if let beepSounds = values[tagBeepSounds] as? Bool {
            options.beepSounds = beepSounds
        }
        
        if let timesUpMessage = values[tagTimesUpMessage] as? String {
            options.timesUpMessage = timesUpMessage
        }
        
        if let timesUpSound = values[tagTimesUpSound] as? String {
            options.timesUpSound = timesUpSound
        }
        
        if let regularReminderInterval = values[tagRegularReminderInterval] as? Int {
            options.regularReminderInterval = regularReminderInterval
        }
        
        if let reminderCount = values[tagReminderCount] as? Double {
            var reminders = [Reminder]()
            for i in 1...Int(reminderCount) {
                let reminder = Reminder(entity: NSEntityDescription.entityForName("Reminder", inManagedObjectContext: context)!, insertIntoManagedObjectContext: nil)
                reminder.initializeWithDefValues()
                
                if let remindAt = values[tagRemindAt + String(i)] as? Int {
                    reminder.remindTimeFrame = remindAt
                }
                
                if let message = values[tagRemindMessage + String(i)] as? String {
                    reminder.customRemindMessage = message
                }
                
                reminder.timer = options
                reminders.append(reminder)
            }
            
            options.reminders = NSOrderedSet(array: reminders)
        }
        self.options = options
        performSegueWithIdentifier("unwindToTimer", sender: self)
    }
}

