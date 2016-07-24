import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions

class TimerViewController: UIViewController {
    @IBOutlet var timerLabel: LTMorphingLabel!

    override func viewDidLoad() {
        timerLabel.morphingEnabled = false
//        timerLabel.morphingDuration = 0.2
        timerLabel.text = "00:00"
        timerLabel.morphingEffect = .Fall
        timerLabel.fontSizeToFit()
        timerLabel.morphingEnabled = true
        NSTimer.runThisAfterDelay(seconds: 1) {
            self.timerLabel.text = "00:01"
        }
        NSTimer.runThisAfterDelay(seconds: 2) {
            self.timerLabel.text = "00:02"
        }
        NSTimer.runThisAfterDelay(seconds: 3) {
            self.timerLabel.text = "00:03"
        }
        NSTimer.runThisAfterDelay(seconds: 4) {
            self.timerLabel.text = "00:04"
        }
    }
}