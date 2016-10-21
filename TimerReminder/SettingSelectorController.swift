import UIKit
import CoreData
import MGSwipeTableCell

class SettingSelectorController: UITableViewController {
    var options = [TimerOptions]()
    let dataContext: NSManagedObjectContext! = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    var selectedOption: TimerOptions?
    var optionsToEdit: TimerOptions?
    
    func reloadData() {
        if dataContext != nil {
            self.options.removeAll()
            let entity = NSEntityDescription.entity(forEntityName: "TimerOptions", in: dataContext)
            let request = NSFetchRequest<TimerOptions>()
            request.entity = entity
            let options = try? dataContext.fetch(request)
            if options != nil {
                for item in options! {
                    self.options.append(item)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = UITableViewCell()
            if self.selectedOption != nil {
                let index = selectedOption == nil ? 0 : options.index { $0.objectID == self.selectedOption!.objectID }! + 1
                if (indexPath as NSIndexPath).row == index {
                    cell.accessoryType = .checkmark
                }
            } else if (indexPath as NSIndexPath).row == 0 {
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = NSLocalizedString("Default", comment: "")
            return cell
        } else {
            let cell = MGSwipeTableCell()
            if self.selectedOption != nil {
                let index = selectedOption == nil ? 0 : options.index { $0 == self.selectedOption! }! + 1
                if (indexPath as NSIndexPath).row == index {
                    cell.accessoryType = .checkmark
                }
            } else if (indexPath as NSIndexPath).row == 0 {
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = options[(indexPath as NSIndexPath).row - 1].name!
            cell.rightSwipeSettings.transition = .drag
            let deleteBtn = MGSwipeButton(title: NSLocalizedString("Delete", comment: ""), backgroundColor: UIColor.red, callback: { _ in
                let itemToDelete = self.options[(indexPath as NSIndexPath).row - 1]
                if itemToDelete == self.selectedOption {
//                    tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .Checkmark
                    self.selectedOption = nil
                }
                self.options.remove(at: (indexPath as NSIndexPath).row - 1)
                self.dataContext.delete(itemToDelete)
                _ = try? self.dataContext.save()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.reloadData()
                return true
            })
            
            let editBtn = MGSwipeButton(title: NSLocalizedString("Edit", comment: ""), backgroundColor: UIColor.gray, callback: { _ in
                self.optionsToEdit = self.options[(indexPath as NSIndexPath).row - 1]
                self.performSegue(withIdentifier: "showSettingsEditor", sender: self)
                return true
            })
            cell.rightButtons = [deleteBtn, editBtn]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedOption = (indexPath as NSIndexPath).row == 0 ? nil : options[(indexPath as NSIndexPath).row - 1]
        for i in 0...options.count {
            tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DataPasserController {
            vc.optionsToEdit = self.optionsToEdit
        }
    }
    
    @IBAction func unwindFromSettingsEditor(_ segue: UIStoryboardSegue) {
        reloadData()
        tableView.reloadData()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismissVC(completion: nil)
    }
}
