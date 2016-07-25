import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import RWDropdownMenu

class TimerViewController: UIViewController {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!

    override func viewDidLoad() {
//        timerLabel.morphingDuration = 0.2
        timerLabel.morphingEffect = .Fall
        timerLabel.fontSizeToFit()
        timerLabel.morphingEnabled = true
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