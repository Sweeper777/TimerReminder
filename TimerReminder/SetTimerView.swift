import UIKit
import SnapKit
import SCLAlertView

class SetTimerView: UIView {
    var picker: UIPickerView!
    var hourLabel: UILabel!
    var minuteLabel: UILabel!
    var secondLabel: UILabel!
    var okButton: UIButton!
    weak var delegate: SetTimerViewDelegate?
    
    var selectedTime: Int {
        let hours = picker.selectedRow(inComponent: 0) * 60 * 60
        let minutes = picker.selectedRow(inComponent: 1) * 60
        let seconds = picker.selectedRow(inComponent: 2)
        return hours + minutes + seconds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        okButton = UIButton(type: .custom)
        okButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        self.addSubview(okButton)
        okButton.snp.makeConstraints { (make) in
            make.width.equalTo(22).labeled("ok button width = 22")
            make.height.equalTo(22).labeled("ok button height = 22")
            make.centerX.equalToSuperview().labeled("ok button is centered horizontally")
            make.bottom.equalToSuperview().offset(-8).labeled("ok button is positioned at the bottom")
        }
        okButton.addTarget(self, action: #selector(okButtonDidPress), for: .touchUpInside)
        
        hourLabel = UILabel()
        hourLabel.text = "Hours".localised
        hourLabel.textAlignment = .center
        self.addSubview(hourLabel)
        hourLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(okButton.snp.top).offset(-8).labeled("hour label is on top of ok button")
            make.left.equalToSuperview().labeled("hour label is on the leftmost of set timer view")
            make.width.equalToSuperview().dividedBy(3).labeled("hour label width is a third of superview's width")
            make.height.equalTo(20).labeled("hour label height = 20")
        }
        hourLabel.translatesAutoresizingMaskIntoConstraints = true
        
        minuteLabel = UILabel()
        minuteLabel.text = "Minutes".localised
        minuteLabel.textAlignment = .center
        self.addSubview(minuteLabel)
        minuteLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(okButton.snp.top).offset(-8).labeled("minute label is on top of ok button")
            make.left.equalTo(hourLabel.snp.right).labeled("minute label is on the right of hour label")
            make.width.equalToSuperview().dividedBy(3).labeled("minute label width is a third of super view's width")
            make.height.equalTo(20).labeled("minute label height = 20")
        }
        
        secondLabel = UILabel()
        secondLabel.text = "Seconds".localised
        secondLabel.textAlignment = .center
        self.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(okButton.snp.top).offset(-8).labeled("second label is on top of ok button")
            make.left.equalTo(minuteLabel.snp.right).labeled("second label is on the right of minute label")
            make.width.equalToSuperview().dividedBy(3).labeled("second label width is a third of super view's width")
            make.height.equalTo(20).labeled("second label height = 20")
        }
        
        picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        self.addSubview(picker)
        picker.snp.makeConstraints { (make) in
            make.bottom.equalTo(secondLabel.snp.top).offset(-8).labeled("picker is on top of second label")
            make.left.equalToSuperview().labeled("picker sticks to the left side")
            make.right.equalToSuperview().labeled("oicker sticks to the right side")
            make.top.equalToSuperview().labeled("picker sticks to the top side")
        }
        
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        layer.cornerRadius = 10
    }
    
    @objc func okButtonDidPress() {
        if selectedTime > 0 {
            delegate?.didSetTimer(setTimerView: self, setTime: selectedTime)
        }
    }
}

extension SetTimerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        [24, 60, 60][component]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(row)"
    }
}

protocol SetTimerViewDelegate : class {
    func didSetTimer(setTimerView: SetTimerView, setTime: Int)
}
