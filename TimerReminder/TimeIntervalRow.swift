import UIKit
import Eureka

final class TimeIntervalRow: SelectorRow<AlertSelectorCell<Int>>, RowType {
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
}
