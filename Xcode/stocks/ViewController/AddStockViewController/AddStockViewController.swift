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

    private let storage = StockStorage.shared
    private let tableView = UITableView()
    private var query: String = "" {
        didSet {
            if query.isEmpty {
                elements.removeAll()
                elements.loadPopularStocks()
            }
        }
    }

    private var elements: [Element] = [] {
        didSet {
            // TODO: - 나중에 하나씩 바뀌면 이 부분을 수정 해보자.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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

// MARK: - UISearchResultsUpdating

extension AddStockViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.uppercased(), !text.isEmpty else {
            query = ""
            return
        }
        
        if !query.isEmpty && text.hasPrefix(query) {
            query = text
            elements = elements.filter { $0.symbol.hasPrefix(query)}
            return
        }
        
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
        // 데이터를 미리 받앙
        print("load search with \(query)")
        
        StockNetworkManager.shared.fetchSearchResults(query) {[weak self] result in
            // 흠.. 이게 빠르긴 한데 계속 네트워크 통신을 해서 느리다.
            // 앞에 프리픽스랑 비교해서 네트워크 통신을 덜 할수잇는 방향으로 개선해보자
            // TODO: - SHould do
            guard let self = self else { return }
            switch result {
            case .success(let search):
                // TODO: - 이름 고민해보자
                let searchedResult = search.result
                let safeData = searchedResult.filter { $0.symbol.hasPrefix((self.query.uppercased())) }
                                             .sorted { $0.symbol < $1.symbol }

                var stockList: [Element] = []
                safeData.forEach { data in
                    stockList.append(Element(symbol: data.symbol, description: data.description))
                }
                
                self.elements = stockList
            case .failure(let error):
                print(error)
            }
        }
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

struct stockListElement {
    let symbol: String
    let description: String?
    let isExisted: Bool
}

struct AddItem {

    var title: String?
    var subtitle: String?

    var alreadyInList: Bool

}
