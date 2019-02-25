//
//  Fonts.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

    static func xRegular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func xLight(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }

    static func xMedium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func xBold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

}
