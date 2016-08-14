import UIKit

class DataPasserController: UINavigationController {
    var selectedOption: TimerOptions?
    
    override func viewDidLoad() {
        if let vc = self.topViewController as? SettingSelectorController {
            vc.selectedOption = selectedOption
        }
    }
}
