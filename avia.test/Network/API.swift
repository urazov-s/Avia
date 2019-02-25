//
//  API.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

struct AirportsRequest: HTTPRequest {
    let method = HTTPMethod.get
    let path = "/places"
    let params: [String : String]

    init(term: String, locale: String) {
        self.params = ["term": term, "locale": locale]
    }
}
