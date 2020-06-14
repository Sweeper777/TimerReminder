import SlideMenuControllerSwift
import TabPageViewController
import MaterialComponents
import KeyboardLayoutGuide
import XXArrowTips

class MySlideViewController: SlideMenuController {

    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "main") as? TimerViewController {
            self.mainViewController = controller
            self.delegate = controller
        }
        let tabPageViewController = TabPageViewController.create()
        tabPageViewController.option.currentColor = UIColor(named: "tint")!
        tabPageViewController.option.tabBackgroundColor = .systemBackground
        tabPageViewController.option.pageBackgoundColor = .systemBackground
        if let currentOptionsVC = self.storyboard?.instantiateViewController(withIdentifier: "options") as? OptionsEditorViewController,
            let timerOptionsListVC = self.storyboard?.instantiateViewController(identifier: "myOptions") as? TimerOptionsListViewController {
            currentOptionsVC.tableViewTopInset = tabPageViewController.option.tabHeight
            currentOptionsVC.mode = .current
            timerOptionsListVC.tableViewTopInset = tabPageViewController.option.tabHeight
            tabPageViewController.tabItems = [(currentOptionsVC, "Current Options".localised), (timerOptionsListVC, "All Timer Options".localised)]
            self.rightViewController = tabPageViewController
        }
        tabPageViewController.definesPresentationContext = true
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            SlideMenuOptions.rightViewWidth *= 2
        }
        
        let doneButton = MDCFloatingButton(shape: .default)
        doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        doneButton.imageView?.tintColor = .white
        doneButton.backgroundColor = UIColor(named: "tint")
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        tabPageViewController.view.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20).labeled("done button on the rightmost of screen")
        }
        let doneBottomConstraint = doneButton.bottomAnchor.constraint(equalTo: tabPageViewController.view.keyboardLayoutGuide.topAnchor)
        doneBottomConstraint.constant = -40
        doneBottomConstraint.isActive = true
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
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
    
    @objc func doneTapped() {
        if isRightOpen(), let tabVC = rightViewController as? TabPageViewController,
            let responder = tabVC.currentIndex.map({ tabVC.tabItems[$0].viewController }) as? DoneTappedRespondable {
            closeRight()
            responder.doneTapped()
        }
    }
}

protocol DoneTappedRespondable {
    func doneTapped()
}
