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
        if let currentOptionsVC = self.storyboard?.instantiateViewController(withIdentifier: "options") as? CurrentOptionsViewController,
            let timerOptionsListVC = self.storyboard?.instantiateViewController(identifier: "myOptions") as? TimerOptionsListViewController {
            currentOptionsVC.tableViewTopInset = tabPageViewController.option.tabHeight
            tabPageViewController.tabItems = [(currentOptionsVC, "Current Options".localised), (timerOptionsListVC, "All Timer Options".localised)]
            self.rightViewController = tabPageViewController
        }
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
