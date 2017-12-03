import UIKit
import LTMorphingLabel
import FittableFontLabel
import ASToast
import CoreData
import GoogleMobileAds
import MLScreenshot
import SlideMenuControllerSwift
import NGORoundedButton
import FTPopOverMenu_Swift
import EZClockView
import MaterialComponents

class TimerViewController: UIViewController, LTMorphingLabelDelegate, UIGestureRecognizerDelegate, GlobalSettingsControllerDelegate, SlideMenuControllerDelegate {
    @IBOutlet var timerLabel: LTMorphingLabel!
    var clock: EZClockView?
    var timer: Timer! {
        didSet {
            if timer is Clock && UserDefaults.standard.bool(forKey: "analogClock") {
                if clock == nil {
                    clock = EZClockView(frame: timerLabel.frame)
                }
                clock?.secondsThickness = 0
                clock?.minutesLength = 0.75
                clock?.hoursLength = 0.5
                clock?.minutes = (timer as! Clock).time.minute
                clock?.hours = (timer as! Clock).time.hour
                clock?.isUserInteractionEnabled = false
                timerLabel.isHidden = true
                view.addSubview(clock!)
            } else {
                clock?.removeFromSuperview()
                clock = nil
                timerLabel.isHidden = false
            }
        }
    }
    
    var playButton: MDCFloatingButton!
    var restartButton: MDCFloatingButton!
    var moreButton: MDCFloatingButton!
    var screenshotButton: MDCFloatingButton!
    
    @IBOutlet var addSettingRecog: UITapGestureRecognizer!
    @IBOutlet var mySettingsRecog: UISwipeGestureRecognizer!
    @IBOutlet var setTimerRecog: UISwipeGestureRecognizer!
    @IBOutlet var edgePanRecog: UIScreenEdgePanGestureRecognizer!
    @IBOutlet var changeModeRecog: UISwipeGestureRecognizer!
    @IBOutlet var changePreviousModeRecog: UISwipeGestureRecognizer!
    @IBOutlet var hoverBar: UIView!
    
    @IBOutlet var ad: GADBannerView!
    
    var shortFontSize: CGFloat!
    var longFontSize: CGFloat!
    
    var initializedFontSizes = false
    
    var appliedOptions: TimerOptions?
    
    fileprivate lazy var timerChangedClosure: (Timer) -> Void = {
        [weak self] timer in
        self!.timerLabel.text = timer.description
        if timer is Clock {
            self?.clock?.minutes = (timer as! Clock).time.minute
            self?.clock?.hours = (timer as! Clock).time.hour
        }
    }
    
    //    var labelSize: CGSize {
    //        let original = timerLabel.bounds.size
    //        return CGSize(width: original.width - 50, height: original.height)
    //    }
    
