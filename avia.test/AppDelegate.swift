//
//  AppDelegate.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let windowsManager = WindowsManager(screen: .main)
    private let httpTransport = AviaHTTPTransport(scheme: "https", host: "places.aviasales.ru", configuration: .default)
    private lazy var apiClient = AviaHTTPClient(transport: httpTransport)
    private lazy var servicesFactory = AviaServicesFactory(httpClient: apiClient)
    private lazy var scenariesFactory = AviaScenariesFactory(servicesFactory: servicesFactory)
    private lazy var launcher = Launcher(scenariesFactory: scenariesFactory, windowsManager: windowsManager)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        launcher.launch(on: UIScreen.main)
        return true
    }
}

