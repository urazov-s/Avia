//
//  MovableAnnotation.swift
//  avia.test
//
//  Created by Sergey Urazov on 24/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import MapKit

class MovableAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        willSet { willChangeValue(for: \.coordinate) }
        didSet { didChangeValue(for: \.coordinate) }
    }

    private var mapPoint: MKMapPoint {
        didSet {
            let vectorLength = sqrt(pow(oldValue.x - mapPoint.x, 2) + pow(oldValue.y - mapPoint.y, 2))
            let normalVector = CGPoint(
                x: (mapPoint.x - oldValue.x) / vectorLength,
                y: (mapPoint.y - oldValue.y) / vectorLength
            )
            onVectorChange?(normalVector)
            coordinate = mapPoint.coordinate
        }
    }

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.mapPoint = MKMapPoint(coordinate)
    }

    private var animator: MoveAnimator?
    private var onVectorChange: ((CGPoint) -> Void)?

    func move(
        to: CLLocationCoordinate2D,
        duration: TimeInterval,
        controlPoint1: CGPoint,
        controlPoint2: CGPoint,
        onVectorChange: @escaping (CGPoint) -> Void
    ) {
        self.animator = MoveAnimator(
            start: coordinate,
            finish: to,
            duration: duration,
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2,
            mapPointChange: { [weak self] mapPoint in
                self?.mapPoint = mapPoint
            }
        )
        self.onVectorChange = onVectorChange
        self.animator?.start()
    }

    func stop() {
        animator?.stop()
        animator = nil
    }

}

private final class MoveAnimator {

    private let startCoordinate: CLLocationCoordinate2D
    private let targetCoordinate: CLLocationCoordinate2D

    private let controlPoint1: CGPoint
    private let controlPoint2: CGPoint

    private let duration: TimeInterval

    private let mapPointChange: (MKMapPoint) -> Void

    init(
        start: CLLocationCoordinate2D,
        finish: CLLocationCoordinate2D,
        duration: TimeInterval,
        controlPoint1: CGPoint,
        controlPoint2: CGPoint,
        mapPointChange: @escaping (MKMapPoint) -> Void
    ) {
        self.startCoordinate = start
        self.targetCoordinate = finish
        self.duration = duration
        self.controlPoint1 = controlPoint1
        self.controlPoint2 = controlPoint2
        self.mapPointChange = mapPointChange
        self.bezierCalc = BezierCalculator(
            controlPoint1: controlPoint1,
            controlPoint2: controlPoint2
        )
    }

    deinit {
        stop()
    }

    private var link: CADisplayLink?
    private var lastTimestamp: CFTimeInterval?
    private var totalElapsed: CFTimeInterval = 0.0

    let bezierCalc: BezierCalculator

    @objc
    private func refresh(link: CADisplayLink) {
        defer { self.lastTimestamp = link.timestamp }
        guard let lastTimestamp = lastTimestamp else {
            return
        }
        let elapsed = link.timestamp - lastTimestamp
        totalElapsed += elapsed

        let progress = min(totalElapsed / duration, 1.0)

        let shouldStop = progress >= 1.0

        let sourcePoint = MKMapPoint(startCoordinate)
        let destinationPoint = MKMapPoint(targetCoordinate)

        let currentPoint = MKMapPoint(
            x: sourcePoint.x + (destinationPoint.x - sourcePoint.x) * bezierCalc.calcX(for: progress),
            y: sourcePoint.y + (destinationPoint.y - sourcePoint.y) * bezierCalc.calcY(for: progress)
        )
        mapPointChange(currentPoint)
        if shouldStop {
            stop()
        }
    }

    func start() {
        let link = CADisplayLink(weakTarget: self, selector: #selector(refresh))
        link.add(to: RunLoop.main, forMode: .common)
        self.link = link
    }

    func stop() {
        link?.invalidate()
        link = nil
    }
}

private struct BezierCalculator {

    let controlPoint1: CGPoint
    let controlPoint2: CGPoint

    private var points: [CGPoint] {
        return [
            .zero,
            controlPoint1,
            controlPoint2,
            CGPoint(x: 1, y: 1)
        ]
    }

    func calcX(for t: Double) -> Double {
        var result: Double = 0.0
        for i in 0..<points.count {
            let c = 6.0 / Double(factorial(val: i) * factorial(val: 3 - i))
            result += c * Double(points[i].x) * pow(t, Double(i)) * pow((1 - t), 3 - Double(i))
        }
        return result
    }

    func calcY(for t: Double) -> Double {
        var result: Double = 0.0
        for i in 0..<points.count {
            let c = 6.0 / Double(factorial(val: i) * factorial(val: 3 - i))
            result += c * Double(points[i].y) * pow(t, Double(i)) * pow((1 - t), 3 - Double(i))
        }
        return result
    }

}
