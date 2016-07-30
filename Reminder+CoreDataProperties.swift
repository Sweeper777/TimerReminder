import Foundation
import CoreData

extension Reminder {

    @NSManaged var remindTimeFrame: NSNumber?
    @NSManaged var customRemindMessage: String?
    @NSManaged var timer: TimerOptions?

}
