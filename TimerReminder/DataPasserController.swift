import UIKit

class DataPasserController: UINavigationController {
    var selectedOption: TimerOptions?
    var optionsToEdit: TimerOptions?
    var image: UIImage?
    weak var settingsDelegate: GlobalSettingsControllerDelegate?
    
    override func viewDidLoad() {
        if let vc = self.topViewController as? SettingSelectorController {
            vc.selectedOption = selectedOption
        } else if let vc = self.topViewController as? TimerFormController {
            vc.options = self.optionsToEdit
        } else if let vc = self.topViewController as? GlobalSettingsController {
            vc.delegate = settingsDelegate
        } else if let vc = self.topViewController as? ScreenshotController {
            vc.image = self.image
        }
    }
}
