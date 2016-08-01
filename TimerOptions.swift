import Foundation
import CoreData


class TimerOptions: NSManagedObject {
    static let defaultOptions: TimerOptions = {
        let options = TimerOptions()
        options.name = "Default"
        return options
    }()
    
    func initializeWithDefvalues() {
        self.name = "Unnamed"
        self.beepSounds = false
        self.countDownTime = 10
        self.reminders = NSOrderedSet()
        self.timesUpMessage = "Time is up"
    }
}
