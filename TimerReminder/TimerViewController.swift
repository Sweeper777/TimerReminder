import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import RWDropdownMenu

class TimerViewController: UIViewController {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!

    override func viewDidLoad() {
        timerLabel.morphingEffect = .Fall
        timerLabel.fontSizeToFit()
        timerLabel.morphingEnabled = true
        
        timer = CountDownTimer(time: 90, onTimerChange: {
            self.timerLabel.text = $0.description
            self.timerLabel.fontSizeToFit()
            print(self.timerLabel.font.fontName)
        }, onEnd: nil)
        timer.start()
    }
    
    @IBAction func more(sender: AnyObject) {
        let menuItems = [
            RWDropdownMenuItem(text: NSLocalizedString("Choose Timer", comment: ""), image: UIImage(named: "choose")) {
                
            },
            RWDropdownMenuItem(text: NSLocalizedString("Add New Timer", comment: ""), image: UIImage(named: "add")) {
                
            },
            RWDropdownMenuItem(text: NSLocalizedString("Set Timer", comment: ""), image: UIImage(named: "timer")) {
                
            }
        ]
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Right, style: .Translucent, navBarImage: nil, completion: nil)
    }
}