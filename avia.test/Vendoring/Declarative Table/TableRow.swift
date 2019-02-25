//
//  TableRow.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

typealias ConfigurableCell = UITableViewCell & Configurable

protocol Row {
    var height: CGFloat { get }
    var estimatedHeight: CGFloat { get }

    func createConfiguredCell(table: UITableView, indexPath: IndexPath) -> UITableViewCell

    @discardableResult
    func on<T: RowAction>(_ actionType: T.Type, handler: @escaping (T.Payload)->T.Result) -> Self
    func invoke<T: RowAction>(action: T) -> T.Result?
}

final class TableRow<Cell: ConfigurableCell> {

    private static var defaultHeight: TableElementHeight {
        return (Cell.self as? DefaultHeightProvider.Type)?.defaultHeight ?? .static(44)
    }

    private let _height: () -> TableElementHeight
    private let _configure: (Cell) -> Void

    init(height: @escaping @autoclosure () -> TableElementHeight = TableRow<Cell>.defaultHeight,
         viewModel: @escaping @autoclosure () -> Cell.ViewModel?) {
        self._height = height
        self._configure = { cell in
            viewModel().flatMap { cell.configure($0) }
        }
    }

    private var actions: [String: Any] = [:]

    @discardableResult
    func on<T: RowAction>(_ actionType: T.Type, handler: @escaping (T.Payload)->T.Result) -> Self {
        actions[actionType.identifier] = handler
        return self
    }

    func invoke<T: RowAction>(action: T) -> T.Result? {
        let key = T.identifier
        let handler = actions[key] as? (T.Payload) -> T.Result
        return handler?(action.payload)
    }

}

extension TableRow: Row {

    var height: CGFloat {
        switch _height() {
        case .static(let height):
            return height
        case .dynamic:
            return UITableView.automaticDimension
        }
    }

    var estimatedHeight: CGFloat {
        switch _height() {
        case .static(let height):
            return height
        case .dynamic(let estimated):
            return estimated
        }
    }

    func createConfiguredCell(table: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            return UITableViewCell()
        }
        _configure(cell)
        return cell
    }

}
