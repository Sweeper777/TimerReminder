import UIKit
import MaterialComponents
import SnapKit
import EmptyDataSet_Swift

class TimerOptionsListViewController : UITableViewController {
    var tableViewTopInset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
            tableView.contentInset.bottom = 84
        }
        
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "You don't have any saved timer options!".localised))
            view.detailLabelString(NSAttributedString(string: "Tap the '+' button to create one!".localised))
        }
    }
}
