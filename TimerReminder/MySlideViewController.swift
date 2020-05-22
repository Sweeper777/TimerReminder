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
        if let currentOptionsVC = self.storyboard?.instantiateViewController(withIdentifier: "options") as? OptionsEditorViewController,
            let timerOptionsListVC = self.storyboard?.instantiateViewController(identifier: "myOptions") as? TimerOptionsListViewController {
            currentOptionsVC.tableViewTopInset = tabPageViewController.option.tabHeight
            currentOptionsVC.isCurrentOptions = true
            tabPageViewController.tabItems = [(currentOptionsVC, "Current Options".localised), (timerOptionsListVC, "All Timer Options".localised)]
            self.rightViewController = tabPageViewController
        }
        tabPageViewController.definesPresentationContext = true
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            SlideMenuOptions.rightViewWidth *= 2
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
