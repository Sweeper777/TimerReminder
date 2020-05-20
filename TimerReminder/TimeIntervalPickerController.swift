import UIKit
import Eureka

class TimeIntervalPickerController: SelectorViewController<SelectorRow<AlertSelectorCell<Int>>> {
    
    @IBOutlet var setTimerView: SetTimerView!
    
    override func viewDidLoad() {
        setTimerView.delegate = self
        setTimerView.selectedTime = row.value ?? 0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}

extension TimeIntervalPickerController : SetTimerViewDelegate {
    func didSetTimer(setTimerView: SetTimerView, setTime: Int) {
        row.value = setTime
        row.updateCell()
        dismiss(animated: true, completion: nil)
    }
}
