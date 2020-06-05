import UIKit
import Eureka
import AVFoundation
import SplitRow
import LTMorphingLabel
import SCLAlertView

class OptionsEditorViewController: FormViewController {
    
    enum Mode {
        case current
        case new
        case edit
    }
    
    var mode = Mode.new
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
        
        if mode == .new {
            navigationItem.rightBarButtonItems?.remove(at: 1)
            title = "New Timer Options".localised
        } else if mode == .edit {
            title = optionsDisplayed.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isEditing = true
    }
    
    @IBAction @objc func doneTapped() {
        let values = form.values()
        let name = values[tagName] as? String
        if mode != .current {
            if (name?.trimmingCharacters(in: .whitespaces)).isNilOrEmpty {
                SCLAlertView().showError("Error".localised, subTitle: "Please enter a name for the timer option!".localised, closeButtonTitle: "OK".localised)
                return
            } else if name == TimerOptions.default.name || (name != optionsDisplayed.name &&
                TimerOptionsManager.shared.queryTimerOptions("name == %@", args: name!.trimmingCharacters(in: .whitespaces)).count > 0) {
                SCLAlertView().showError("Error".localised, subTitle: "Another timer option with this name already exists!".localised, closeButtonTitle: "OK".localised)
                return
            }
        }
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
        
        var options = TimerOptions(
            name: name?.trimmingCharacters(in: .whitespaces) ?? TimerOptions.default.name,
            language: language,
            countDown: countDown,
            countSeconds: countSeconds,
            beepSounds: beepSounds,
            vibrate: vibrate,
            timeUpOption: timeUpOption,
            reminderOption: reminderOption,
            font: font,
            textAnimation: animation)
        switch mode {
        case .current:
            (parent?.slideMenuController()?.mainViewController as? TimerViewController)?.currentOptions = options
        case .new:
            do {
                try TimerOptionsManager.shared.addTimerOptions(&options)
                dismiss(animated: true, completion: nil)
            } catch {
                SCLAlertView().showError("Error".localised, subTitle: error.localizedDescription, closeButtonTitle: "OK".localised)
            }
        case .edit:
            do {
                try TimerOptionsManager.shared.updateTimerOptions(from: optionsDisplayed, to: &options)
                performSegue(withIdentifier: "unwindToTimerOptions", sender: nil)
            } catch {
                SCLAlertView().showError("Error".localised, subTitle: error.localizedDescription, closeButtonTitle: "OK".localised)
            }
        }
        
    }
    
    @IBAction func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteTapped() {
        let alert = SCLAlertView()
        alert.addButton("Yes".localised) {
            [weak self] in
            do {
                try (self?.optionsDisplayed).map { try TimerOptionsManager.shared.deleteTimerOptions($0) }
                self?.dismiss(animated: true, completion: nil)
            } catch {
                SCLAlertView().showError("Error".localised, subTitle: error.localizedDescription, closeButtonTitle: "OK".localised)
            }
        }
        alert.showWarning("".localised, subTitle: "Are you sure you want to delete this option?".localised, closeButtonTitle: "No".localised)
    }
}

extension OptionsEditorViewController : DoneTappedRespondable {}
