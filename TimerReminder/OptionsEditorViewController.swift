import UIKit
import Eureka
import AVFoundation
import SplitRow
import LTMorphingLabel

class OptionsEditorViewController: FormViewController {
    var isCurrentOptions = false
    var tableViewTopInset: CGFloat?
    var player: AVAudioPlayer?
    
    var optionsDisplayed = TimerOptions.default {
        didSet {
            form.removeAll()
            setUpForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
            tableView.contentInset.bottom = 84
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isEditing = true
    }
    
    @objc func doneTapped() {
        let values = form.values()
        let name = values[tagName] as? String ?? TimerOptions.default.name
        let language = (values[tagLanguage] as? Languages)?.rawValue ?? TimerOptions.default.language
        let countDown: CountDownOption
        if let countDownTime = (values[tagStartCountDown] as? CountDownTime)?.rawValue {
            countDown = .yes(startsAt: countDownTime)
        } else {
            countDown = .no
        }
        let countSeconds = values[tagCounting] as? Bool ?? TimerOptions.default.countSeconds
        let beepSounds = values[tagBeepSounds] as? Bool ?? TimerOptions.default.beepSounds
        let font = values[tagFontStyle] as? FontStyle ?? TimerOptions.default.font
        let animation = values[tagAnimation] as? LTMorphingEffect ?? TimerOptions.default.textAnimation
        let timeUpOption: TimeUpOption
        if let timesUpAction = values[tagTimesUpAction] as? String {
            if timesUpAction == "Verbalize a Message".localised {
                let message = values[tagTimesUpMessage] as? String ?? ""
                if message.isEmpty {
                    timeUpOption = .speakDefaultMessage
                } else {
                    timeUpOption = .speak(message)
                }
            } else if timesUpAction == "Play a Sound".localised {
                if let sound = values[tagTimesUpSound] as? String {
                    timeUpOption = .playSound(sound)
                } else {
                    timeUpOption = TimerOptions.default.timeUpOption
                }
            } else {
                timeUpOption = TimerOptions.default.timeUpOption
            }
        } else {
            timeUpOption = TimerOptions.default.timeUpOption
        }
        let vibrate = values[tagVibrate] as? Bool ?? TimerOptions.default.vibrate
        let reminderOption: ReminderOption
        if let reminderStyle = values[tagReminderStyle] as? String {
            if reminderStyle == "Regular".localised {
                let interval = values[tagRegularReminderInterval] as? Int ?? 300
                let message = values [tagRegularReminderMessage] as? String
                reminderOption = .regularInterval(Reminder(remindTime: interval, message: message))
            } else if reminderStyle == "At Specific Times".localised {
                let reminders = (values[tagReminders] as? [Any] ?? []).compactMap { $0 as? SplitRowValue<Int, String> }
                if reminders.isEmpty {
                    reminderOption = .no
                } else {
                    func transformSplitValue(_ splitValue: SplitRowValue<Int, String>) -> (Int, String?)? {
                        guard let int = splitValue.left else { return nil }
                        if splitValue.right.isNilOrEmpty {
                            return (int, nil)
                        } else {
                            return (int, splitValue.right)
                        }
                    }
                    reminderOption = .specificTimes(
                        reminders.compactMap(transformSplitValue(_:))
                            .map { Reminder(remindTime: $0, message: $1) }
                    )
                }
            } else {
                reminderOption = TimerOptions.default.reminderOption
            }
        } else {
            reminderOption = TimerOptions.default.reminderOption
        }
        
        let options = TimerOptions(
            name: name,
            language: language,
            countDown: countDown,
            countSeconds: countSeconds,
            beepSounds: beepSounds,
            vibrate: vibrate,
            timeUpOption: timeUpOption,
            reminderOption: reminderOption,
            font: font,
            textAnimation: animation)
        if isCurrentOptions {
            (parent?.slideMenuController()?.mainViewController as? TimerViewController)?.currentOptions = options
        }
    }
    
 
}
