import UIKit
import LTMorphingLabel
import RxSwift
import RxCocoa
import MaterialComponents
import SwiftyUtils
import SlideMenuControllerSwift
import TabPageViewController
import GoogleMobileAds

class TimerViewController: UIViewController {
    
    @IBOutlet var timerLabel: LTMorphingLabel!
    @IBOutlet var analogClockView: AnalogClockView!
    var playButton: MDCFloatingButton!
    var resetButton: MDCFloatingButton!
    var optionsButton: MDCFloatingButton!
    var modeSelector: UISegmentedControl!
    @IBOutlet var digitalAnalogSelector: UISegmentedControl!
    @IBOutlet var hud: UIView!
    @IBOutlet var setTimerView: SetTimerView!
    @IBOutlet var adBanner: GADBannerView!
    
    var timer = Timer.newCountDownInstance()
    var currentOptions: TimerOptions = .default {
        didSet {
            timer.options = currentOptions
            timerLabel.morphingEffect = currentOptions.textAnimation
            timerLabel.textAttributes![.font] = currentOptions.font.uiFont
            analogClockView.font = currentOptions.font.uiFont
            timerLabel.updateFontSizeToFit()
            timerSoundEffectPlayer.language = currentOptions.language
            timerSoundEffectPlayer.timeUpOption = currentOptions.timeUpOption
            
            if let data = try? JSONEncoder().encode(currentOptions) {
                UserDefaults.standard.set(data, forKey: "lastSavedOptions")
            }
        }
    }
    var disposeBag = DisposeBag()
    
    var hudHidden = false
    var playButtonIsPlay = BehaviorRelay(value: true)
    
    var timerDisposable: Disposable?
    let timerSoundEffectPlayer = TimerSoundEffectPlayer(language: TimerOptions.default.language, timeUpOption: TimerOptions.default.timeUpOption)
    
    
    func setUpView() {
        playButton = MDCFloatingButton(shape: .mini)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.imageView?.tintColor = .white
        playButton.backgroundColor = UIColor(named: "tint")
        hud.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(44).labeled("play button width = 44")
            make.height.equalTo(44).labeled("play button height = 44")
            make.right.equalToSuperview().offset(-8).labeled("play button on the rightmost of the screen")
            make.top.equalToSuperview().offset(8).labeled("play button on the topmost of the screen")
        }
        
        resetButton = MDCFloatingButton(shape: .mini)
        resetButton.setImage(UIImage(systemName: "goforward"), for: .normal)
        resetButton.imageView?.tintColor = .white
        resetButton.backgroundColor = UIColor(named: "tint")
        hud.addSubview(resetButton)
        resetButton.snp.makeConstraints { (make) in
            make.width.equalTo(44).labeled("reset button width = 44")
            make.height.equalTo(44).labeled("reset button height = 44")
            make.right.equalTo(playButton.snp.left).offset(-8).labeled("reset button on the left of play button")
            make.top.equalToSuperview().offset(8).labeled("reset button on the topmost of the screen")
        }
        
        optionsButton = MDCFloatingButton(shape: .mini)
        optionsButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        optionsButton.imageView?.tintColor = .white
        optionsButton.backgroundColor = UIColor(named: "tint")
        hud.addSubview(optionsButton)
        optionsButton.snp.makeConstraints { (make) in
            make.width.equalTo(44).labeled("options button width = 44")
            make.height.equalTo(44).labeled("options button height = 44")
            make.right.equalTo(resetButton.snp.left).offset(-8).labeled("options button on the left of reset button")
            make.top.equalToSuperview().offset(8).labeled("options button on the topmost of the screen")
        }
        
        modeSelector = UISegmentedControl(items: [
            UIImage(systemName: "timer")!,
            UIImage(systemName: "stopwatch")!,
            UIImage(systemName: "clock")!
        ])
        modeSelector.selectedSegmentIndex = 0
        hud.addSubview(modeSelector)
        modeSelector.snp.makeConstraints { (make) in
            make.right.equalTo(optionsButton.snp.left).offset(-8).labeled("mode selector on the left of options button")
            make.centerY.equalTo(optionsButton.snp.centerY).labeled("mode selector on the same line of options button")
        }
        
        digitalAnalogSelector.setTitle("Digital".localised, forSegmentAt: 0)
        digitalAnalogSelector.setTitle("Analog".localised, forSegmentAt: 1)
        
        adBanner.rootViewController = self
        adBanner.adUnitID = adUnitId
        let request = GADRequest()
        adBanner.load(request)
        
        playButtonIsPlay.distinctUntilChanged().map {
            $0 ? UIImage(systemName: "play.fill") : UIImage(systemName: "pause.fill")
            }.bind(to: playButton.rx.image()).disposed(by: disposeBag)
        
        playButton.rx.tap.subscribe(onNext: {
            self.playButtonIsPlay.accept(!self.playButtonIsPlay.value)
            }).disposed(by: disposeBag)
        resetButton.rx.tap.subscribe(onNext: {
            [weak self] in
            self?.playButtonIsPlay.accept(true)
            self?.timerSoundEffectPlayer.stopPlaying()
            }).disposed(by: disposeBag)
        
        modeSelector.rx.selectedSegmentIndex.subscribe(onNext: {
            [weak self] in
            self?.modeSelectorDidChange(newMode: $0)
            self?.playButtonIsPlay.accept(true)
            }).disposed(by: disposeBag)
        
