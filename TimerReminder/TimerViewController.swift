import UIKit
import LTMorphingLabel
import RxSwift

class TimerViewController: UIViewController {
    
    @IBOutlet var timerLabel: LTMorphingLabel!
    @IBOutlet var playButton: UIButton!
    
    var timer: Timer!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        timer = Timer.newCountDownInstance(countDownTime: 20)
        timerLabel.text = timer.currentTimerEvent.displayString
        
        timer.timerEvents.subscribe(
            onNext: { (timerEvent) in
                self.timerLabel.text = timerEvent.displayString
                if timerEvent.ended {
                    print("Completed")
                }
        }).disposed(by: disposeBag)
        
        timer.rxPaused.map { $0 ? "Play" : "Pause" }.bind(to: playButton.rx.title())
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerLabel.updateFontSizeToFit()
    }
    
    @IBAction func playPause() {
        if timer.paused {
            timer.start()
        } else {
            timer.pause()
        }
    }
    
    @IBAction func reset() {
        timer.reset()
        timerLabel.text = timer.currentTimerEvent.displayString
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { (_) in
            self.timerLabel.updateFontSizeToFit()
        }
    }
}
