import Foundation

protocol Timer: CustomStringConvertible {
    func reset()
    func start()
    func pause()
    
    var paused: Bool { get }
    var ended: Bool { get }
    
    var onEnd: ((Timer) -> Void)? { get }
    var onTimerChange: ((Timer) -> Void)? { get }
    
    var options: TimerOptions? { get set }
    
    var canCountDown: Bool { get }
    var canBeSet: Bool { get }
}

extension Timer {
    var hasLongDescription: Bool {
        return self.description.characters.count > 5
    }
}