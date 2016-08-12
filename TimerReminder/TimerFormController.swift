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
        //
        //        let section2 = XLFormSectionDescriptor()
        //        section2.footerTitle = NSLocalizedString("Only applicable in Timer Mode", comment: "")
        //        let row3 = XLFormRowDescriptor(tag: tagStartCountDown, rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Start Countdown At", comment: ""))
        //        row3.value = CountDownTimeWrapper._10
        //        row3.selectorOptions = [
        //            CountDownTimeWrapper.noCountdown,
        //            CountDownTimeWrapper._3,
        //            CountDownTimeWrapper._5,
        //            CountDownTimeWrapper._10,
        //            CountDownTimeWrapper._20,
        //            CountDownTimeWrapper._30,
        //            CountDownTimeWrapper._60,
        //        ]
        //        row3.required = true
        //        section2.addFormRow(row3)
        //        form.addFormSection(section2)
        //
        //        let section3 = XLFormSectionDescriptor()
        //        section3.title = NSLocalizedString("Time is up", comment: "")
        //        section3.footerTitle = NSLocalizedString("Only applicable in Timer Mode", comment: "")
        //        let row4 = XLFormRowDescriptor(tag: tagTimesUpAction, rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "")
        //        row4.selectorOptions = [TimeIsUpActionWrapper.sayMessage, TimeIsUpActionWrapper.playSound]
        //        row4.value = TimeIsUpActionWrapper.sayMessage
        //        section3.addFormRow(row4)
        //        let row5 = XLFormRowDescriptor(tag: tagTimesUpMessage, rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Message", comment: ""))
        //        section3.addFormRow(row5)
        //        form.addFormSection(section3)
        //
        //        self.form = form
        //    }
        //
        
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
    }
}

