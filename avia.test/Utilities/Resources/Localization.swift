//
//  Localization.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

func ls(_ key: String, table: String? = nil) -> String {
    return NSLocalizedString(key, tableName: table, comment: "")
}
