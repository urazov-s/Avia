//
//  HTTPRequest.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

protocol HTTPRequest {
    var method: HTTPMethod { get }
    var path: String { get }
    var params: [String: String] { get }
}
