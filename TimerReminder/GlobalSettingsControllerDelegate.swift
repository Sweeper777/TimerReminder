import UIKit

@objc protocol GlobalSettingsControllerDelegate {
    optional func globalSettings(globalSettings: GlobalSettingsController, globalSettingsDidChangeWithKey key: String, newValue: AnyObject)
}