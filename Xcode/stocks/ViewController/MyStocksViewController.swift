//
//  MyStocksViewController.swift
//  stocks
//
//  Created by Daniel on 5/28/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

// TODO: - Timer 를 두어 몇 초마다 계속 리프레쉬 되게 만들자.
class MyStocksViewController: UIViewController {

    // UI
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addButton: UIButton!
    private let refreshControl = UIRefreshControl()
    private var updateLabel = UpdateLabel()
    
    private let networkManager = StockNetworkManager.shared
    private let storage = StockStorage.shared
    private var items: [StockItem]? {
        didSet {
            tableView.reloadData()
            
            guard let items = items else { return }
            storage.saveStockItems(items)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addStock()
    }

    // Data 
    private var sections: [Section] = []
    private var sort: Sort = .percent
    private let provider: Provider = .finnhub
    

    var footerView: UpdateLabel {
        let label = UpdateLabel()

        var f = view.bounds
        f.size.height = 15
        label.frame = f

        updateLabel = label
        updateLabel.provider = provider

        return label
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DATAReload 가 이상하다.
        setupView()
        setItems()
        // TODO: - UI 수정할 때 updateNavBar 고칠 것
        updateNavBar()
        loadStockItems()
    }
    
    func setItems() {
        items = StockStorage.shared.loadStockItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }

}

private extension MyStocksViewController {
    func makeSections() {
        let stockItems = storage.loadStockItems()
        
        sections = makeSections(items: stockItems, sort: sort)
    }

    func setupView() {
        setupTableView()
        
        refreshControl.addTarget(self, action: #selector(loadStockItems), for: .valueChanged)
    }
    
    func setupTableView() {
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = self.footerView
        
        tableView.isHidden = storage.isEmpty
        addButton.isHidden = !storage.isEmpty
    }

    func updateNavBar(_ isEditing: Bool = false) {
        if isEditing {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editStocks))

            navigationItem.rightBarButtonItems = [doneButton]
        }
        else {
            let image = UIImage(systemName: "plus")
            let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addStock))

            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editStocks))

            navigationItem.rightBarButtonItems = sections.first?.items?.count ?? 0 == 0 ?
                [addButton] : [editButton, addButton]
        }
    }
}

@objc
private extension MyStocksViewController {
    func addStock() {
        let s = AddStockViewController()
        s.modalPresentationStyle = .formSheet
        s.provider = provider
        s.delegate = self

        let n = UINavigationController(rootViewController: s)
        n.navigationBar.prefersLargeTitles = true
        n.navigationBar.largeTitleTextAttributes = Theme.attributes

        present(n, animated: true, completion: nil)
    }

    func editStocks() {
        let isEditing = !tableView.isEditing
        updateNavBar(isEditing)
        tableView.setEditing(isEditing, animated: true)
    }
    
    func loadStockItems() {
        guard let items = items else { return }
        let symbols = items.compactMap { $0.symbol }

        networkManager.fetch(dataType: Finnhub.Quote.self, for: symbols) { [weak self] results in
            guard let self = self else { return }
            
            var fetchItems = [StockItem]()
            results.forEach { symbol, result in
                switch result {
                case .success(let quote):
                    // TODO: - myQuote 개선하기
                    // TODO: - Item naming 개선
                    let fetchItem = StockItem(symbol: symbol, quote: quote.quote)
                    fetchItems.append(fetchItem)
                case .failure(let error):
                    // TODO: - error 처리
                    print(error)
                }
            }
            
            // TODO: -  밑 부분 로직 다시짜기
            // TODO: - UI 관련 해서 짜기
            // TODO: - tableView 가 어떻게 뿌려주고 있는지 확인하기
            // TODO: - Section 으로 되어있는데 이부분을 없애버리자
            self.items = fetchItems
            self.refreshControl.endRefreshing()
            self.updateLabel.date = Date()
            self.updateLabel.update()
        }
        
    }

    func sortList() {
        switch sort {
        case .symbol:
            sort = .change
        case .change:
            sort = .percent
        case .percent:
            sort = .price
        case .price:
            sort = .symbol
        }

        makeSections()
    }

}

private extension MyStocksViewController {

