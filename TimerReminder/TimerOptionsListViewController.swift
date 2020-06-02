import UIKit
import MaterialComponents
import SnapKit
import EmptyDataSet_Swift

class TimerOptionsListViewController : UITableViewController {
    var tableViewTopInset: CGFloat?
    
    var allTimerOptions: [TimerOptions] = []
    var selectedOptions: TimerOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
            tableView.contentInset.bottom = 84
        }
        
        allTimerOptions = TimerOptionsManager.shared.allTimerOptions
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTimerOptions.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addButton")!
            cell.textLabel?.text = "New Timer Options".localised
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = allTimerOptions[indexPath.row - 1].name
            if selectedOptions?.name == allTimerOptions[indexPath.row - 1].name {
                cell.imageView?.image = UIImage(systemName: "checkmark")
            } else {
                cell.imageView?.image = nil
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.parent?.slideMenuController()?.closeRight()
            (self.parent?.slideMenuController()?.mainViewController as? TimerViewController)?.newOptions()
        } else {
            selectedOptions = allTimerOptions[indexPath.row - 1]
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
