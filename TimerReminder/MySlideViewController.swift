import SlideMenuControllerSwift
import TabPageViewController

class MySlideViewController: SlideMenuController {

    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "main") {
            self.mainViewController = controller
        }
        let tabPageViewController = TabPageViewController.create()
        tabPageViewController.option.currentColor = UIColor(hex: "5abb5a")
        tabPageViewController.option.tabBackgroundColor = .systemBackground
        tabPageViewController.option.pageBackgoundColor = .systemBackground
        super.awakeFromNib()
    }

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == leftPanGesture || gestureRecognizer == leftTapGesture {
            return super.gestureRecognizer(isLeftOpen() ? leftTapGesture! : gestureRecognizer, shouldReceive: touch)
        } else if gestureRecognizer == rightPanGesture || gestureRecognizer == rightTapGesture {
            return super.gestureRecognizer(isRightOpen() ? rightTapGesture! : gestureRecognizer, shouldReceive: touch)
        } else {
            return true 
        }
    }
}
