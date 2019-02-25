//
//  TableSection.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

final class TableSectionHeaderFooter {

    let text: () -> String?
    let view: () -> UIView?
    let height: () -> TableElementHeight

    init(text: @escaping @autoclosure () -> String, height: @escaping @autoclosure () -> TableElementHeight) {
        self.text = text
        self.view = { nil }
        self.height = height
    }

    init(view: @escaping () -> UIView, height: @escaping @autoclosure () -> TableElementHeight) {
        self.text = { nil }
        self.view = view
        self.height = height
    }

    static func empty(height: CGFloat) -> TableSectionHeaderFooter {
        return TableSectionHeaderFooter(text: "", height: .static(height))
    }

    static var zero: TableSectionHeaderFooter {
        return empty(height: .leastNormalMagnitude)
    }

}

final class TableSection {

    var rows: [Row] = []

    let header: TableSectionHeaderFooter?
    let footer: TableSectionHeaderFooter?

    init(rows: [Row],
         header: TableSectionHeaderFooter? = nil,
         footer: TableSectionHeaderFooter? = nil) {
        self.rows = rows
        self.header = header
        self.footer = footer
    }

}
