import UIKit

class ScreenshotController: UIViewController {
    var image: UIImage!
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        
    }
}
