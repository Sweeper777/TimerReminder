import UIKit
import Firebase
import CoreData
import RealmSwift
import Eureka

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(named: "tint")
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
            kGADSimulatorID as! String
        ]
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        NavigationAccessoryView.appearance().tintColor = UIColor(named: "tint")
        
        if lastUsedBuild < 25 {
            func connstructReminderObjectFromManagedObject(_ managedObject: NSManagedObject) -> ReminderObject? {
                let newObject = ReminderObject()
                let timesUpMessage = managedObject.value(forKey: "customRemindMessage") as? String
                if timesUpMessage.isNotNilNotEmpty {
                    newObject.message = timesUpMessage
                }
                guard let remindTime = (managedObject.value(forKey: "remindTimeFrame") as? NSNumber)?.intValue else { return nil }
                newObject.remindTime = remindTime
                return newObject
            }
            
            func constructTimerOptionsObjectFromManagedObject(_ managedObject: NSManagedObject) -> TimerOptionsObject? {
                let newObject = TimerOptionsObject()
                guard let name = managedObject.value(forKey: "name") as? String else { return nil }
                guard let beepSounds = (managedObject.value(forKey: "beepSounds") as? NSNumber)?.boolValue else { return nil }
                // if 0, no countdown
                guard let countDownTime = (managedObject.value(forKey: "countDownTime") as? NSNumber)?.intValue else { return nil }
                // if nil or empty, nil
                let timesUpMessage = managedObject.value(forKey: "timesUpMessage") as? String
                let regularReminderInterval = (managedObject.value(forKey: "regularReminderInterval") as? NSNumber)?.intValue
                // if nil or empty, nil
                let regularReminderMessage = managedObject.value(forKey: "regularReminderMessage") as? String
                let timesUpSound = managedObject.value(forKey: "timesUpSound") as? String
                guard let language = managedObject.value(forKey: "language") as? String else { return nil }
                guard let vibrate = (managedObject.value(forKey: "vibrate") as? NSNumber)?.boolValue else { return nil }
                guard let reminders = (managedObject.value(forKey: "reminders") as? NSOrderedSet).flatMap({ Array($0) as? [NSManagedObject] }) else { return nil }
                let reminderObjects = reminders.compactMap(connstructReminderObjectFromManagedObject)
                guard let countSeconds = (managedObject.value(forKey: "counting") as? NSNumber)?.boolValue else { return nil }
                
                newObject.name = name.trimmingCharacters(in: .whitespaces)
                newObject.beepSounds = beepSounds
                newObject.countDownTime.value = countDownTime == 0 ? nil : countDownTime
                newObject.countSeconds = countSeconds
                newObject.language = language
                if let interval = regularReminderInterval {
                    newObject.regularReminders = true
                    let regularReminder = ReminderObject()
                    regularReminder.remindTime = interval
                    if regularReminderMessage.isNotNilNotEmpty {
                        regularReminder.message = regularReminderMessage
                    }
                    newObject.reminders.append(regularReminder)
                } else {
                    newObject.regularReminders = false
                    newObject.reminders.append(objectsIn: reminderObjects)
                }
                if timesUpMessage.isNotNilNotEmpty {
                    newObject.timeUpMessage = timesUpMessage
                }
                newObject.timeUpSound = timesUpSound
                newObject.vibrate = vibrate
                return newObject
            }
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TimerOptions")
            do {
                let managedObjects = try managedObjectContext().fetch(fetchRequest)
                print(managedObjects.count)
            } catch {
                print("No Migration Occurred")
                print(error)
            }
        }
        
        lastUsedBuild = Int(Bundle.main.appBuild) ?? 0
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.TimerReminder" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
         // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
         let modelURL = Bundle.main.url(forResource: "TimerReminder", withExtension: "momd")!
         return NSManagedObjectModel(contentsOf: modelURL)!
     }()

    func persistentStoreCoordinator() throws -> NSPersistentStoreCoordinator {
         // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
         // Create the coordinator and store
         let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        if FileManager.default.fileExists(atPath: url.path) {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                                                                                     NSInferMappingModelAutomaticallyOption: true])
        } else {
            throw MigrationError.noNeed
        }
         return coordinator
    }

     func managedObjectContext() throws -> NSManagedObjectContext {
         // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
         let coordinator = try self.persistentStoreCoordinator()
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
         managedObjectContext.persistentStoreCoordinator = coordinator
         return managedObjectContext
     }
}

var lastUsedBuild: Int {
    get { return UserDefaults.standard.integer(forKey: "lastUsedBuild") }
    set { UserDefaults.standard.set(newValue, forKey: "lastUsedBuild") }
}

enum MigrationError: Error {
    case noNeed
}
