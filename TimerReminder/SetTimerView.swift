import UIKit
import SnapKit

class SetTimerView: UIView {
    var picker: UIPickerView!
    var hourLabel: UILabel!
    var minuteLabel: UILabel!
    var secondLabel: UILabel!
    var okButton: UIButton!
    
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
            make.width.equalTo(22)
            make.height.equalTo(22)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
}
