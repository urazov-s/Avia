//
//  ScenariesFactory.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

protocol ScenariesFactory {
    func makeFlightScenary() -> ScenaryCoordinator
}

final class AviaScenariesFactory: ScenariesFactory {

    private let servicesFactory: ServicesFactory
    init(servicesFactory: ServicesFactory) {
        self.servicesFactory = servicesFactory
    }

    func makeFlightScenary() -> ScenaryCoordinator {
        return FlightScenaryCoordinator(airportsService: servicesFactory.makeAirportsService())
    }

}
