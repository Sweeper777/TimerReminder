import XLForm
import UIKit

class TimerFormController: XLFormViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissVC(completion: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Add Settings", comment: ""))
        
        let section1 = XLFormSectionDescriptor()
        section1.footerTitle = NSLocalizedString("This is the language in which the reminder messages and the \"Time is up\" message will be spoken.", comment: "")
        let row1 = XLFormRowDescriptor(tag: tagName, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Name", comment: ""))
        section1.addFormRow(row1)
        let row2 = XLFormRowDescriptor(tag: tagLanguage, rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: NSLocalizedString("Language", comment: ""))
        let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
        row2.selectorOptions = langs.map { LanguageWrapper(language: $0) }
        row2.value = LanguageWrapper(language: .English)
        section1.addFormRow(row2)
        form.addFormSection(section1)
        
        let section2 = XLFormSectionDescriptor()
        section2.footerTitle = NSLocalizedString("Only applicable in Timer Mode", comment: "")
        let row3 = XLFormRowDescriptor(tag: tagStartCountDown, rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: NSLocalizedString("Start Countdown At", comment: ""))
        row3.value = CountDownTimeWrapper._10
        row3.selectorOptions = [
            CountDownTimeWrapper.noCountdown,
            CountDownTimeWrapper._3,
            CountDownTimeWrapper._5,
            CountDownTimeWrapper._10,
            CountDownTimeWrapper._20,
            CountDownTimeWrapper._30,
            CountDownTimeWrapper._60,
        ]
        section2.addFormRow(row3)
        form.addFormSection(section2)
        
        let section3 = XLFormSectionDescriptor()
        section3.title = NSLocalizedString("Time is up", comment: "")
        section3.footerTitle = NSLocalizedString("Only applicable in Timer Mode", comment: "")
        let row4 = XLFormRowDescriptor(tag: tagTimesUpAction, rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "")
        row4.selectorOptions = [TimeIsUpActionWrapper.sayMessage, TimeIsUpActionWrapper.playSound]
        row4.value = TimeIsUpActionWrapper.sayMessage
        section3.addFormRow(row4)
        let row5 = XLFormRowDescriptor(tag: tagTimesUpMessage, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Message", comment: ""))
        section3.addFormRow(row5)
        form.addFormSection(section3)
        
        self.form = form
    }
    
    func showTimesUpMessageRow() {
        let sec = form.formSectionAtIndex(2)!
        
        sec.removeFormRowAtIndex(1)
        
        let row = XLFormRowDescriptor(tag: tagTimesUpMessage, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Message", comment: ""))
        sec.addFormRow(row)
    }
    
    func showTimesUpSoundRow() {
        let sec = form.formSectionAtIndex(2)!
        
        sec.removeFormRowAtIndex(1)
        
        let row = XLFormRowDescriptor(tag: tagTimesUpSound, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Sound", comment: ""))
        row.selectorOptions = ["xxx", "yyy", "zzz"]
        row.value = "xxx"
        
        sec.addFormRow(row)
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        if formRow.tag == nil {
            return
        }
        
        switch formRow.tag! {
        case tagTimesUpAction:
            if (newValue as! TimeIsUpActionWrapper) == TimeIsUpActionWrapper.playSound {
                showTimesUpSoundRow()
            } else if (newValue as! TimeIsUpActionWrapper) == TimeIsUpActionWrapper.sayMessage {
                showTimesUpMessageRow()
            }
        default:
            break
        }
    }
}
