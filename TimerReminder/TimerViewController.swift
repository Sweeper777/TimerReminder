import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions

class TimerViewController: UIViewController {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!

    override func viewDidLoad() {
//        timerLabel.morphingDuration = 0.2
        timerLabel.morphingEffect = .Fall
        timerLabel.fontSizeToFit()
        timerLabel.morphingEnabled = true
    }
}