        optionsButton.rx.tap.subscribe(onNext: {
            [weak self] in
            self?.slideMenuController()?.openRight()
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(modeSelector.rx.selectedSegmentIndex, digitalAnalogSelector.rx.selectedSegmentIndex)
            .map { !($0.0 == 2 && $0.1 == 1) }
            .bind(to: analogClockView.rx.isHidden)
        .disposed(by: disposeBag)
        Observable.combineLatest(modeSelector.rx.selectedSegmentIndex, digitalAnalogSelector.rx.selectedSegmentIndex)
            .map { $0.0 == 2 && $0.1 == 1 }
            .bind(to: timerLabel.rx.isHidden)
        .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        setUpView()
        subscribeToTimer(withInitial: 60)
        
        setTimerView.delegate = self
        
        if let lastSavedOptionsData = UserDefaults.standard.data(forKey: "lastSavedOptions"),
            let lastSavedOptions = try? JSONDecoder().decode(TimerOptions.self, from: lastSavedOptionsData) {
            currentOptions = lastSavedOptions
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerLabel.updateFontSizeToFit()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { (_) in
            self.timerLabel.updateFontSizeToFit()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if hudHidden {
            hudHidden = false
            UIView.animate(withDuration: 0.1) {
                self.hud.alpha = 1
            }
        } else {
            hudHidden = true
            UIView.animate(withDuration: 0.1) {
                self.hud.alpha = 0
            }
        }
    }
    
    func updateTimerLabel(text: String) {
        timerLabel.text = text
        timerLabel.updateFontSizeToFit()
    }
    
    func handleTimerEvent(timerEvent: Timer.Event) {
        updateTimerLabel(text: timerEvent.displayString)
        if timerEvent.ended {
            timerSoundEffectPlayer.performTimeUpAction()
            timerSoundEffectPlayer.vibrate()
            return
        }
        if timerEvent.countDown {
            timerSoundEffectPlayer.countSecond(timerEvent.state)
        } else if let reminder = timerEvent.reminder {
            if case .regularInterval = currentOptions.reminderOption {
                timerSoundEffectPlayer.remind(reminder, timerMode: timer.mode, remindTime: timerEvent.state)
            } else {
                timerSoundEffectPlayer.remind(reminder, timerMode: timer.mode)
            }
        } else if timerEvent.countSeconds {
            timerSoundEffectPlayer.countSecond(timerEvent.state)
        }
        if timerEvent.beep {
            timerSoundEffectPlayer.beep()
        }
    }
    
    func subscribeToTimer(withInitial initial: Int) {
        updateTimerLabel(text: timer.displayString(forState: initial))
        timerDisposable = timer.events(initial: initial,
                pause: playButton.rx.tap.asObservable(),
                reset: resetButton.rx.tap.asObservable(),
                scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self]
            timerEvent in
            self?.handleTimerEvent(timerEvent: timerEvent)
        })
    }
    
    func modeSelectorDidChange(newMode: Int) {
        timerDisposable?.dispose()
        switch newMode {
        case 0:
            timer = Timer.newCountDownInstance(options: currentOptions)
            setTimerView.isHidden = false
            digitalAnalogSelector.isHidden = true
            subscribeToTimer(withInitial: 60)
        case 1:
            timer = Timer.newCountUpInstance(options: currentOptions)
            setTimerView.isHidden = true
            digitalAnalogSelector.isHidden = true
            subscribeToTimer(withInitial: 0)
        case 2:
            timer = Timer.newClockInstance(options: currentOptions)
            setTimerView.isHidden = true
            digitalAnalogSelector.isHidden = false
            subscribeToTimer(withInitial: -1)
        default:
            fatalError()
        }
    }
    
    func newOptions() {
        performSegue(withIdentifier: "newOptions", sender: TimerOptions.default)
    }
    
    func editOptions(_ timerOptions: TimerOptions) {
        performSegue(withIdentifier: "editOptions", sender: timerOptions)
    }
    
    @IBAction func unwindFromTimerOptions(_ segue: UIStoryboardSegue) {
        currentOptions.synchroniseWithRealmObject()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?
                .topViewController as? OptionsEditorViewController,
            let options = sender as? TimerOptions {
            if segue.identifier == "newOptions" {
                vc.mode = .new
            } else if segue.identifier == "editOptions" {
                vc.mode = .edit
            }
            vc.optionsDisplayed = options
        }
    }
}

extension TimerViewController : SetTimerViewDelegate {
    func didSetTimer(setTimerView: SetTimerView, setTime: Int) {
        timerDisposable?.dispose()
        subscribeToTimer(withInitial: setTime)
        self.playButtonIsPlay.accept(true)
        timerSoundEffectPlayer.stopPlaying()
    }
}

extension TimerViewController : SlideMenuControllerDelegate {
    func rightWillOpen() {
        let tabItems = (slideMenuController()?.rightViewController as? TabPageViewController)?.tabItems
        (tabItems?[0].viewController as? OptionsEditorViewController)?
            .optionsDisplayed = currentOptions
        let optionsListVC = tabItems?[1].viewController as? TimerOptionsListViewController
        optionsListVC?.selectedOptions = currentOptions
        optionsListVC?.reloadData()
        if !UserDefaults.standard.bool(forKey: "tipShown") {
            (slideMenuController() as? MySlideViewController)?.addArrowTip()
        }
    }
}
