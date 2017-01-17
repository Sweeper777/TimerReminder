import UIKit
import ImageScrollView

class ScreenshotController: UIViewController {
    var image: UIImage!
    @IBOutlet var imageView: ImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.display(image: image)
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        let alert = UIAlertController(title: NSLocalizedString("Screenshot has been saved.", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
