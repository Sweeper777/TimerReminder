import Eureka

final class TimeIntervalRow: SelectorRow<PushSelectorCell<Int>, SetTimerController> {
    required init(tag: String?, _ initializer: ((TimeIntervalRow) -> ())) {
        super.init(tag: tag)
        initializer(self)
        presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.storyBoard(storyboardId: "TimeIntervalSelector", storyboardName: "Main", bundle: nil), onDismiss: {
             _ in
        })
        displayValueFor = {
            guard let timeInterval = $0 else { return "" }
            return normalize(timeInterval: TimeInterval(timeInterval))
        }
    }
    
    required convenience init(tag: String?) {
        self.init(tag: tag)
    }
}
