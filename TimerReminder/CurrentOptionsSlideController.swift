import UIKit
import SlideMenuControllerSwift

class CurrentOptionsSlideController: SlideMenuController {
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "TimerViewController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CurrentOptionsNavigationController") {
            self.rightViewController = controller
        }
        super.awakeFromNib()
    }
}
