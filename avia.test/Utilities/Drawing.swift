//
//  Drawing.swift
//  avia.test
//
//  Created by Sergey Urazov on 24/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

public extension CGContext {
    public func draw(layer: CALayer, in rect: CGRect) {
        saveGState()
        defer { restoreGState() }
        translateBy(x: rect.origin.x, y: rect.origin.y)
        layer.bounds.size = rect.size
        layer.draw(in: self)
    }

    public func draw(layer: CALayer, centeredAt point: CGPoint) {
        let lSize = layer.preferredFrameSize()
        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -lSize.width / 2.0, dy: -lSize.height / 2.0)
        draw(layer: layer, in: rect)
    }
}

public extension CGContext {
    public func render(layer: CALayer, in rect: CGRect) {
        saveGState()
        defer { restoreGState() }
        translateBy(x: rect.origin.x, y: rect.origin.y)
        layer.bounds.size = rect.size
        layer.render(in: self)
    }

    public func render(layer: CALayer, centeredAt point: CGPoint) {
        let lSize = layer.preferredFrameSize()
        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -lSize.width / 2.0, dy: -lSize.height / 2.0)
        render(layer: layer, in: rect)
    }
}

extension UIImage {
    static func draw(withSize size: CGSize, baseSize: CGSize? = nil, _ drawings: (_ context: CGContext, _ rect: CGRect) -> Void) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let drawingsSize = baseSize ?? size
        context.scaleBy(x: size.width / drawingsSize.width, y: size.height / drawingsSize.height)
        drawings(context, CGRect(origin: .zero, size: drawingsSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImage {
    static func imageWithColor(_ color: UIColor, size: CGFloat = 1.0, cornerRadius: CGFloat? = nil) -> UIImage? {
        return UIImage.draw(withSize: CGSize(width: size, height: size), { context, rect in
            color.setFill()
            if let cornerRadius = cornerRadius {
                let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
                context.addPath(path)
                context.fillPath()
            } else {
                UIRectFill(rect)
            }
        })
    }
}
