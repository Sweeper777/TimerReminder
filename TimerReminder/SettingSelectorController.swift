import UIKit
import CoreData

class SettingSelectorController: UITableViewController {
    var options = [TimerOptions]()
    let dataContext: NSManagedObjectContext! = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            cell.textLabel?.text = NSLocalizedString("Default", comment: "")
        } else {
            cell.textLabel?.text = options[indexPath.row - 1].name!
        }
        return cell
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissVC(completion: nil)
    }
}
