//
//  ReusableCell.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableCell {
    static var nib: UINib { get }
    static var identifier: String { get }
}

extension ReusableCell {
    private static var cellName: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: cellName, bundle: nil)
    }

    static var identifier: String {
        return cellName
    }
}

extension UITableViewCell: ReusableCell {}
extension UICollectionViewCell: ReusableCell {}

extension UITableView {
    func registerCells(_ cells: UITableViewCell.Type...) {
        cells.forEach { register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
}

extension UICollectionView {
    func registerCells(_ cells: UICollectionViewCell.Type...) {
        cells.forEach { register($0.nib, forCellWithReuseIdentifier: $0.identifier) }
    }
}
