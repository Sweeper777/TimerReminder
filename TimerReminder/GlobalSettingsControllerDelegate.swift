import UIKit

@objc protocol GlobalSettingsControllerDelegate {
    @objc optional func globalSettings(_ globalSettings: GlobalSettingsController, globalSettingsDidChangeWithKey key: String, newValue: AnyObject)
}
