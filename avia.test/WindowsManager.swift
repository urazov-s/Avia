//
//  WindowsManager.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

final class WindowsManager {

    enum Window {
        case main
    }

    private let screen: UIScreen
    init(screen: UIScreen) {
        self.screen = screen
    }

    private var mainWindow: UIWindow?

    func resetMain(with scenary: ScenaryCoordinator) {
        mainWindow = with(UIWindow(frame: screen.bounds)) {
            $0.rootViewController = scenary.rootViewController
            $0.tintColor = .xMainTint
        }
    }

    func activate(_ window: Window) {
        switch window {
        case .main:
            mainWindow?.makeKeyAndVisible()
        }
    }

}
