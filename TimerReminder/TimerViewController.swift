import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import RWDropdownMenu
import ASToast
import ISHHoverBar
import CoreData
import GoogleMobileAds

class TimerViewController: UIViewController, LTMorphingLabelDelegate, UIGestureRecognizerDelegate, GlobalSettingsControllerDelegate {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var timer: Timer!
    
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var restartButton: UIBarButtonItem!
    @IBOutlet var moreButton: UIBarButtonItem!
    
    @IBOutlet var addSettingRecog: UITapGestureRecognizer!
    @IBOutlet var mySettingsRecog: UISwipeGestureRecognizer!
    @IBOutlet var setTimerRecog: UISwipeGestureRecognizer!
    @IBOutlet var edgePanRecog: UIScreenEdgePanGestureRecognizer!
    @IBOutlet var hoverBar: ISHHoverBar!
    
    @IBOutlet var ad: GADBannerView!
    
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
        timerLabel.morphingEffect = LTMorphingEffect(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("timerAnimation"))!
        timerLabel.morphingEnabled = true
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        if let url = NSUserDefaults.standardUserDefaults().URLForKey("selectedSetting"),
            let oid = context.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(url) {
            let object = try? context.existingObjectWithID(oid)
            appliedOptions = object as! TimerOptions?
        }
        
        view.addGestureRecognizer(addSettingRecog)
        view.addGestureRecognizer(mySettingsRecog)
        view.addGestureRecognizer(setTimerRecog)
        
        let gestureEnabled = NSUserDefaults.standardUserDefaults().boolForKey("gestureControl")
        addSettingRecog.enabled = gestureEnabled
        setTimerRecog.enabled = gestureEnabled
        mySettingsRecog.enabled = gestureEnabled
        
        let nightMode = NSUserDefaults.standardUserDefaults().boolForKey("nightMode")
        view.backgroundColor = nightMode ? UIColor.blackColor() : UIColor.whiteColor()
        timerLabel.textColor = nightMode ? UIColor.whiteColor() : UIColor.blackColor()
        
        let fontStyle = NSUserDefaults.standardUserDefaults().integerForKey("fontStyle") == 1 ? "" : "-Thin"
        timerLabel.font = UIFont(name: "SFUIDisplay\(fontStyle)", size: 16)
        let textCache = timerLabel.text
        shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        timerLabel.text = ""
        
        timerLabel.font = timerLabel.font.fontWithSize(shortFontSize)
        timerLabel.text = textCache
        
        hoverBar.orientation = .Horizontal
        hoverBar.items = [restartButton, playButton, moreButton]
        
