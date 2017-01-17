//
//  Created by Tom Baranes on 23/06/16.
//  Copyright © 2016 Tom Baranes. All rights reserved.
//

import Foundation

public extension UISwitch {

    public func toggle(animated: Bool = true) {
        self.setOn(!self.isOn, animated: animated)
    }

}
