import UIKit
import MaterialComponents
import SnapKit

class TimerOptionsListViewController : UITableViewController {
    var tableViewTopInset: CGFloat?
    var doneButton: MDCFloatingButton!
    var addButton: MDCFloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
            tableView.contentInset.bottom = 84
            
            doneButton = MDCFloatingButton(shape: .default)
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.imageView?.tintColor = .white
            doneButton.backgroundColor = UIColor(named: "tint")
            view.addSubview(doneButton)
            doneButton.snp.makeConstraints { (make) in
                make.right.equalTo(view.snp.right).offset(-20).labeled("done button on the rightmost of screen")
            }
            let doneBottomConstraint = doneButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
            doneBottomConstraint.constant = -40
            doneBottomConstraint.isActive = true
            
            addButton = MDCFloatingButton(shape: .default)
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addButton.imageView?.tintColor = .white
            addButton.backgroundColor = UIColor(named: "tint")
            view.addSubview(addButton)
            addButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(20).labeled("add button on the leftmost of view")
            }
            let addBottomConstraint = addButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
            addBottomConstraint.constant = -40
            addBottomConstraint.isActive = true
        }
    }
}
