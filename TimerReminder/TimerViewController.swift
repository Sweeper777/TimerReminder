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
    
        } else {
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

    }
}
