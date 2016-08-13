import Foundation
import CoreData


class Reminder: NSManagedObject {

    func initializeWithDefValues() {
        self.remindTimeFrame = 0
    }
}
