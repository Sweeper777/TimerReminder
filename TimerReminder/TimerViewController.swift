import UIKit
import LTMorphingLabel
import RxSwift
import RxCocoa
import MaterialComponents
import SwiftyUtils

class TimerViewController: UIViewController {
    
    @IBOutlet var timerLabel: LTMorphingLabel!
    var playButton: MDCFloatingButton!
    var resetButton: MDCFloatingButton!
    var optionsButton: MDCFloatingButton!
    var modeSelector: UISegmentedControl!
    @IBOutlet var hud: UIView!
    @IBOutlet var setTimerView: SetTimerView!
    
    var timer = Timer.newCountDownInstance()
    var currentOptions: TimerOptions = .default {
        didSet {
            timer.options = currentOptions
            timerLabel.morphingEffect = currentOptions.textAnimation
            timerLabel.font = UIFont(name: currentOptions.font.fontName, size: 10)
            timerLabel.updateFontSizeToFit()
            timerSoundEffectPlayer.language = currentOptions.language
            timerSoundEffectPlayer.timeUpOption = currentOptions.timeUpOption
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
        playButton.backgroundColor = UIColor(hex: "5abb5a")
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
        resetButton.backgroundColor = UIColor(hex: "5abb5a")
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
        optionsButton.backgroundColor = UIColor(hex: "5abb5a")
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
    }
    
    override func viewDidLoad() {
        setUpView()
        subscribeToTimer(withInitial: 60)
        
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
        
        setTimerView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerLabel.updateFontSizeToFit()
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
            print("TimerEvent: \(timerEvent.state)")
            if timerEvent.ended {
                print("Ended!")
            }
        })
    }
    
    func modeSelectorDidChange(newMode: Int) {
        timerDisposable?.dispose()
        switch newMode {
        case 0:
            timer = Timer.newCountDownInstance()
            setTimerView.isHidden = false
            subscribeToTimer(withInitial: 60)
        case 1:
            timer = Timer.newCountUpInstance()
            setTimerView.isHidden = true
            subscribeToTimer(withInitial: 0)
        case 2:
            timer = Timer.newClockInstance()
            setTimerView.isHidden = true
            subscribeToTimer(withInitial: -1)
        default:
            fatalError()
        }
    }
}

extension TimerViewController : SetTimerViewDelegate {
    func didSetTimer(setTimerView: SetTimerView, setTime: Int) {
        timerDisposable?.dispose()
        subscribeToTimer(withInitial: setTime)
        self.playButtonIsPlay.accept(true)
    }
}
