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
    
    var timer: Timer!
    var disposeBag = DisposeBag()
    
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
