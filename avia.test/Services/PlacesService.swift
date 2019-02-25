//
//  PlacesService.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

protocol AirportsService {
    func requestAirports(textFilter: String, locale: Locale, completion: @escaping (Result<[Airport]>) -> Void) -> Cancellable
    var closestAirport: Airport { get }
}

struct Location: Equatable {
    let lon: Double
    let lat: Double
}

struct Airport: Equatable {
    let name: String
    let iata: String
    let location: Location
}

struct PlacesService<Client: HTTPClient>: AirportsService where Client.DecodedData == JSONObject {

    private let httpClient: Client
    init(httpClient: Client) {
        self.httpClient = httpClient
    }

    func requestAirports(textFilter: String, locale: Locale, completion: @escaping (Result<[Airport]>) -> Void) -> Cancellable {
        let request = AirportsRequest(term: textFilter, locale: locale.languageCode ?? "")
        return httpClient.perform(request: request) { result in
            let mapped: Result<[Airport]> = result.map { json in
                guard let array = json as? [[String: Any]] else { return [] }
                return array.compactMap { Airport(dict: $0) }
            }
            completion(mapped)
        }
    }

    var closestAirport: Airport {
        // NOTE: it seems like we should use location services to determine the closest airport to the current location
        // but i don't care 🤷‍♂️. Using some stub value for now
        return Airport(name: "Stub airport", iata: "STB", location: Location(lon: 56.771, lat: 59.6484))
    }

}

private extension Airport {
    init?(dict: [String: Any]) {
        do {
            guard let locationDict = dict["location"] as? [String: Any] else {
                assertionFailure("No location for airport")
                return nil
            }
            self.init(
                name: cast(dict["airport_name"], default: try cast(dict["name"])),
                iata: try cast(dict["iata"]),
                location: try cast(Location(dict: locationDict))
            )
        } catch {
            assertionFailure("Unexpected data for airport")
            return nil
        }
    }
}

private extension Location {
    init?(dict: [String: Any]) {
        do {
            self.init(
                lon: try cast(dict["lon"]),
                lat: try cast(dict["lat"])
            )
        } catch {
            assertionFailure("Unexpected data for location")
            return nil
        }
    }
}
