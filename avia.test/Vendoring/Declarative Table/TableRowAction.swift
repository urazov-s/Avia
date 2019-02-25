//
//  TableRowAction.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

protocol RowAction {
    associatedtype Payload
    associatedtype Result

    var payload: Payload { get }
    static var identifier: String { get }

    init(payload: Payload)
}

extension RowAction {
    static var identifier: String {
        return String(describing: self)
    }
}

// MARK: - Actions

struct DidSelectRowAction: RowAction {
    typealias Payload = IndexPath
    typealias Result = Void

    let payload: Payload
}

struct ConfigureRowAction: RowAction {
    typealias Payload = UITableViewCell
    typealias Result = Void

    let payload: Payload
}

struct ShouldHighlightRowAction: RowAction {
    typealias Payload = IndexPath
    typealias Result = Bool

    let payload: Payload
}

