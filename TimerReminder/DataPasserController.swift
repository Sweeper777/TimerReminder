import UIKit

class DataPasserController: UINavigationController {
    var selectedOption: TimerOptions?
    var optionsToEdit: TimerOptions?
    
    override func viewDidLoad() {
        if let vc = self.topViewController as? SettingSelectorController {
            vc.selectedOption = selectedOption
        } else if let vc = self.topViewController as? TimerFormController {
            vc.options = self.optionsToEdit
        }
    }
}
