//
//  Images.swift
//  avia.test
//
//  Created by Sergey Urazov on 24/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static let xPlane = UIImage(named: "plane")
}

extension UIImage {
    static func airportAnnotation(withText text: String) -> UIImage? {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = UIFont.xMedium(16)
        textLayer.fontSize = 16
        textLayer.foregroundColor = UIColor.xShakespeare.cgColor
        textLayer.string = text
        textLayer.alignmentMode = .center
        let hMargin: CGFloat = 8
        let vMargin: CGFloat = 4
        let layerSize = textLayer.preferredFrameSize()
        let size = CGSize(width: layerSize.width + 2 * hMargin, height: layerSize.height + 2 * vMargin)
        return UIImage.draw(withSize: size, { context, rect in
            context.setFillColor(UIColor.xWhite.withAlphaComponent(0.7).cgColor)
            context.setStrokeColor(UIColor.xShakespeare.cgColor)
            let lineWidth: CGFloat = 3.0
            context.setLineWidth(lineWidth)
            let path = UIBezierPath(
                roundedRect: rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
                cornerRadius: rect.size.height / 2
            ).cgPath
            context.addPath(path)
            context.fillPath()
            context.addPath(path)
            context.strokePath()
            context.render(layer: textLayer, centeredAt: CGPoint(x: rect.midX, y: rect.midY))
        })
    }
}
