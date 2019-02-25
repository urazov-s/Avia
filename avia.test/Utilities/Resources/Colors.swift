//
//  Colors.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(r: Int, g: Int, b: Int) {
        let comps = [r, g, b].map { CGFloat($0) / 255.0 }
        self.init(red: comps[0], green: comps[1], blue: comps[2], alpha: 1.0)
    }

}

extension UIColor {

    // MARK: Basic

    static let xWhite = UIColor(white: 1.0, alpha: 1.0)
    static let xBlack = UIColor(white: 0.12, alpha: 1.0)
    static let xShakespeare = UIColor(r: 78, g: 171, b: 209)
    static let xSilverChalice = UIColor(r: 172, g: 172, b: 172)

    // MARK: General

    static let xMainTint = UIColor.xShakespeare
    static let xGeneralBackground = UIColor.xWhite
    static let xMainText = UIColor.xBlack
    static let xDetailedText = UIColor.xSilverChalice

    enum xMap {
        static let routePath = UIColor.xShakespeare
    }

}
