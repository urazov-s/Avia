//
//  ServicesFactory.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

protocol ServicesFactory {
    func makeAirportsService() -> AirportsService
}

final class AviaServicesFactory<Client: HTTPClient>: ServicesFactory where Client.DecodedData == JSONObject {

    private let httpClient: Client
    init(httpClient: Client) {
        self.httpClient = httpClient
    }

    func makeAirportsService() -> AirportsService {
        return PlacesService(httpClient: httpClient)
    }

}
