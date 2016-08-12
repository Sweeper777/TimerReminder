import UIKit
import EZSwiftExtensions
import Eureka

class SetTimerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, TypedRowControllerType {
    var selectedTimeInterval: NSTimeInterval?
    @IBOutlet var timeIntervalPicker: UIPickerView!
    var row: RowOf<Int>!
    var completionCallback: ((UIViewController) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 500, height: 230)
        if let timeInterval = row.value {
            let hours = timeInterval / 60 / 60
            let minutes = timeInterval % 3600 / 60
            let seconds = timeInterval % 60
            
            timeIntervalPicker.selectRow(hours, inComponent: 0, animated: false)
            timeIntervalPicker.selectRow(minutes, inComponent: 1, animated: false)
            timeIntervalPicker.selectRow(seconds, inComponent: 2, animated: false)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissVC(completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 2:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var suffix = ""
        
        switch component {
        case 0:
            suffix = " h"
        case 1:
            suffix = " m"
        case 2:
            suffix = " s"
        default:
            suffix = ""
        }
        
        return String(row) + suffix
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let hours = timeIntervalPicker.selectedRowInComponent(0)
        let minutes = timeIntervalPicker.selectedRowInComponent(1)
        let seconds = timeIntervalPicker.selectedRowInComponent(2)
        self.selectedTimeInterval = Double(hours * 60 * 60 + minutes * 60 + seconds)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let hours = timeIntervalPicker.selectedRowInComponent(0)
        let minutes = timeIntervalPicker.selectedRowInComponent(1)
        let seconds = timeIntervalPicker.selectedRowInComponent(2)
        self.row.value = hours * 60 * 60 + minutes * 60 + seconds
    }
}
