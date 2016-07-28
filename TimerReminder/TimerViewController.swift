import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import RWDropdownMenu

class TimerViewController: UIViewController, LTMorphingLabelDelegate {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!
    @IBOutlet var playButton: UIBarButtonItem!
    
    var labelSize: CGSize {
        let original = timerLabel.bounds.size
        return CGSize(width: original.width - 50, height: original.height)
    }

    override func viewDidLoad() {
        timerLabel.delegate = self
        timerLabel.morphingEffect = .Evaporate
        timerLabel.fontSizeToFit(rectSize: labelSize)
        timerLabel.morphingEnabled = true
        
        timer = CountDownTimer(time: 5, onTimerChange: {
            self.timerLabel.text = $0.description
//            self.timerLabel.fontSizeToFit()
        }, onEnd: nil)
    }
    
    @IBAction func play(sender: UIBarButtonItem) {
        if timer.ended {
            return
        }
        
        if timer.paused {
            sender.image = UIImage(named: "pause")
            timer.start()
        } else {
            sender.image = UIImage(named: "play")
            timer.pause()
        }
    }
    
    @IBAction func restart(sender: UIBarButtonItem) {
        timer.reset()
        playButton.image = UIImage(named: "play")
    }
    
    @IBAction func more(sender: AnyObject) {
        let menuItems = [
            RWDropdownMenuItem(text: NSLocalizedString("Choose Timer", comment: ""), image: UIImage(named: "choose")) {
                
            },
            RWDropdownMenuItem(text: NSLocalizedString("Add New Timer", comment: ""), image: UIImage(named: "add")) {
                
            },
            RWDropdownMenuItem(text: NSLocalizedString("Set Timer", comment: ""), image: UIImage(named: "timer")) {
                self.performSegueWithIdentifier("showSetTimer", sender: self)
            }
        ]
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Right, style: .Translucent, navBarImage: nil, completion: nil)
    }
    
    @IBAction func unwindFromSetTimer(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SetTimerController {
            timer = CountDownTimer(time: vc.selectedTimeInterval!, onTimerChange: {
                self.timerLabel.text = $0.description
//                self.timerLabel.fontSizeToFit()
                }, onEnd: nil)
            timerLabel.fontSizeToFit(rectSize: labelSize)
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        timerLabel.fontSizeToFit(rectSize: labelSize)
    }
}