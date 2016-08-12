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
            <<< PickerInlineRow<CountDownTimeWrapper>(tagStartCountDown) {
                row in
                row.title = NSLocalizedString("Start Countdown At", comment: "")
                row.value = CountDownTimeWrapper._10
                row.options = [
                    CountDownTimeWrapper.noCountdown,
                    CountDownTimeWrapper._3,
                    CountDownTimeWrapper._5,
                    CountDownTimeWrapper._10,
                    CountDownTimeWrapper._20,
                    CountDownTimeWrapper._30,
                    CountDownTimeWrapper._60,
                ]
        }
        
        form +++ Section(header: NSLocalizedString("time is up", comment: ""), footer: NSLocalizedString("Only applicable in Timer Mode", comment: ""))
            <<< SegmentedRow<TimeIsUpActionWrapper>(tagTimesUpAction) {
                row in
                row.options = [TimeIsUpActionWrapper.sayMessage, TimeIsUpActionWrapper.playSound]
                row.value = TimeIsUpActionWrapper.sayMessage
        }
            <<< TextRow(tagTimesUpMessage) {
                row in
                row.title = NSLocalizedString("Message", comment: "")
                row.hidden = Condition.Function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpActionWrapper> = $0.rowByTag(tagTimesUpAction)!
                    return action.value == TimeIsUpActionWrapper.playSound
                }
        }
            <<< PickerInlineRow<String>(tagTimesUpSound) {
                row in
                row.title = NSLocalizedString("Sound", comment: "")
                row.hidden = Condition.Function([tagTimesUpAction]) {
                    let action: SegmentedRow<TimeIsUpActionWrapper> = $0.rowByTag(tagTimesUpAction)!
                    return action.value == TimeIsUpActionWrapper.sayMessage
                }
                row.options = ["xxx", "yyy", "zzz"]
                row.value = "xxx"
        }
    }
}

