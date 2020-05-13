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

}
