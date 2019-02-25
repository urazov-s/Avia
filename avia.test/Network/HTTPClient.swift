//
//  HTTPClient.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

protocol HTTPClient {
    associatedtype DecodedData
    func perform(request: HTTPRequest, completion: @escaping (Result<DecodedData>) -> Void) -> Cancellable
}

final class AviaHTTPClient: HTTPClient {

    typealias DecodedData = JSONObject

    private let transport: HTTPTransport
    init(transport: HTTPTransport) {
        self.transport = transport
    }

    func perform(request: HTTPRequest, completion: @escaping (Result<DecodedData>) -> Void) -> Cancellable {
        return transport.send(request: request) { result in
            do {
                let decodedResult: Result<DecodedData> = try result.map { data in
                    try cast(try JSONSerialization.jsonObject(with: data))
                }
                completion(decodedResult)
            } catch {
                completion(.failure(error))
            }
        }
    }

}
