//
//  Launcher.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

final class Launcher {

    private let scenariesFactory: AviaScenariesFactory
    private let windowsManager: WindowsManager
    init(scenariesFactory: AviaScenariesFactory, windowsManager: WindowsManager) {
        self.scenariesFactory = scenariesFactory
        self.windowsManager = windowsManager
    }

    func launch(on screen: UIScreen) {
        windowsManager.resetMain(with: flightScenary)
        windowsManager.activate(.main)
    }

    // MARK: Possible Scenaries

    private lazy var flightScenary = scenariesFactory.makeFlightScenary()

}
