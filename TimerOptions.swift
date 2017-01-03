import Foundation
import CoreData
import UIKit

class TimerOptions: NSManagedObject {
    static let defaultOptions: TimerOptions = {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let options = TimerOptions.init(entity: NSEntityDescription.entity(forEntityName: "TimerOptions", in: context)!, insertInto: nil)
        options.initializeWithDefValues()
        options.name = "Default"
        
        return options
    }()
    
    func initializeWithDefValues() {
        self.name = "Unnamed"
        self.beepSounds = false
        self.countDownTime = 0
        self.language = Languages.English.rawValue
        self.timesUpMessage = nil
        self.regularReminderInterval = nil
        self.timesUpSound = nil
        self.vibrate = false
        self.regularReminderMessage = nil
        self.reminders = NSOrderedSet()
        self.counting = false
    }
}
