//
//  Configurable.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation

protocol Configurable {
    associatedtype ViewModel
    func configure(_ model: ViewModel)
}