        ad.adUnitID = adUnitID
        ad.rootViewController = self
        ad.loadRequest(getAdRequest())
        view.bringSubviewToFront(ad)
    }
    
    override func viewDidAppear(animated: Bool) {
        let newShortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        let newLongFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        
        if !(shortFontSize == newShortFontSize && longFontSize == newLongFontSize) {
            shortFontSize = newShortFontSize
            longFontSize = newLongFontSize
            
            let textCache = timerLabel.text
            timerLabel.text = ""
            
            timerLabel.font = timerLabel.font.fontWithSize(timer.hasLongDescription ? longFontSize : shortFontSize)
            timerLabel.text = textCache
        }
        
        if timer is Clock {
            self.timer.reset()
            self.playButton.image = UIImage(named: "play")
            self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
        }
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
    
    @IBAction func pan(sender: AnyObject) {
        
    }
    
    @IBAction func play(sender: UIBarButtonItem) {
        if timer.ended {
            return
        }
        
        if timer.paused {
            playButton.image = UIImage(named: "pause")
            timer.start()
        } else {
            playButton.image = UIImage(named: "play")
            timer.pause()
        }
        hoverBar.items = [restartButton, playButton, moreButton]
    }
    
    @IBAction func restart(sender: UIBarButtonItem) {
        timer.reset()
        playButton.image = UIImage(named: "play")
        hoverBar.items = [restartButton, playButton, moreButton]
    }
    
    @IBAction func more(sender: AnyObject) {
        var menuItems = [
            RWDropdownMenuItem(text: NSLocalizedString("My Timer Settings", comment: ""), image: UIImage(named: "choose")) {
                self.performSegueWithIdentifier("showChooseTimerSettings", sender: self)
                
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
        
        func addStopwatchModeBtn() {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Stopwatch Mode", comment: ""), image: UIImage(named: "countup")) {
                [weak self] in
                self?.timer.reset()
                self?.playButton.image = UIImage(named: "play")
                self?.timer = CountUpTimer(options: self?.appliedOptions, onTimerChange: self?.timerChangedClosure)
                })
        }
        
        func addTimerModeBtn() {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Timer Mode", comment: ""), image: UIImage(named: "countdown")) {
                [weak self] in
                self?.timer.reset()
                self?.playButton.image = UIImage(named: "play")
                self?.timer = CountDownTimer(time: 60, options: self?.appliedOptions, onTimerChange: self?.timerChangedClosure, onEnd: nil)
                })
        }
        
        func addClockModeBtn() {
            menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Switch to Clock Mode", comment: ""), image: UIImage(named: "clock")) {
                [weak self] in
                self?.timer.reset()
                self?.playButton.image = UIImage(named: "play")
                self?.timer = Clock(options: self?.appliedOptions, onTimerChange: self?.timerChangedClosure)
                })
        }
        
        if timer is CountDownTimer {
            addStopwatchModeBtn()
            addClockModeBtn()
        } else if timer is CountUpTimer {
            addTimerModeBtn()
            addClockModeBtn()
        } else if timer is Clock {
            addTimerModeBtn()
            addStopwatchModeBtn()
        }
        
        menuItems.append(RWDropdownMenuItem(text: NSLocalizedString("Global Settings", comment: ""), image: UIImage(named: "settings")) {
            [unowned self] in
            self.performSegueWithIdentifier("showSettings", sender: self)
            })
        
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
                if vc.options.inserted {
                    NSUserDefaults.standardUserDefaults().setURL(self.timer.options!.objectID.URIRepresentation(), forKey: "selectedSetting")
                }
            }
        }
    }
    
    @IBAction func unwindFromSettingsSelector(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SettingSelectorController {
            self.appliedOptions = vc.selectedOption
            self.timer.options = vc.selectedOption ?? TimerOptions.defaultOptions
            self.view.makeToast(NSLocalizedString("Settings applied", comment: ""), backgroundColor: nil)
            NSUserDefaults.standardUserDefaults().setURL(self.timer.options!.objectID.URIRepresentation(), forKey: "selectedSetting")
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? DataPasserController {
            vc.selectedOption = self.appliedOptions?.objectID.temporaryID == false ? self.appliedOptions : nil
            vc.settingsDelegate = self
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if hoverBar.alpha == 0 {
            UIView.animateWithDuration(0.2) {
                self.hoverBar.alpha = 1
                self.ad.alpha = 1
            }
            return
        }
        if !touches.contains({
            touch -> Bool in
            let point = touch.locationInView(self.hoverBar)
            let point2 = touch.locationInView(self.ad)
            return self.hoverBar.bounds.contains(point) || self.ad.bounds.contains(point2)
        }) {
            UIView.animateWithDuration(0.2) {
                self.hoverBar.alpha = 0
                self.ad.alpha = 0
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == edgePanRecog {
            return false
        }
        return true
    }
    
    func globalSettings(globalSettings: GlobalSettingsController, globalSettingsDidChangeWithKey key: String, newValue: AnyObject) {
        if key == "gestureControl" {
            let value = newValue as! Bool
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
            self.addSettingRecog.enabled = value
            self.setTimerRecog.enabled = value
            self.mySettingsRecog.enabled = value
        } else if key == "fontStyle" {
            let value = (newValue as! String) == "Regular" ? 1 : 0
            NSUserDefaults.standardUserDefaults().setInteger(value, forKey: key)
            let fontStyle = value == 1 ? "" : "-Thin"
            timerLabel.font = UIFont(name: "SFUIDisplay\(fontStyle)", size: 16)
            let textCache = timerLabel.text
            shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
            longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
            timerLabel.text = ""
            
            timerLabel.font = timerLabel.font.fontWithSize(timer.hasLongDescription ? longFontSize : shortFontSize)
            timerLabel.text = textCache
        } else if key == "timerAnimation" {
            let value = newValue as! Int
            NSUserDefaults.standardUserDefaults().setInteger(value, forKey: key)
            timerLabel.morphingEffect = LTMorphingEffect(rawValue: value)!
        } else if key == "nightMode" {
            let value = newValue as! Bool
            NSUserDefaults.standardUserDefaults().setBool(value, forKey: key)
            view.backgroundColor = value ? UIColor.blackColor() : UIColor.whiteColor()
            timerLabel.textColor = value ? UIColor.whiteColor() : UIColor.blackColor()
        }
    }
}