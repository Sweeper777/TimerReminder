import UIKit
import Eureka

class TimeIntervalPickerController: UIViewController, TypedRowControllerType {

    typealias RowValue = Int

    var onDismissCallback: ((UIViewController) -> Void)?
    var row: RowOf<Int>!
    
    @IBOutlet var setTimerView: SetTimerView!
    
    override func viewDidLoad() {
        setTimerView.delegate = self
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}

extension TimeIntervalPickerController : SetTimerViewDelegate {
    func didSetTimer(setTimerView: SetTimerView, setTime: Int) {
        row.value = setTime
        dismiss(animated: true, completion: nil)
    }
}
