import UIKit
import Eureka
import LTMorphingLabel

class GlobalSettingsController: FormViewController {
    weak var delegate: GlobalSettingsControllerDelegate?
    
    @IBAction func done(sender: AnyObject) {
        dismissVC(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Global Settings", comment: "")
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
        
            +++ PickerInlineRow<LTMorphingEffect>(tagAnimation) {
                row in
                row.title = NSLocalizedString("Timer Animation", comment: "")
                row.value = LTMorphingEffect(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("timerAnimation"))!
                row.options = [.Evaporate, .Scale, .Pixelate, .Fall, .Burn]
        }.onChange {
            row in
            self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "timerAnimation", newValue: row.value!.rawValue)
        }
        
            +++ SwitchRow(tagNightMode) {
                row in
                row.title = NSLocalizedString("Night Mode", comment: "")
                row.value = NSUserDefaults.standardUserDefaults().boolForKey("nightMode")
        }.onChange {
            row in
            self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "nightMode", newValue: row.value!)
        }
    }
}