    func makeSections(items: [StockItem], sort: Sort) -> [Section] {
        // sort items
        let sorted = sortItems(items, sort: sort)

        // save list
        var s = MyStocks()
        s.save(sorted)

        // make data source
        let section = Section(header: sort.header, items: sorted)

        return [section]
    }

    func sortItems(_ items: [StockItem], sort: Sort) -> [StockItem] {
        var sorted: [StockItem] = []

        switch sort {
        case .symbol:
            sorted = items.sorted { $0.symbol ?? "" < $1.symbol ?? "" }
        case .change:
            sorted = items.sorted { $0.quote?.change ?? 0 > $1.quote?.change ?? 0 }
        case .percent:
            sorted = items.sorted { $0.quote?.percent ?? 0 > $1.quote?.percent ?? 0 }
        case .price:
            sorted = items.sorted { $0.quote?.price ?? 0 > $1.quote?.price ?? 0 }
        }

        return sorted
    }

}

extension MyStocksViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = view.bounds
        let view = UIView(frame: frame)

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ])

        let s = sections[section]
        let title = "   \(s.header ?? "")   "
        button.setTitle(title, for: .normal)

        button.backgroundColor = Theme.color
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(sortList), for: .touchUpInside)
        button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        button.layer.cornerRadius = 13
        button.layer.masksToBounds = true

        return view
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = sections[section]
        return s.header
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // step 1 of 2: update data
            var s = MyStocks()
            var list = s.load()
            list.remove(at: indexPath.row)
            s.save(list)

            // step 2 of 2: update ui
            sections = makeSections(items: list, sort: sort)
            makeSections()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let s = sections[indexPath.section]
        guard let item = s.items?[indexPath.row] else { return }

        let d = DetailViewController()
        d.provider = provider
        d.item = item
        d.modalPresentationStyle = .formSheet

        let n = UINavigationController(rootViewController: d)
        n.navigationBar.prefersLargeTitles = true
        n.navigationBar.largeTitleTextAttributes = Theme.attributes
        present(n, animated: true, completion: nil)
    }

}

extension MyStocksViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = sections[section]
        return s.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "id")

        let s = sections[indexPath.section]
        if let item = s.items?[indexPath.row] {
            cell.textLabel?.text = item.symbol

            switch sort {
            case .change:
                cell.detailTextLabel?.attributedText = item.changeAttributedValue
            case .price:
                cell.detailTextLabel?.attributedText = item.priceAttributedValue
            case .percent:
                cell.detailTextLabel?.attributedText = item.percentAttributedValue
            case .symbol:
                cell.detailTextLabel?.attributedText = item.attributedValue
            }


        }

        return cell
    }

}

extension MyStocksViewController: SelectStock {

    func didSelect(_ stock: String?) {
        guard let stock = stock else { return }

        var s = MyStocks()
        var list = s.load()

        let item = StockItem(symbol: stock)

        guard list.contains(item) == false else { return }

        list.append(item)
        s.save(list)

        makeSections()
        updateNavBar()
        loadStockItems()
    }

}

struct MyStocks {

    var symbols: [String] {
        return list.compactMap { $0.symbol }
    }

    fileprivate var dataSource: [Section] {
        var sections: [Section] = []

        let section = Section(items: list)
        sections.append(section)

        return sections
    }

    fileprivate func load() -> [StockItem] {
        return list
    }

    fileprivate mutating func save(_ items: [StockItem]) {
        self.list = items
    }

    private var list: [StockItem] = UserDefaultsConfig.list {
        didSet {
            UserDefaultsConfig.list = list
        }
    }

}

private struct UserDefaultsConfig {
    @UserDefault("list", defaultValue: [])
    fileprivate static var list: [StockItem]
}

//private struct Section {
//
//    var header: String?
//    var items: [StockItem]?
//
//}

private extension StockItem {

    var attributedValue: NSAttributedString? {
        return quote?.value
    }

    var changeAttributedValue: NSAttributedString? {
        return quote?.changeValue
    }

    var percentAttributedValue: NSAttributedString? {
        return quote?.percentValue
    }

    var priceAttributedValue: NSAttributedString? {
        return quote?.priceAttributedValue
    }

}

private enum Sort {

    case change, percent, price, symbol

    var header: String {
        switch self {
        case .symbol:
            return "Alphabetical"
        case .percent:
            return "Percent Change"
        case .price:
            return "Current Price"
        case .change:
            return "Price Change"
        }
    }

}
