import UIKit
import CoreData
import MGSwipeTableCell

class SettingSelectorController: UITableViewController {
    var options = [TimerOptions]()
    let dataContext: NSManagedObjectContext! = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var selectedOption: TimerOptions?
    var optionsToEdit: TimerOptions?
    
    override func viewDidLoad() {
        if dataContext != nil {
            self.options.removeAll()
            let entity = NSEntityDescription.entityForName("TimerOptions", inManagedObjectContext: dataContext)
            let request = NSFetchRequest()
            request.entity = entity
            let options = try? dataContext.executeFetchRequest(request)
            if options != nil {
                for item in options! {
                    self.options.append(item as! TimerOptions)
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            if self.selectedOption != nil {
                let index = selectedOption == nil ? 0 : options.indexOf { $0.objectID == self.selectedOption!.objectID }! + 1
                if indexPath.row == index {
                    cell.accessoryType = .Checkmark
                }
            } else if indexPath.row == 0 {
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = NSLocalizedString("Default", comment: "")
            return cell
        } else {
            let cell = MGSwipeTableCell()
            if self.selectedOption != nil {
                let index = selectedOption == nil ? 0 : options.indexOf { $0.objectID == self.selectedOption!.objectID }! + 1
                if indexPath.row == index {
                    cell.accessoryType = .Checkmark
                }
            } else if indexPath.row == 0 {
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = options[indexPath.row - 1].name!
            cell.rightSwipeSettings.transition = .Drag
            let deleteBtn = MGSwipeButton(title: NSLocalizedString("Delete", comment: ""), backgroundColor: UIColor.redColor(), callback: { _ in
                let itemToDelete = self.options[indexPath.row - 1]
                if itemToDelete == self.selectedOption {
//                    tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.accessoryType = .Checkmark
                    self.selectedOption = nil
                }
                self.options.removeAtIndex(indexPath.row - 1)
                self.dataContext.deleteObject(itemToDelete)
                _ = try? self.dataContext.save()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                tableView.reloadData()
                return true
            })
            
            let editBtn = MGSwipeButton(title: NSLocalizedString("Edit", comment: ""), backgroundColor: UIColor.grayColor(), callback: { _ in
                self.optionsToEdit = self.options[indexPath.row - 1]
                self.performSegueWithIdentifier("showSettingsEditor", sender: self)
                return true
            })
            cell.rightButtons = [deleteBtn, editBtn]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedOption = indexPath.row == 0 ? nil : options[indexPath.row - 1]
        for i in 0...options.count {
            tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))?.accessoryType = .None
        }
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? DataPasserController {
            vc.optionsToEdit = self.optionsToEdit
        }
    }
    
    @IBAction func unwindFromSettingsEditor(segue: UIStoryboardSegue) {
        
    }
}
