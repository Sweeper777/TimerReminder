import UIKit
import LTMorphingLabel
import RxSwift
import MaterialComponents
import SwiftyUtils

class TimerViewController: UIViewController {
    
    @IBOutlet var timerLabel: LTMorphingLabel!
    var playButton: MDCFloatingButton!
    var resetButton: MDCFloatingButton!
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
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
        }
        
        resetButton = MDCFloatingButton(shape: .mini)
        resetButton.setImage(UIImage(systemName: "goforward"), for: .normal)
        resetButton.imageView?.tintColor = .white
        resetButton.backgroundColor = UIColor(hex: "5abb5a")
        hud.addSubview(resetButton)
        resetButton.snp.makeConstraints { (make) in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.right.equalTo(playButton.snp.left).offset(-8)
            make.top.equalToSuperview().offset(8)
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
    
    func handleTimerEvent(timerEvent: TimerEvent) {
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
