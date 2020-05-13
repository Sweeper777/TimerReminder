import UIKit
import Eureka
import AVFoundation

class CurrentOptionsViewController: FormViewController {
    var tableViewTopInset: CGFloat?
    var showNameField = false
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let topInset = tableViewTopInset {
            tableView.contentInset.top = topInset
        }
        
        
    }
}

