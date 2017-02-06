import UIKit
import Eureka
import LTMorphingLabel

class GlobalSettingsController: FormViewController {
    weak var delegate: GlobalSettingsControllerDelegate?
    
    @IBAction func done(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
                row.value = UserDefaults.standard.bool(forKey: "gestureControl")
        }.onChange {
                row in
                self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "gestureControl", newValue: row.value!)
        }
        
            +++ PickerInlineRow<FontStyle>(tagFontStyle) {
                row in
                row.title = NSLocalizedString("Font Style", comment: "")
                row.options = [.Thin, .Regular, .Light, .Ultralight, .Bodoni72, .Chalkduster]
                let fontStyle = UserDefaults.standard.integer(forKey: "fontStyle")
                row.value = FontStyle(rawValue: fontStyle)
        }.onChange {
            row in
            print(row.value!)
            self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "fontStyle", newValue: row.value!)
        }
        
            +++ PickerInlineRow<LTMorphingEffect>(tagAnimation) {
                row in
                row.title = NSLocalizedString("Timer Animation", comment: "")
                row.value = LTMorphingEffect(rawValue: UserDefaults.standard.integer(forKey: "timerAnimation"))!
                row.options = [.evaporate, .scale, .pixelate, .fall, .burn]
        }.onChange {
            row in
            self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "timerAnimation", newValue: row.value!.rawValue)
        }
        
            +++ SwitchRow(tagNightMode) {
                row in
                row.title = NSLocalizedString("Night Mode", comment: "")
                row.value = UserDefaults.standard.bool(forKey: "nightMode")
        }.onChange {
            row in
            self.delegate?.globalSettings?(self, globalSettingsDidChangeWithKey: "nightMode", newValue: row.value!)
        }
    }
}
