import XLForm
import UIKit

class TimerFormController: XLFormViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: NSLocalizedString("Add Settings", comment: ""))
        
        let section1 = XLFormSectionDescriptor()
        section1.footerTitle = NSLocalizedString("This is the language in which the reminder messages and the \"Time is up\" message will be spoken.", comment: "")
        
        let row1 = XLFormRowDescriptor(tag: "name", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Name", comment: ""))
        section1.addFormRow(row1)
        
        let row2 = XLFormRowDescriptor(tag: "language", rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: NSLocalizedString("Language", comment: ""))
        let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
        row2.selectorOptions = langs.map { LanguageWrapper(language: $0) }
        row2.value = LanguageWrapper(language: .English)
        section1.addFormRow(row2)
        form.addFormSection(section1)
        
        let section2 = XLFormSectionDescriptor()
        section2.footerTitle = NSLocalizedString("Only applicable in Timer Mode", comment: "")
        let row3 = XLFormRowDescriptor(tag: "startCountdown", rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: NSLocalizedString("Start Countdown At", comment: ""))
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
        
        self.form = form
    }
}
