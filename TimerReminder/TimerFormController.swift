import Eureka
import UIKit
import CoreData
import AVFoundation

class TimerFormController: FormViewController {
    var options: TimerOptions!
    var shouldApplyOptions = false
    var player: AVAudioPlayer?
    
    @IBAction func cancel(sender: AnyObject) {
        dismissVC(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.title = ""
        
        title = options == nil ? NSLocalizedString("Add Settings", comment: "") : NSLocalizedString("Edit Settings", comment: "")
        
        initializeForm()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let row: StepperRow = form.rowByTag(tagReminderCount)!
        if self.options != nil && self.options.reminders!.count != 0 {
            row.value = self.options.reminders!.count
        } else {
            row.value = 1
        }
    }
    
    func initializeForm() {
        
        form +++ Section(footer: NSLocalizedString("This is the language in which the reminder messages and the \"Time is up\" message will be spoken.", comment: ""))
            <<< TextRow(tagName) {
                row in
                row.title = NSLocalizedString("Name:", comment: "")
                row.cell.textField.textAlignment = .Left
                row.value = self.options == nil ? "" : self.options.name
        }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .Left
        }
            <<< PickerInlineRow<Languages>(tagLanguage) {
                row in
                row.title = NSLocalizedString("Language", comment: "")
                let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
                row.options = langs
                row.value = self.options == nil ? .English : Languages(rawValue: self.options.language!)
        }
        
        form +++ Section(footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SwitchRow(tagCountDownEnabled) {
                row in
                row.title = NSLocalizedString("Countdown", comment: "")
                row.value = true
                
                if self.options != nil {
                    row.value = self.options.countDownTime != 0
                }
        }
            <<< PickerInlineRow<CountDownTime>(tagStartCountDown) {
                row in
                row.title = NSLocalizedString("Start Countdown At", comment: "")
                row.value = self.options == nil ? ._10 : (CountDownTime(rawValue: Int(self.options.countDownTime!)) ?? ._10)
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
            
            if self.options != nil {
                row.value = self.options.beepSounds!.boolValue
            }
        }
        
        form +++ Section(header: NSLocalizedString("time is up", comment: ""), footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SegmentedRow<TimeIsUpAction>(tagTimesUpAction) {
                row in
                row.options = [.SayMessage, .PlaySound]
                row.value = self.options == nil ? .SayMessage : (self.options.timesUpSound == nil ? .SayMessage : .PlaySound)
        }
            <<< TextRow(tagTimesUpMessage) {
                row in
                row.title = NSLocalizedString("Message:", comment: "")
                row.hidden = Condition.Function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpAction> = $0.rowByTag(tagTimesUpAction)!
                    return action.value == .PlaySound
                }
                row.value = self.options == nil ? "" : self.options.timesUpMessage ?? ""
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
                row.options = ["Radar", "yyy", "zzz"]
                row.value = self.options?.timesUpSound == nil ? "Radar" : self.options.timesUpSound
        }.onChange {
            row in
            if let url = NSBundle.mainBundle().URLForResource(row.value, withExtension: ".mp3") {
                self.player?.stop()
                self.player = try? AVAudioPlayer(contentsOfURL: url)
                self.player?.prepareToPlay()
                self.player?.play()
            }
        }
        
        form +++ Section()
            <<< SwitchRow(tagReminderOnOff) {
                row in
                row.title = NSLocalizedString("Reminders", comment: "")
                row.value = false
                
                if self.options != nil {
                    row.value = self.options.reminders!.count != 0 || self.options.regularReminderInterval != nil
                }
        }
            <<< SegmentedRow<ReminderStyle>(tagReminderStyle) {
                row in
                row.options = [.Regular, .AtSpecificTimes]
                row.value = .AtSpecificTimes
                
                if self.options != nil {
                    row.value = self.options.regularReminderInterval == nil ? .AtSpecificTimes : .Regular
                }
                
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
                
                if self.options != nil && self.options.reminders!.count != 0 {
                    row.value = self.options.reminders!.count
                } else {
                    row.value = 1
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
                
                if self.options?.regularReminderInterval != nil {
                    row.value = Int(options.regularReminderInterval!)
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
                    
                    if self.options?.reminders != nil && self.options.reminders!.count >= i {
                        row.value = Int((self.options.reminders!.array[i - 1] as! Reminder).remindTimeFrame!)
                    }
            }
                <<< TextRow(tagRemindMessage + String(i)) {
                    row in
                    row.title = NSLocalizedString("Message:", comment: "")
                    row.placeholder = NSLocalizedString("Leave blank for default", comment: "")
                    if self.options?.reminders != nil && self.options.reminders!.count >= i {
                        row.value = (self.options.reminders!.array[i - 1] as! Reminder).customRemindMessage ?? ""
                    }
                    }.cellUpdate { cell, row in
                        cell.textField.textAlignment = .Left
            }
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save and apply", comment: ""), style: .Default) {
            [unowned self]
            _ in
            self.shouldApplyOptions = true
            self.processOptions(true)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Apply but don't save", comment: ""), style: .Default) {
            [unowned self]
            _ in
            self.shouldApplyOptions = true
            self.processOptions(false)
            })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save but don't apply", comment: ""), style: .Default) {
            [unowned self]
            _ in
            self.shouldApplyOptions = false
            self.processOptions(true)
            })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) {
            _ in
            })
        self.presentVC(alert)
    }
    
    func processOptions(shouldSave: Bool) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let options = TimerOptions.init(entity: NSEntityDescription.entityForName("TimerOptions", inManagedObjectContext: context)!, insertIntoManagedObjectContext: shouldSave ? context : nil)
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
        
        if let reminderCount = values[tagReminderCount] as? Int {
            print(reminderCount)
            var reminders = [Reminder]()
            for i in 1...Int(reminderCount) {
                let reminder = Reminder(entity: NSEntityDescription.entityForName("Reminder", inManagedObjectContext: context)!, insertIntoManagedObjectContext: shouldSave ? context : nil)
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
        _ = try? context.save()
        performSegueWithIdentifier("unwindToTimer", sender: self)
    }
}

