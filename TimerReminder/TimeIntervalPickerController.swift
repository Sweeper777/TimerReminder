import UIKit

class TimeIntervalPickerController: UIViewController {
    @IBOutlet var setTimerView: SetTimerView!
    
    override func viewDidLoad() {
        setTimerView.delegate = self
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}