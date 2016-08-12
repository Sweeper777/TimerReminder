import Eureka

final class TimeIntervalRow: SelectorRow<Int, PushSelectorCell<Int>, SetTimerController> {
    required init(tag: String?, @noescape _ initializer: (TimeIntervalRow -> ())) {
        super.init(tag: tag)
        initializer(self)
        presentationMode = .Show(controllerProvider: ControllerProvider.StoryBoard(storyboardId: "TimeIntervalSelector", storyboardName: "Main", bundle: nil), completionCallback: {
            _ in
//            vc in vc.navigationController?.popViewControllerAnimated(true) 
        })
        displayValueFor = {
            guard let timeInterval = $0 else { return "" }
            return normalize(timeInterval: NSTimeInterval(timeInterval))
        }
    }
}