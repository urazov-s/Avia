//
//  TableDirector.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

enum TableElementHeight {
    case `static`(_ height: CGFloat)
    case `dynamic`(estimated: CGFloat)
}

final class TableDirector: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: Contents

    private let table: UITableView
    private weak var scrollDelegate: UIScrollViewDelegate?

    var sections: [TableSection] = []

    init(table: UITableView, scrollDelegate: UIScrollViewDelegate? = nil) {
        self.table = table
        super.init()
        self.table.dataSource = self
        self.table.delegate = self

        self.scrollDelegate = scrollDelegate
    }

    // MARK: - Table Datasource & Delegate

    // MARK: Numbers

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    // MARK: Cell Height

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].rows[indexPath.row]
        return row.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].rows[indexPath.row]
        return row.estimatedHeight
    }

    // MARK: Section Header & Footer Height

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        guard let header = section.header else { return 0.0 }
        switch header.height() {
        case .static(let height):
            return height
        case .dynamic:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        guard let header = section.header else { return 0.0 }
        switch header.height() {
        case .static(let height):
            return height
        case .dynamic(let estimated):
            return estimated
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = sections[section]
        guard let footer = section.footer else { return 0.0 }
        switch footer.height() {
        case .static(let height):
            return height
        case .dynamic:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let section = sections[section]
        guard let footer = section.footer else { return 0.0 }
        switch footer.height() {
        case .static(let height):
            return height
        case .dynamic(let estimated):
            return estimated
        }
    }

    // MARK: Header

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        return section.header?.text()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        return section.header?.view()
    }

    // MARK: Footer

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = sections[section]
        return section.footer?.text()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = sections[section]
        return section.footer?.view()
    }

    // MARK: Cell

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = row.createConfiguredCell(table: tableView, indexPath: indexPath)

        let action = ConfigureRowAction(payload: cell)
        row.invoke(action: action)

        return cell
    }

    // MARK: Selection

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]

        let action = DidSelectRowAction(payload: indexPath)
        row.invoke(action: action)
    }

    // MARK: Highlight

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let row = sections[indexPath.section].rows[indexPath.row]

        let action = ShouldHighlightRowAction(payload: indexPath)
        return row.invoke(action: action) ?? true
    }

    // MARK: - Scrolling

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    override func responds(to aSelector: Selector) -> Bool {
        return super.responds(to: aSelector) || scrollDelegate?.responds(to: aSelector) == true
    }

    override func forwardingTarget(for aSelector: Selector) -> Any? {
        return scrollDelegate?.responds(to: aSelector) == true
            ? scrollDelegate
            : super.forwardingTarget(for: aSelector)
    }

}
