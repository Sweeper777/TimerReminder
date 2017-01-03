import Foundation
import CoreData

extension TimerOptions {

    @NSManaged var name: String?
    @NSManaged var beepSounds: NSNumber?
    @NSManaged var countDownTime: NSNumber?
    @NSManaged var timesUpMessage: String?
    @NSManaged var regularReminderInterval: NSNumber?
    @NSManaged var regularReminderMessage: String?
    @NSManaged var timesUpSound: String?
    @NSManaged var language: String?
    @NSManaged var vibrate: NSNumber?
    @NSManaged var reminders: NSOrderedSet?
    @NSManaged var counting: NSNumber?

}
