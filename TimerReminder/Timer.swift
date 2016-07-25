import Foundation

protocol Timer: CustomStringConvertible {
    func reset()
    func start()
    func pause()
    
    var paused: Bool { get }
    
    var onEnd: ((Timer) -> Void)? { get }
    var onTimerChange: ((Timer) -> Void)? { get }
}