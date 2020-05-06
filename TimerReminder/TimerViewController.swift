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
    var modeSelector: UISegmentedControl!
    @IBOutlet var hud: UIView!
    @IBOutlet var setTimerView: SetTimerView!
    
    var timer = Timer.newCountDownInstance()
    var disposeBag = DisposeBag()
    
    var hudHidden = false
    var playButtonIsPlay = true
    
    var timerDisposable: Disposable?
    
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
        
        modeSelector = UISegmentedControl(items: [
            UIImage(systemName: "timer")!,
            UIImage(systemName: "stopwatch")!,
            UIImage(systemName: "clock")!
        ])
        modeSelector.selectedSegmentIndex = 0
        hud.addSubview(modeSelector)
        modeSelector.snp.makeConstraints { (make) in
            make.right.equalTo(resetButton.snp.left).offset(-8).labeled("mode selector on the left of reset button")
            make.centerY.equalTo(resetButton.snp.centerY).labeled("mode selector on the same line of reset button")
        }
    }
    
    override func viewDidLoad() {
        setUpView()
        updateTimerLabel(text: timer.displayString(forState: 20))
        timerDisposable = timer.timerEvents(initial: 20,
                pause: playButton.rx.tap.asObservable(),
                reset: resetButton.rx.tap.asObservable(),
                scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self]
            timerEvent in
            self?.handleTimerEvent(timerEvent: timerEvent)
            if timerEvent.ended {
                print("Ended!")
            }
        })
        
        playButton.rx.tap.subscribe(onNext: {
            if self.playButtonIsPlay {
                self.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                self.playButtonIsPlay = false
            } else {
                self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.playButtonIsPlay = true
            }
            }).disposed(by: disposeBag)
        resetButton.rx.tap.subscribe(onNext: {
            self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
    }
}

extension TimerViewController : SetTimerViewDelegate {
    func didSetTimer(setTimerView: SetTimerView, setTime: Int) {
        timerDisposable?.dispose()
        updateTimerLabel(text: timer.displayString(forState: setTime))
        timerDisposable = timer.timerEvents(initial: setTime,
                    pause: playButton.rx.tap.asObservable(),
                    reset: resetButton.rx.tap.asObservable(),
                    scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self]
                timerEvent in
                self?.handleTimerEvent(timerEvent: timerEvent)
                if timerEvent.ended {
                    print("Ended!")
                }
            })
    }
}
