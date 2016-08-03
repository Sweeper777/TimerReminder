import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import RWDropdownMenu

class TimerViewController: UIViewController, LTMorphingLabelDelegate {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!
    @IBOutlet var playButton: UIBarButtonItem!
    
    var shortFontSize: CGFloat!
    var longFontSize: CGFloat!
    
    var initializedFontSizes = false
    
//    var labelSize: CGSize {
//        let original = timerLabel.bounds.size
//        return CGSize(width: original.width - 50, height: original.height)
//    }

    override func viewDidLoad() {
        timerLabel.delegate = self
        timerLabel.morphingEffect = .Evaporate
        timerLabel.morphingEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initializedFontSizes {
            shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
            longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
            timerLabel.font = timerLabel.font.fontWithSize(shortFontSize)
            timer = CountDownTimer(time: 60, onTimerChange: {
                self.timerLabel.text = $0.description
                }, onEnd: nil)
            initializedFontSizes = true
        }
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
        var menuItems = [
            RWDropdownMenuItem(text: NSLocalizedString("Choose Timer", comment: ""), image: UIImage(named: "choose")) {
                
            },
            RWDropdownMenuItem(text: NSLocalizedString("Add New Timer", comment: ""), image: UIImage(named: "add")) {
                
            }
        ]
        
        if timer.canBeSet {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Set Timer", comment: ""), image: UIImage(named: "timer")) {
                self.performSegueWithIdentifier("showSetTimer", sender: self)
                })
        }
        
        if timer is CountDownTimer {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Stopwatch Mode", comment: ""), image: UIImage(named: "countup")) {
                self.timer = CountUpTimer {
                    self.timer.reset()
                    self.playButton.image = UIImage(named: "play")
                    self.timerLabel.text = $0.description
                }
            })
        } else if timer is CountUpTimer {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Timer Mode", comment: ""), image: UIImage(named: "countdown")) {
                self.timer.reset()
                self.playButton.image = UIImage(named: "play")
                self.timer = CountDownTimer(time: 60, onTimerChange: {
                    self.timerLabel.text = $0.description
                    }, onEnd: nil)
                })
        }
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Right, style: .Translucent, navBarImage: nil, completion: nil)
    }
    
    @IBAction func unwindFromSetTimer(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SetTimerController {
            if vc.selectedTimeInterval! >= 3601 {
                timerLabel.font = timerLabel.font.fontWithSize(longFontSize)
            } else {
                timerLabel.font = timerLabel.font.fontWithSize(shortFontSize)
            }
            
            timer = CountDownTimer(time: vc.selectedTimeInterval!, onTimerChange: {
                self.timerLabel.text = $0.description
                }, onEnd: nil)
            timerLabel.font = timerLabel.font.fontWithSize(timer.hasLongDescription ? longFontSize : shortFontSize)
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let textCache = timerLabel.text
        timerLabel.text = "00:00"
        shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        timerLabel.font = timerLabel.font.fontWithSize(timer.hasLongDescription ? longFontSize : shortFontSize)
        timerLabel.text = textCache
    }
}