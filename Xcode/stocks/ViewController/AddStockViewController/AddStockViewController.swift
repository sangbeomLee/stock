//
//  AddStockViewController.swift
//  stocks
//
//  Created by Daniel on 5/26/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

protocol AddStockViewControllerDelegate: AnyObject {
    func didSelect(stock: String?)
}

class AddStockViewController: UIViewController {
    weak var delegate: AddStockViewControllerDelegate?
    weak var coordinator: AddStockCoordinator?
    
    var provider: Provider?

    private let tableView = UITableView()
    private var query: String = ""

    private var elements: [Element] = [] {
        didSet {
            // TODO: - 나중에 하나씩 바뀌면 이 부분을 수정 해보자.
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        loadPopularStocks()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.end()
    }
}

private extension AddStockViewController {
 func setupView() {
        title = "Add a Stock"
        view.backgroundColor = .systemGray5
        
        setupNavigationView()
        setupTableView()
    }
    
    func setupNavigationView() {
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search

        let button = Theme.closeButton
        button.target = self
        button.action = #selector(close)
        navigationItem.rightBarButtonItem = button
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    func loadPopularStocks() {
        elements.loadPopularStocks()
    }
}

extension AddStockViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let text = searchController.searchBar.text,
            text.count > 0 else { return }

        query = text

        /// Credits: https://stackoverflow.com/questions/24330056/how-to-throttle-search-based-on-typing-speed-in-ios-uisearchbar
        /// to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadSearch), object: nil)
        perform(#selector(loadSearch), with: nil, afterDelay: 0.5)
    }

}

private extension AddStockViewController {

    @objc
    func loadSearch() {
        print("load search with \(query)")

//        provider?.search(query, completion: { (items) in
//            let section = AddSection(header: "Search", items: items)
//            self.dataSource = [section]
//            self.tableView.reloadData()
//        })
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension AddStockViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//
//        var s = dataSource[indexPath.section]
//        var items = s.items
//        if var item = items?[indexPath.row] {
//            guard item.alreadyInList == false else { return }
//
//            print("selected \(item)")
//
//            self.delegate?.didSelect(stock: item.title)
//
//            // update ui
//            item.alreadyInList = item.alreadyInList ? false : true
//            items = s.items
//            items?[indexPath.row] = item
//
//            s.items = items
//            dataSource = [s]
//            tableView.reloadData()
//        }
    }

}

extension AddStockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let s = dataSource[section]
//        return s.items?.count ?? 0
        return elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

//        let s = dataSource[indexPath.section]
//        if let item = s.items?[indexPath.row] {
//            cell.textLabel?.text = item.title
//            cell.detailTextLabel?.text = item.subtitle
//
//            cell.accessoryType = item.alreadyInList ? .checkmark : .none
//        }

        cell.textLabel?.text = elements[indexPath.row].symbol

        return cell
    }

}

private struct AddSection {

    var header: String?
    var items: [AddItem]?

}

struct AddItem {

    var title: String?
    var subtitle: String?

    var alreadyInList: Bool

}
