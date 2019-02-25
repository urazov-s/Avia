//
//  FlightScenaryCoordinator.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

protocol ScenaryCoordinator {
    var rootViewController: UIViewController { get }
}

protocol FlightScenaryRouter {
    func showMapWithRoute(to: Airport)
    func showError(_ error: Error, withRetry: (() -> Void)?)
}

final class FlightScenaryCoordinator: ScenaryCoordinator, FlightScenaryRouter {

    private let airportsService: AirportsService
    init(airportsService: AirportsService) {
        self.airportsService = airportsService
    }

    private lazy var airportsList = AirportsListViewController(service: airportsService, router: self)
    private lazy var navigationController = UINavigationController(rootViewController: airportsList)

    var rootViewController: UIViewController {
        return navigationController
    }

    // MARK: Routing

    func showMapWithRoute(to: Airport) {
        let mapViewController = MapViewController(route: .init(from: airportsService.closestAirport, to: to))
        navigationController.pushViewController(mapViewController, animated: true)
    }

    // MARK: Errors

    func showError(_ error: Error, withRetry retry: (() -> Void)?) {
        let alert = UIAlertController(
            title: ls("error.title"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let mainAction: UIAlertAction
        if let retry = retry {
            mainAction = UIAlertAction(title: ls("error.retry"), style: .default) { _ in
                retry()
            }
        } else {
            mainAction = UIAlertAction(title: ls("error.ok"), style: .default, handler: nil)
        }
        alert.addAction(mainAction)
        rootViewController.present(alert, animated: true, completion: nil)
    }

}
