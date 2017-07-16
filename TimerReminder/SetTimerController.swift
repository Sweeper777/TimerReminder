import UIKit
import SwiftyUtils
import Eureka
import GoogleMobileAds

class SetTimerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, TypedRowControllerType {
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?

    var selectedTimeInterval: TimeInterval?
    @IBOutlet var timeIntervalPicker: UIPickerView!
    @IBOutlet var ad: GADBannerView?
    var row: RowOf<Int>!
    var completionCallback: ((UIViewController) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        if row == nil {
            self.preferredContentSize = CGSize(width: 500, height: 230)
        }
        if let timeInterval = row?.value {
            let hours = timeInterval / 60 / 60
            let minutes = timeInterval % 3600 / 60
            let seconds = timeInterval % 60
            
            timeIntervalPicker.selectRow(hours, inComponent: 0, animated: false)
            timeIntervalPicker.selectRow(minutes, inComponent: 1, animated: false)
            timeIntervalPicker.selectRow(seconds, inComponent: 2, animated: false)
        }
        
        ad?.adUnitID = adUnitID2
        ad?.rootViewController = self
        ad?.load(getAdRequest())
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1, 2:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var suffix = ""
        
        switch component {
        case 0:
            suffix = NSLocalizedString(" h", comment: "")
        case 1:
            suffix = NSLocalizedString(" m", comment: "")
        case 2:
            suffix = NSLocalizedString(" s", comment: "")
        default:
            suffix = ""
        }
        
        return String(row) + suffix
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hours = timeIntervalPicker.selectedRow(inComponent: 0)
        let minutes = timeIntervalPicker.selectedRow(inComponent: 1)
        let seconds = timeIntervalPicker.selectedRow(inComponent: 2)
        self.selectedTimeInterval = Double(hours * 60 * 60 + minutes * 60 + seconds)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let hours = timeIntervalPicker.selectedRow(inComponent: 0)
        let minutes = timeIntervalPicker.selectedRow(inComponent: 1)
        let seconds = timeIntervalPicker.selectedRow(inComponent: 2)
        self.row?.value = hours * 60 * 60 + minutes * 60 + seconds
    }
}
