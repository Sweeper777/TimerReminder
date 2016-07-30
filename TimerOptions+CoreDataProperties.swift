import Foundation
import CoreData

extension TimerOptions {

    @NSManaged var name: String?
    @NSManaged var beepSounds: NSNumber?
    @NSManaged var countDownTime: NSNumber?
    @NSManaged var timesUpMessage: String?
    @NSManaged var regularReminderInterval: NSNumber?
    @NSManaged var timesUpSound: String?
    @NSManaged var reminders: NSOrderedSet?

}
