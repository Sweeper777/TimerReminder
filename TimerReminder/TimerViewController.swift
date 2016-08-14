import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import RWDropdownMenu
import ASToast

class TimerViewController: UIViewController, LTMorphingLabelDelegate {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!
    @IBOutlet var playButton: UIBarButtonItem!
    
    var shortFontSize: CGFloat!
    var longFontSize: CGFloat!
    
    var initializedFontSizes = false
    
    var appliedOptions: TimerOptions?
    
    private lazy var timerChangedClosure: (Timer) -> Void = {
        [weak self] timer in
        self!.timerLabel.text = timer.description
    }
    
//    var labelSize: CGSize {
//        let original = timerLabel.bounds.size
//        return CGSize(width: original.width - 50, height: original.height)
//    }

    override func viewDidLoad() {
        timerLabel.delegate = self
        timerLabel.morphingEffect = .Evaporate
        timerLabel.morphingEnabled = true
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initializedFontSizes {
            shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
            longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
            timerLabel.font = timerLabel.font.fontWithSize(shortFontSize)
            timer = CountDownTimer(time: 60, options: appliedOptions, onTimerChange: timerChangedClosure, onEnd: nil)
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
            RWDropdownMenuItem(text: NSLocalizedString("Select Timer Settings", comment: ""), image: UIImage(named: "choose")) {
                
            },
            RWDropdownMenuItem(text: NSLocalizedString("Add New Timer Settings", comment: ""), image: UIImage(named: "add")) {
                [weak self] in
                self?.performSegueWithIdentifier("showTimerForm", sender: self)
            }
        ]
        
        if timer.canBeSet {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Set Timer", comment: ""), image: UIImage(named: "timer")) {
                [weak self] in
                self?.performSegueWithIdentifier("showSetTimer", sender: self)
                })
        }
        
        if timer is CountDownTimer {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Stopwatch Mode", comment: ""), image: UIImage(named: "countup")) {
                [weak self] in
                self?.timer.reset()
                self?.playButton.image = UIImage(named: "play")
                self?.timer = CountUpTimer(options: self?.appliedOptions, onTimerChange: self?.timerChangedClosure)
            })
        } else if timer is CountUpTimer {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Timer Mode", comment: ""), image: UIImage(named: "countdown")) {
                [weak self] in
                self?.timer.reset()
                self?.playButton.image = UIImage(named: "play")
                self?.timer = CountDownTimer(time: 60, options: self?.appliedOptions, onTimerChange: self?.timerChangedClosure, onEnd: nil)
            })
        }
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Right, style: .Translucent, navBarImage: nil, completion: nil)
    }
    
    @IBAction func unwindFromSetTimer(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SetTimerController {
            playButton.image = UIImage(named: "play")
            if vc.selectedTimeInterval! >= 3601 {
                timerLabel.font = timerLabel.font.fontWithSize(longFontSize)
            } else {
                timerLabel.font = timerLabel.font.fontWithSize(shortFontSize)
            }
            
            timer = CountDownTimer(time: vc.selectedTimeInterval!, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)
            timerLabel.font = timerLabel.font.fontWithSize(timer.hasLongDescription ? longFontSize : shortFontSize)
        }
    }
    
    @IBAction func unwindFromTimerForm(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? TimerFormController {
            if vc.shouldApplyOptions {
                self.timer.options = vc.options
                self.appliedOptions = vc.options
                self.view.makeToast(NSLocalizedString("Settings applied", comment: ""), backgroundColor: nil)
            }
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let textCache = timerLabel.text
        shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        timerLabel.text = ""
        
        timerLabel.font = timerLabel.font.fontWithSize(timer.hasLongDescription ? longFontSize : shortFontSize)
        timerLabel.text = textCache
    }
}