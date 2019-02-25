//
//  MapViewController.swift
//  avia.test
//
//  Created by Sergey Urazov on 24/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct Route {
    let from: Airport
    let to: Airport
}

final class MapViewController: UIViewController {

    private let mapView = MKMapView()

    private let route: Route
    init(route: Route) {
        self.route = route
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        planeAnnotation.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .xGeneralBackground

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.frame = view.bounds
        view.addSubview(mapView)
        mapView.isRotateEnabled = false
        mapView.delegate = self

        setupOverlays()
        setupAnnotations()
        goToRouteRegion()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.takeOff()
        }
    }

    // MARK: Map Actions

    private func goToRouteRegion() {
        let dLat = abs(route.from.location.lat - route.to.location.lat) * 0.2
        let dLon = abs(route.from.location.lon - route.to.location.lon) * 0.2
        let region = route.region.insetBy(lat: dLat, lon: dLon)
        mapView.visibleMapRect = region.mapRect
    }

    private let pathControlPoint1 = CGPoint(x: 0.5, y: 0.0)
    private let pathControlPoint2 = CGPoint(x: 0.5, y: 1.0)

    private func takeOff() {
        planeAnnotation.move(
            to: route.to.location.coordinates,
            duration: 15,
            controlPoint1: pathControlPoint1,
            controlPoint2: pathControlPoint2,
            onVectorChange: { [weak self] newVector in
                guard let self = self else { return }
                guard let plainView = self.annotations[self.planeAnnotation] else { return }
                plainView.isHidden = false
                let originalVector = CGPoint(x: 1, y: 0)
                let angle = atan2(
                    originalVector.x * newVector.y - originalVector.y * newVector.x,
                    originalVector.x * newVector.x + originalVector.y * newVector.y
                )
                plainView.transform = CGAffineTransform(rotationAngle: angle)
            }
        )
    }

    // MARK: Overlays

    private var renderers: [AnyHashable: MKOverlayRenderer] = [:]

    private func setupOverlays() {
        let from = route.from.location.coordinates
        let to = route.to.location.coordinates
        var coords = [from, to]
        let pathOverlay = MKPolyline(
            coordinates: &coords,
            count: 2
        )
        renderers[pathOverlay] = pathRenderer(for: pathOverlay)

        mapView.addOverlays([pathOverlay])
    }

    // MARK: Renderers

    private func pathRenderer(for overlay: MKPolyline) -> MKOverlayPathRenderer {
        let renderer = MKOverlayPathRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.xMap.routePath
        renderer.lineDashPattern = [3, 4]
        renderer.lineWidth = 2.0

        let mapPoints = Array(UnsafeBufferPointer(start: overlay.points(), count: overlay.pointCount))
        let overlayPoints = mapPoints.map {
            CGPoint(x: $0.x - overlay.boundingMapRect.minX, y: $0.y - overlay.boundingMapRect.minY)
        }

        let controlPoints = [pathControlPoint1, pathControlPoint2].map {
            CGPoint(
                x: overlayPoints[0].x + (overlayPoints[1].x - overlayPoints[0].x) * $0.x,
                y: overlayPoints[0].y + (overlayPoints[1].y - overlayPoints[0].y) * $0.y
            )
        }

        let path = CGMutablePath()
        path.move(to: overlayPoints[0])
        path.addCurve(
            to: overlayPoints[1],
            control1: controlPoints[0],
            control2: controlPoints[1]
        )
        renderer.path = path
        return renderer
    }

    // MARK: Annotations

    private var annotations: [AnyHashable: MKAnnotationView] = [:]
    private lazy var planeAnnotation = MovableAnnotation(coordinate: route.from.location.coordinates)

    func setupAnnotations() {
        setupAirportAnnotations()
        setupPlaneAnnotation()
    }

    private func setupAirportAnnotations() {
        [route.from, route.to].forEach { airport in
            let annotation = MKPointAnnotation()
            annotation.coordinate = airport.location.coordinates

            let view = MKAnnotationView()
            view.image = UIImage.airportAnnotation(withText: airport.iata)

            annotations[annotation] = view
            mapView.addAnnotation(annotation)
        }
    }

    private func setupPlaneAnnotation() {
        let view = MKAnnotationView()
        view.image = UIImage.xPlane
        view.isHidden = true

        annotations[planeAnnotation] = view
        mapView.addAnnotation(planeAnnotation)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let hashableAnnotation = annotation as? AnyHashable else { return nil }
        return annotations[hashableAnnotation]
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let hashableOverlay = overlay as? AnyHashable else { return MKOverlayRenderer(overlay: overlay) }
        return renderers[hashableOverlay] ?? MKOverlayRenderer(overlay: overlay)
    }
}

private extension Route {

    var center: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: (from.location.lat + to.location.lat) / 2,
            longitude: (from.location.lon + to.location.lon) / 2
        )
    }

    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(
            latitudeDelta: abs(to.location.lat - from.location.lat),
            longitudeDelta: abs(to.location.lon - from.location.lon)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

}
