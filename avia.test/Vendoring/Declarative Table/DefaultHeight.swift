//
//  DefaultHeight.swift
//  DeclarativeTable
//
//  Created by Sergey Urazov on 03/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

protocol DefaultHeightProvider: class {
    static var defaultHeight: TableElementHeight { get }
}
