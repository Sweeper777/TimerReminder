import Foundation
import CoreData
import UIKit

class TimerOptions: NSManagedObject {
    static let defaultOptions: TimerOptions = {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let options = TimerOptions.init(entity: NSEntityDescription.entityForName("TimerOptions", inManagedObjectContext: context)!, insertIntoManagedObjectContext: nil)
        options.initializeWithDefValues()
        options.name = "Default"
        return options
    }()
    
    func initializeWithDefValues() {
        self.name = "Unnamed"
        self.beepSounds = false
        self.countDownTime = 10
        self.reminders = NSOrderedSet()
        self.timesUpMessage = "Time is up"
    }
}
