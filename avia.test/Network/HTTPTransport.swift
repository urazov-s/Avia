//
//  HTTPTransport.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

protocol HTTPTransport {
    func send(request: HTTPRequest, completion: @escaping (Result<Data>) -> Void) -> Cancellable
}

enum HTTPTransportError: Error {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)
    case emptyData
}

extension URLSessionTask: Cancellable {}

final class AviaHTTPTransport: HTTPTransport {

    typealias Error = HTTPTransportError

    private let scheme: String
    private let host: String
    private let configuration: URLSessionConfiguration
    init(scheme: String, host: String, configuration: URLSessionConfiguration) {
        self.scheme = scheme
        self.host = host
        self.configuration = configuration
    }

    private lazy var session = URLSession(configuration: configuration)

    func send(request: HTTPRequest, completion: @escaping (Result<Data>) -> Void) -> Cancellable {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = request.path
        components.queryItems = request.params.map { URLQueryItem(name: $0, value: $1) }

        guard let url = components.url else {
            completion(.failure(Error.invalidURL))
            return PseudoCancellable()
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(Error.invalidResponse))
                return
            }
            guard 200..<300 ~= httpResponse.statusCode else {
                completion(.failure(Error.badStatusCode(httpResponse.statusCode)))
                return
            }
            guard let data = data else {
                completion(.failure(Error.emptyData))
                return
            }
            completion(.success(data))
        }
        task.resume()
        return task
    }

}
