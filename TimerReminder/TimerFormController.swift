import Eureka
import UIKit

class TimerFormController: FormViewController {
    
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
                row.title = NSLocalizedString("Name", comment: "")
        }
            <<< PickerInlineRow<Languages>(tagLanguage) {
                row in
                row.title = NSLocalizedString("Language", comment: "")
                let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
                row.options = langs
                row.value = .English
        }
        
        form +++ Section(footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< PickerInlineRow<CountDownTime>(tagStartCountDown) {
                row in
                row.title = NSLocalizedString("Start Countdown At", comment: "")
                row.value = ._10
                row.options = [
                    .NoCountdown,
                    ._3, ._5, ._10, ._20, ._30, ._60
                ]
        }
        
        form +++ Section(header: NSLocalizedString("time is up", comment: ""), footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SegmentedRow<TimeIsUpAction>(tagTimesUpAction) {
                row in
                row.options = [.SayMessage, .PlaySound]
                row.value = .SayMessage
        }
            <<< TextRow(tagTimesUpMessage) {
                row in
                row.title = NSLocalizedString("Message", comment: "")
                row.hidden = Condition.Function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpAction> = $0.rowByTag(tagTimesUpAction)!
                    return action.value == .PlaySound
                }
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
//                row.cell.segmentedControl.apportionsSegmentWidthsByContent = true
                row.hidden = Condition.Function([tagReminderOnOff]) {
                    let onOff: SwitchRow = $0.rowByTag(tagReminderOnOff)!
                    return !onOff.value!
                }
        }
    }
}

