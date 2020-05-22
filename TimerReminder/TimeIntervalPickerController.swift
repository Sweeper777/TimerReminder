import UIKit
import Eureka

class TimeIntervalPickerController: SelectorViewController<SelectorRow<TimeIntervalCell>> {
    
    @IBOutlet var setTimerView: SetTimerView!
    
    override func viewDidLoad() {
        setTimerView.delegate = self
        setTimerView.selectedTime = row.value ?? 0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onDismissCallback!(self)
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
        onDismissCallback!(self)
    }
}
