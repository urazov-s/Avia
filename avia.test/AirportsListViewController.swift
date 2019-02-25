//
//  AirportsListViewController.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

final class AirportsListViewController: UIViewController, UISearchResultsUpdating {

    private let service: AirportsService
    typealias Router = AnyObject & FlightScenaryRouter
    private weak var router: Router?
    init(service: AirportsService, router: Router) {
        self.service = service
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true
        title = ls("airports.list.title")
        view.backgroundColor = .xGeneralBackground
        navigationItem.searchController = searchController

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        tableView.registerCells(AirportCell.self)
        tableView.keyboardDismissMode = .interactive

        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        tableView.indexPathForSelectedRow.flatMap { tableView.deselectRow(at: $0, animated: true) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    // MARK: Search

    private lazy var searchController = with(UISearchController(searchResultsController: nil)) {
        $0.searchResultsUpdater = self
        $0.dimsBackgroundDuringPresentation = false
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchText.value = searchController.searchBar.text ?? ""
    }

    private lazy var searchText = ThrottlingValue(initialValue: "", delay: 0.5) { [weak self] _ in
        self?.reloadData()
    }

    // MARK: Table

    private let tableView = UITableView(frame: .zero, style: .plain)
    private lazy var tableDirector = TableDirector(table: tableView)

    private func updateTable() {
        let rows = airports.map {
            TableRow<AirportCell>(
                height: .static(52),
                viewModel: AirportCellViewModel(title: $0.iata, subtitle: $0.name)
            )
            .on(ConfigureRowAction.self) { cell in
                cell.accessoryType = .disclosureIndicator
            }
            .on(DidSelectRowAction.self) { [weak self] indexPath in
                guard let self = self else { return }
                self.router?.showMapWithRoute(to: self.airports[indexPath.row])
            }
        }
        tableDirector.sections = [TableSection(rows: rows)]
        tableView.reloadData()
    }

    // MARK: Data

    private var currentRequest: Cancellable? {
        willSet {
            currentRequest?.cancel()
        }
    }

    private var airports: [Airport] = []

    private func reloadData() {
        // TODO: provide locale from app config
        currentRequest = service.requestAirports(textFilter: searchText.value, locale: Locale.current) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }

    private func handleResult(_ result: Result<[Airport]>) {
        weak var weakSelf = self
        switch result {
        case .success(let airports):
            self.airports = airports
            updateTable()
        case .failure(let error):
            router?.showError(error, withRetry: { weakSelf?.reloadData() })
        }
    }

    // MARK: Keyboard

    @objc
    private func adjustForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }

        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let intersection = view.frame.intersection(keyboardViewEndFrame)

        tableView.contentInset.bottom = intersection.height
        tableView.scrollIndicatorInsets.bottom = intersection.height
    }

}
