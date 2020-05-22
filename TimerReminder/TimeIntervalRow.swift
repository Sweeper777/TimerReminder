import UIKit
import Eureka

final class TimeIntervalRow: SelectorRow<TimeIntervalCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .presentModally(controllerProvider: .storyBoard(storyboardId: "timeIntervalPicker", storyboardName: "Main", bundle: Bundle.main),
                                           onDismiss: { (vc) in
                                            vc.dismiss(animated: true, completion: nil)
        })
        displayValueFor = {
            x in
            guard let timeInterval = x else {
                return ""
            }
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = timeInterval >= 60 * 60 ? [.hour, .minute, .second] : [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: TimeInterval(timeInterval))
        }
    }
    
    override func customDidSelect() {
        super.customDidSelect()
        deselect(animated: true)
        updateCell()
    }
}

class TimeIntervalCell: AlertSelectorCell<Int> {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        contentView.backgroundColor = .systemGray3
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }
}
