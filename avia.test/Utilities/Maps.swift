//
//  Maps.swift
//  avia.test
//
//  Created by Sergey Urazov on 24/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    var mapRect: MKMapRect {
        let topLeft = CLLocationCoordinate2D(
            latitude: center.latitude + span.latitudeDelta / 2,
            longitude: center.longitude - span.longitudeDelta / 2
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: center.latitude - (span.latitudeDelta/2),
            longitude: center.longitude + (span.longitudeDelta/2)
        )

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        return MKMapRect(
            origin: MKMapPoint(x: min(a.x, b.x), y: min(a.y, b.y)),
            size: MKMapSize(width: abs(a.x - b.x), height: abs(a.y - b.y))
        )
    }

    func insetBy(lat: CLLocationDegrees, lon: CLLocationDegrees) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: span.latitudeDelta + lat * 2,
                longitudeDelta: span.longitudeDelta + lon * 2
            )
        )
    }
}

extension Location {
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

