import UIKit

class TimerOptionsListViewController : UITableViewController {
    var tableViewTopInset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
        }
    }
}