    override func viewDidLoad() {
        playButton = MDCFloatingButton(shape: .largeIcon)
        playButton.frame = playButton.frame.with(width: 44).with(height: 44)
        playButton.x = 94
        playButton.backgroundColor = UIColor(hex: "5abb5a")
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        
        restartButton = MDCFloatingButton(shape: .largeIcon)
        restartButton.frame = restartButton.frame.with(width: 44).with(height: 44)
        restartButton.x = 47
        restartButton.backgroundColor = UIColor(hex: "5abb5a")
        restartButton.setImage(#imageLiteral(resourceName: "restart"), for: .normal)
        restartButton.addTarget(self, action: #selector(restart), for: .touchUpInside)
        
        moreButton = MDCFloatingButton(shape: .largeIcon)
        moreButton.frame = moreButton.frame.with(width: 44).with(height: 44)
        moreButton.x = 141
        moreButton.backgroundColor = UIColor(hex: "5abb5a")
        moreButton.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        moreButton.addTarget(self, action: #selector(more), for: .touchUpInside)
        
        screenshotButton = MDCFloatingButton(shape: .largeIcon)
        screenshotButton.frame = screenshotButton.frame.with(width: 44).with(height: 44)
        screenshotButton.backgroundColor = UIColor(hex: "5abb5a")
        screenshotButton.setImage(#imageLiteral(resourceName: "camera"), for: .normal)
        screenshotButton.addTarget(self, action: #selector(screenshot), for: .touchUpInside)
        
        timerLabel.delegate = self
        timerLabel.morphingEffect = LTMorphingEffect(rawValue: UserDefaults.standard.integer(forKey: "timerAnimation"))!
        timerLabel.morphingEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        if let url = UserDefaults.standard.url(forKey: "selectedSetting"),
            let oid = context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url) {
            let object = try? context.existingObject(with: oid)
            appliedOptions = object as! TimerOptions?
        }
        
        view.addGestureRecognizer(addSettingRecog)
        view.addGestureRecognizer(mySettingsRecog)
        view.addGestureRecognizer(setTimerRecog)
        view.addGestureRecognizer(changeModeRecog)
        view.addGestureRecognizer(changePreviousModeRecog)
        
        let gestureEnabled = UserDefaults.standard.bool(forKey: "gestureControl")
        addSettingRecog.isEnabled = gestureEnabled
        setTimerRecog.isEnabled = gestureEnabled
        mySettingsRecog.isEnabled = gestureEnabled
        changePreviousModeRecog.isEnabled = gestureEnabled
        changeModeRecog.isEnabled = gestureEnabled
        
        let nightMode = UserDefaults.standard.bool(forKey: "nightMode")
        view.backgroundColor = nightMode ? UIColor.black : UIColor.white
        timerLabel.textColor = nightMode ? UIColor.white : UIColor.black
        
        let fontStyle = FontStyle(rawValue: UserDefaults.standard.integer(forKey: "fontStyle"))
        if fontStyle!.rawValue > 3 {
            timerLabel.font = UIFont(name: "\(fontStyle!)", size: 16)
        } else {
            timerLabel.font = UIFont(name: "SFUIDisplay-\(fontStyle!)", size: 16)
        }
        let textCache = timerLabel.text
        shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        timerLabel.text = ""
        
        timerLabel.font = timerLabel.font.withSize(shortFontSize)
        timerLabel.text = textCache
        
        hoverBar.addSubview(screenshotButton)
        hoverBar.addSubview(restartButton)
        hoverBar.addSubview(playButton)
        hoverBar.addSubview(moreButton)
        
        ad.adUnitID = adUnitID
        ad.rootViewController = self
        ad.load(getAdRequest())
        view.bringSubview(toFront: ad)
        
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else { return }
            self.slideMenuController()!.delegate = self
            self.slideMenuController()!.rightPanGesture?.maximumNumberOfTouches = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let newShortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        let newLongFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        
        if !(shortFontSize == newShortFontSize && longFontSize == newLongFontSize) {
            shortFontSize = newShortFontSize
            longFontSize = newLongFontSize
            
            let textCache = timerLabel.text
            timerLabel.text = ""
            
            timerLabel.font = timerLabel.font.withSize(timer.hasLongDescription ? longFontSize : shortFontSize)
            timerLabel.text = textCache
        }
        
        if timer is Clock {
            self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initializedFontSizes {
            shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
            longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
            timerLabel.font = timerLabel.font.withSize(shortFontSize)
            timer = CountDownTimer(time: 60, options: appliedOptions, onTimerChange: timerChangedClosure, onEnd: nil)
            initializedFontSizes = true
        }
    }
    
    @IBAction func pan(_ sender: AnyObject) {
        
    }
    
    @IBAction func play() {
        if timer.ended {
            return
        }
        
        if timer.paused {
            playButton.customImage = UIImage(named: "pause")
            timer.start()
        } else {
            playButton.customImage = UIImage(named: "play")
            timer.pause()
        }
    }
    
    @IBAction func restart(_ sender: UIBarButtonItem) {
        timer.reset()
        playButton.customImage = UIImage(named: "play")
    }
    
    @IBAction func screenshot() {
        UIView.animate(withDuration: 0.2, animations: {
            self.hoverBar.alpha = 0
            self.ad.alpha = 0
        })
        _ = Foundation.Timer.after(0.2) {
            self.performSegue(withIdentifier: "showScreenshotPreview", sender: self)
            if !self.timer.paused {
                self.play()
            }
        }
    }
    
    @IBAction func more(_ sender: AnyObject) {
        var menuItems = ["My Timer Settings", "Add New Timer Settings"]
        var images = ["choose", "add"]
        if self.timer.canBeSet {
            menuItems.append("Set Timer")
            images.append("timer")
        }
        if timer is CountDownTimer {
            menuItems.append("Switch to Stopwatch Mode")
            menuItems.append("Switch to Clock Mode")
            images.append("countup")
            images.append("clock")
        } else if timer is CountUpTimer {
            menuItems.append("Switch to Timer Mode")
            menuItems.append("Switch to Clock Mode")
            images.append("countdown")
            images.append("clock")
        } else if timer is Clock {
            menuItems.append("Switch to Timer Mode")
            menuItems.append("Switch to Stopwatch Mode")
            images.append("countdown")
            images.append("countup")
        }
        menuItems.append("Global Settings")
        images.append("settings")
        let widths = menuItems.map { (NSLocalizedString($0, comment: "") as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width }
        let menuWidth = widths.max()! + 70
        let config = FTConfiguration.shared
        config.menuWidth = menuWidth
        config.backgoundTintColor = #colorLiteral(red: 0.8242458767, green: 0.8242458767, blue: 0.8242458767, alpha: 1)
        config.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        FTPopOverMenu.showForSender(sender: moreButton, with: menuItems.map { NSLocalizedString($0, comment: "") }, menuImageArray: images, done: { index in
            let item = menuItems[index]
            switch item {
            case "My Timer Settings":
                self.performSegue(withIdentifier: "showChooseTimerSettings", sender: self)
            case "Add New Timer Settings":
                self.performSegue(withIdentifier: "showTimerForm", sender: self)
            case "Set Timer":
                self.performSegue(withIdentifier: "showSetTimer", sender: self)
            case "Switch to Clock Mode":
                self.timer.reset()
                self.playButton.customImage = UIImage(named: "play")
                self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
            case "Switch to Stopwatch Mode":
                self.timer.reset()
                self.playButton.customImage = UIImage(named: "play")
                self.timer = CountUpTimer(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
                
            case "Switch to Timer Mode":
                self.timer.reset()
                self.playButton.customImage = UIImage(named: "play")
                self.timer = CountDownTimer(time: 60, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)
                
            case "Global Settings":
                self.performSegue(withIdentifier: "showSettings", sender: self)
            default:
                break
            }
        }, cancel: {})
    }
    
    @IBAction func unwindFromSetTimer(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? SetTimerController {
            playButton.customImage = UIImage(named: "play")
            if vc.selectedTimeInterval! >= 3601 {
                timerLabel.font = timerLabel.font.withSize(longFontSize)
            } else {
                timerLabel.font = timerLabel.font.withSize(shortFontSize)
            }
            
            timer = CountDownTimer(time: vc.selectedTimeInterval!, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)
            timerLabel.font = timerLabel.font.withSize(timer.hasLongDescription ? longFontSize : shortFontSize)
        }
    }
    
    @IBAction func unwindFromTimerForm(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? TimerFormController {
            if vc.shouldApplyOptions {
                self.timer.options = vc.options
                self.appliedOptions = vc.options
                self.view.makeToast(message: NSLocalizedString("Settings applied", comment: ""), backgroundColor: nil, messageColor: nil)
                if vc.options.isInserted {
                    UserDefaults.standard.set(self.timer.options!.objectID.uriRepresentation(), forKey: "selectedSetting")
                }
            }
        }
    }
    
    @IBAction func unwindFromSettingsSelector(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? SettingSelectorController {
            self.appliedOptions = vc.selectedOption
            self.timer.options = vc.selectedOption ?? TimerOptions.defaultOptions
            self.view.makeToast(message: NSLocalizedString("Settings applied", comment: ""), backgroundColor: nil, messageColor: nil)
            UserDefaults.standard.set(self.timer.options!.objectID.uriRepresentation(), forKey: "selectedSetting")
        }
    }
    
    @IBAction func changeMode() {
        if timer is CountDownTimer {
            self.timer.reset()
            self.playButton.customImage = UIImage(named: "play")
            self.timer = CountUpTimer(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
            //            self.view.makeToast(NSLocalizedString("Changed to Stopwatch Mode", comment: ""), backgroundColor: nil, messageColor: nil)
        } else if timer is CountUpTimer {
            self.timer.reset()
            self.playButton.customImage = UIImage(named: "play")
            self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
            //            self.view.makeToast(NSLocalizedString("Changed to Clock Mode", comment: ""), backgroundColor: nil, messageColor: nil)
        } else if timer is Clock {
            self.timer.reset()
            self.playButton.customImage = UIImage(named: "play")
            self.timer = CountDownTimer(time: 60, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)
            //            self.view.makeToast(NSLocalizedString("Changed to Timer Mode", comment: ""), backgroundColor: nil, messageColor: nil)
        }
    }
    
    @IBAction func changePreviousMode() {
        if timer is Clock {
            self.timer.reset()
            self.playButton.customImage = UIImage(named: "play")
            self.timer = CountUpTimer(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
            //            self.view.makeToast(NSLocalizedString("Changed to Stopwatch Mode", comment: ""), backgroundColor: nil, messageColor: nil)
        } else if timer is CountDownTimer {
            self.timer.reset()
            self.playButton.customImage = UIImage(named: "play")
            self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
            //            self.view.makeToast(NSLocalizedString("Changed to Clock Mode", comment: ""), backgroundColor: nil, messageColor: nil)
        } else if timer is CountUpTimer {
            self.timer.reset()
            self.playButton.customImage = UIImage(named: "play")
            self.timer = CountDownTimer(time: 60, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)
            //            self.view.makeToast(NSLocalizedString("Changed to Timer Mode", comment: ""), backgroundColor: nil, messageColor: nil)
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let textCache = timerLabel.text
        shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        timerLabel.text = ""
        
        timerLabel.font = timerLabel.font.withSize(timer.hasLongDescription ? longFontSize : shortFontSize)
        timerLabel.text = textCache
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DataPasserController {
            vc.selectedOption = self.appliedOptions?.objectID.isTemporaryID == false ? self.appliedOptions : nil
            vc.settingsDelegate = self
            vc.image = self.view.screenshot()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if hoverBar.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.hoverBar.alpha = 1
                self.ad.alpha = 1
            })
            return
        }
        if !touches.contains(where: {
            touch -> Bool in
            let point = touch.location(in: self.hoverBar)
            let point2 = touch.location(in: self.ad)
            return self.hoverBar.bounds.contains(point) || self.ad.bounds.contains(point2)
        }) {
            UIView.animate(withDuration: 0.2, animations: {
                self.hoverBar.alpha = 0
                self.ad.alpha = 0
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == edgePanRecog {
            return false
        }
        return true
    }
    
    func globalSettings(_ globalSettings: GlobalSettingsController, globalSettingsDidChangeWithKey key: String, newValue: Any) {
        if key == "gestureControl" {
            let value = newValue as! Bool
            UserDefaults.standard.set(value, forKey: key)
            self.addSettingRecog.isEnabled = value
            self.setTimerRecog.isEnabled = value
            self.mySettingsRecog.isEnabled = value
            self.changeModeRecog.isEnabled = value
            self.changeModeRecog.isEnabled = value
        } else if key == "fontStyle" {
            let value = newValue as! FontStyle
            UserDefaults.standard.set(value.rawValue, forKey: key)
            if value.rawValue > 3 {
                timerLabel.font = UIFont(name: "\(value)", size: 16)
            } else {
                timerLabel.font = UIFont(name: "SFUIDisplay-\(value)", size: 16)
            }
            let textCache = timerLabel.text
            shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
            longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
            timerLabel.text = ""
            
            timerLabel.font = timerLabel.font.withSize(timer.hasLongDescription ? longFontSize : shortFontSize)
            timerLabel.text = textCache
        } else if key == "timerAnimation" {
            let value = newValue as! Int
            UserDefaults.standard.set(value, forKey: key)
            timerLabel.morphingEffect = LTMorphingEffect(rawValue: value)!
        } else if key == "nightMode" {
            let value = newValue as! Bool
            UserDefaults.standard.set(value, forKey: key)
            view.backgroundColor = value ? UIColor.black : UIColor.white
            timerLabel.textColor = value ? UIColor.white : UIColor.black
        } else if key == "trueTime" || key == "analogClock" {
            UserDefaults.standard.setValue(newValue, forKey: key)
            if self.timer is Clock {
                self.timer = Clock(options: self.timer.options, onTimerChange: timerChangedClosure)
            }
        }
    }
    
    func rightDidOpen() {
        self.slideMenuController()!.rightPanGesture?.isEnabled = false
        (self.slideMenuController()!.rightViewController!.childViewControllers.first! as! CurrentOptionsFormController).syncTimerOptions()
    }
    
    func rightDidClose() {
        self.slideMenuController()!.rightPanGesture?.isEnabled = true
        appliedOptions = (self.slideMenuController()!.rightViewController!.childViewControllers.first! as! CurrentOptionsFormController).processOptions()
        self.timer.options = appliedOptions
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.containsTraits(in: UITraitCollection(horizontalSizeClass: .compact)) {
            self.slideMenuController()?.changeRightViewWidth(self.view.frame.width * 0.9)
        } else {
            self.slideMenuController()?.changeRightViewWidth(self.view.frame.width * 0.5)
        }
    }
}
