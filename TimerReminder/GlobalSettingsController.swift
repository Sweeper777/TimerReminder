import UIKit
import Eureka

class GlobalSettingsController: FormViewController {
    weak var delegate: GlobalSettingsControllerDelegate?
    
    override func viewDidLoad() {
        initializeForm()
    }
    
    func initializeForm() {
        form +++ Section(footer: NSLocalizedString("gesture instructions", comment: ""))
            <<< SwitchRow(tagGestureControls) {
                row in
                row.title = NSLocalizedString("Gesture Controls", comment: "")
                row.value = NSUserDefaults.standardUserDefaults().boolForKey("gestureControl")
            }.onChange {
                row in
                self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "gestureControl", newValue: row.value!)
            }
        
        +++ SegmentedRow<String>(tagFontStyle) {
            row in
            row.title = NSLocalizedString("Font Style", comment: "")
            row.options = ["Light", "Regular"]
            row.value = NSUserDefaults.standardUserDefaults().integerForKey("fontStyle") == 1 ? "Regular" : "Light"
        }.onChange {
            row in
            self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "fontStyle", newValue: row.value!)
        }
    }
}
