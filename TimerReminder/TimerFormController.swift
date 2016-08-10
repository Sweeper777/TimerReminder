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
        let row1 = XLFormRowDescriptor(tag: "language", rowType: XLFormRowDescriptorTypeSelectorPush, title: NSLocalizedString("Language", comment: ""))
        let langs: [Languages] = [.English, .Mandarin, .Cantonese, .Japanese]
        row1.selectorOptions = langs.map { LanguageWrapper(language: $0) }
        row1.value = LanguageWrapper(language: .English)
        section1.addFormRow(row1)
        form.addFormSection(section1)
        
        self.form = form
    }
}
