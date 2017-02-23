import UIKit
import ImageScrollView
import SCLAlertView

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
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false, showCircularIcon: false))
        alert.addButton(NSLocalizedString("OK", comment: ""), action: {})
        _ = alert.showCustom("", subTitle: NSLocalizedString("Screenshot has been saved.", comment: ""), color: UIColor(hex: "5abb5a"), icon: UIImage(color: nil))
        
    }
}
