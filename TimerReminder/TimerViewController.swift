import UIKit
import LTMorphingLabel
import FittableFontLabel
import EZSwiftExtensions
import ISHHoverBar
import ASToast
import CoreData
import GoogleMobileAds
import DropDown

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
    @IBOutlet var changeModeRecog: UISwipeGestureRecognizer!
    @IBOutlet var changePreviousModeRecog: UISwipeGestureRecognizer!
    @IBOutlet var hoverBar: ISHHoverBar!
    
    @IBOutlet var ad: GADBannerView!
    
    let moreMenu = DropDown()
    
    var shortFontSize: CGFloat!
    var longFontSize: CGFloat!
    
    var initializedFontSizes = false
    
    var appliedOptions: TimerOptions?
    
    fileprivate lazy var timerChangedClosure: (Timer) -> Void = {
        [weak self] timer in
        self!.timerLabel.text = timer.description
    }
    
//    var labelSize: CGSize {
//        let original = timerLabel.bounds.size
//        return CGSize(width: original.width - 50, height: original.height)
//    }

    override func viewDidLoad() {
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
        
        let gestureEnabled = UserDefaults.standard.bool(forKey: "gestureControl")
        addSettingRecog.isEnabled = gestureEnabled
        setTimerRecog.isEnabled = gestureEnabled
        mySettingsRecog.isEnabled = gestureEnabled
        
        let nightMode = UserDefaults.standard.bool(forKey: "nightMode")
        view.backgroundColor = nightMode ? UIColor.black : UIColor.white
        timerLabel.textColor = nightMode ? UIColor.white : UIColor.black
        
        let fontStyle = FontStyle(rawValue: UserDefaults.standard.integer(forKey: "fontStyle"))
        timerLabel.font = UIFont(name: "SFUIDisplay-\(fontStyle!)", size: 16)
        let textCache = timerLabel.text
        shortFontSize = timerLabel.fontSizeThatFits(text: "00:00", maxFontSize: 500)
        longFontSize = timerLabel.fontSizeThatFits(text: "00:00:00", maxFontSize: 500)
        timerLabel.text = ""
        
        timerLabel.font = timerLabel.font.withSize(shortFontSize)
        timerLabel.text = textCache
        
        hoverBar.orientation = .horizontal
        hoverBar.items = [restartButton, playButton, moreButton]
        
        ad.adUnitID = adUnitID
        ad.rootViewController = self
        ad.load(getAdRequest())
        view.bringSubview(toFront: ad)
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
    
    @IBAction func play(_ sender: UIBarButtonItem) {
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
    
    @IBAction func restart(_ sender: UIBarButtonItem) {
        timer.reset()
        playButton.image = UIImage(named: "play")
        hoverBar.items = [restartButton, playButton, moreButton]
    }
    
    @IBAction func more(_ sender: AnyObject) {
        var menuItems = ["My Timer Settings", "Add New Timer Settings"]
        if self.timer.canBeSet {
            menuItems.append("Set Timer")
        }
        if timer is CountDownTimer {
            menuItems.append("Switch to Stopwatch Mode")
            menuItems.append("Switch to Clock Mode")
        } else if timer is CountUpTimer {
            menuItems.append("Switch to Timer Mode")
            menuItems.append("Switch to Clock Mode")
        } else if timer is Clock {
            menuItems.append("Switch to Timer Mode")
            menuItems.append("Switch to Stopwatch Mode")
        }
        menuItems.append("Global Settings")
        
        let widths = menuItems.map { (NSLocalizedString($0, comment: "") as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width }
        print(widths)
        let menuWidth = widths.max()! + 70
        print(menuWidth)
        
        moreMenu.anchorView = hoverBar
        moreMenu.dataSource = menuItems
        moreMenu.width = menuWidth
        moreMenu.cellNib = UINib(nibName: "MoreMenuItem", bundle: nil)
        moreMenu.customCellConfiguration = {
            _, item, cell in
            guard let menuItemCell = cell as? MoreMenuItem else { return }
            menuItemCell.optionLabel.text = NSLocalizedString(item, comment: "")
            switch item {
            case "My Timer Settings":
                menuItemCell.icon.image = UIImage(named: "choose")
            case "Add New Timer Settings":
                menuItemCell.icon.image = UIImage(named: "add")
            case "Set Timer":
                menuItemCell.icon.image = UIImage(named: "timer")
            case "Switch to Clock Mode":
                menuItemCell.icon.image = UIImage(named: "clock")
            case "Switch to Stopwatch Mode":
                menuItemCell.icon.image = UIImage(named: "countup")
            case "Switch to Timer Mode":
                menuItemCell.icon.image = UIImage(named: "countdown")
            case "Global Settings":
                menuItemCell.icon.image = UIImage(named: "settings")
            default:
                break
            }
        }
        
        moreMenu.selectionAction = {
            [unowned self] index, item in
            switch item {
            case "My Timer Settings":
                self.performSegue(withIdentifier: "showChooseTimerSettings", sender: self)
            case "Add New Timer Settings":
                self.performSegue(withIdentifier: "showTimerForm", sender: self)
            case "Set Timer":
                self.performSegue(withIdentifier: "showSetTimer", sender: self)
            case "Switch to Clock Mode":
                self.timer.reset()
                self.playButton.image = UIImage(named: "play")
                self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
            case "Switch to Stopwatch Mode":
                self.timer.reset()
                self.playButton.image = UIImage(named: "play")
                self.timer = CountUpTimer(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)

            case "Switch to Timer Mode":
                self.timer.reset()
                self.playButton.image = UIImage(named: "play")
                self.timer = CountDownTimer(time: 60, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)

            case "Global Settings":
                self.performSegue(withIdentifier: "showSettings", sender: self)
            default:
                break
            }
        }
        
        moreMenu.show()
    }
    
    @IBAction func unwindFromSetTimer(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? SetTimerController {
            playButton.image = UIImage(named: "play")
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
                self.view.makeToast(NSLocalizedString("Settings applied", comment: ""), backgroundColor: nil)
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
            self.view.makeToast(NSLocalizedString("Settings applied", comment: ""), backgroundColor: nil)
            UserDefaults.standard.set(self.timer.options!.objectID.uriRepresentation(), forKey: "selectedSetting")
        }
    }
    
    @IBAction func changeMode() {
        if timer is CountDownTimer {
            self.timer.reset()
            self.playButton.image = UIImage(named: "play")
            self.timer = CountUpTimer(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
        } else if timer is CountUpTimer {
            self.timer.reset()
            self.playButton.image = UIImage(named: "play")
            self.timer = Clock(options: self.appliedOptions, onTimerChange: self.timerChangedClosure)
        } else if timer is Clock {
            self.timer.reset()
            self.playButton.image = UIImage(named: "play")
            self.timer = CountDownTimer(time: 60, options: self.appliedOptions, onTimerChange: self.timerChangedClosure, onEnd: nil)
        }
    }
    
    @IBAction func changePreviousMode() {
        
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
        } else if key == "fontStyle" {
            let value = newValue as! FontStyle
            UserDefaults.standard.set(value.rawValue, forKey: key)
            timerLabel.font = UIFont(name: "SFUIDisplay-\(value)", size: 16)
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
        }
    }
}
