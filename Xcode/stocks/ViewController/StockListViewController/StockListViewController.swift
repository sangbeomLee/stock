//
//  MyStocksViewController.swift
//  stocks
//
//  Created by Daniel on 5/28/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

// TODO: - Timer 를 두어 몇 초마다 계속 리프레쉬 되게 만들자.
// TODO: - 정렬법 다르게 변경하기
class StockListViewController: UIViewController {
    // UI
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addStockButton: UIButton!
    
    private let refreshControl = UIRefreshControl()

    // TODO: - updateLabel 삭제 -> 개선 Label
    private var updateLabel = UpdateLabel()
    
    weak var coordinator: Coordinator?
    
    private let networkManager = StockNetworkManager.shared
    private let storage = StockStorage.shared
    // TODO: - naming 에 관한 고민..!
    private var stockItems: [StockItem]? {
        didSet {
            tableView.reloadData()
            refreshControl.endRefreshing()
            updateFooterLabel()

            // TODO: - 정렬만 해서 바뀌었을때도 저장이 되는데 이 부분은 생각 해 보자.
            guard let items = stockItems else { return }
            storage.saveStockItems(items)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addStock()
    }

    // Data
    private var sort: Sort = .percent

    var footerView: UpdateLabel {
        let label = UpdateLabel()

        var f = view.bounds
        f.size.height = 15
        label.frame = f

        updateLabel = label
        updateLabel.provider = .finnhub

        return label
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupView()
        setItems()
        
        loadStockItems()
    }
    
    func setItems() {
        stockItems = StockStorage.shared.loadStockItems()
    }
}

private extension StockListViewController {
    func setupNavigation() {
        title = "Stock List"
        navigationController?.navigationBar.prefersLargeTitles = true
        updateNavBar()
    }
    
    func setupView() {
        setupTableView()
        
        refreshControl.addTarget(self, action: #selector(loadStockItems), for: .valueChanged)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = self.footerView

        tableView.isHidden = storage.isEmpty
        addStockButton.isHidden = !storage.isEmpty
    }

    // TODO: - UI 수정할 때 updateNavBar 고칠 것
    func updateNavBar(_ isEditing: Bool = false) {
        if isEditing {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(editStocks))

            navigationItem.rightBarButtonItems = [doneButton]
        }
        else {
            let image = UIImage(systemName: "plus")
            let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addStock))

            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editStocks))

            navigationItem.rightBarButtonItems = stockItems?.count ?? 0 == 0 ?
                [addButton] : [editButton, addButton]
        }
    }
}

@objc
private extension StockListViewController {
    func addStock() {
        let s = AddStockViewController()
        s.modalPresentationStyle = .formSheet
        s.provider = .finnhub
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
        guard let items = stockItems else { return }
        let symbols = items.compactMap { $0.symbol }

        networkManager.fetch(dataType: Finnhub.Quote.self, for: symbols) { [weak self] results in
            guard let self = self else { return }
    
            var fetchItems = [StockItem]()
            results.forEach { symbol, result in
                switch result {
                case .success(let quote):
                    // TODO: - myQuote 개선하기
                    let fetchItem = StockItem(symbol: symbol, quote: quote.quote)
                    fetchItems.append(fetchItem)
                case .failure(let error):
                    // TODO: - error 처리
                    print(error)
                }
            }
            
            // TODO: -  밑 부분 로직 다시짜기
            // TODO: - UI 관련 해서 짜기
            self.stockItems = fetchItems
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
    }

}

// MARK: - UIupdate

private extension StockListViewController {
    func updateFooterLabel() {
        updateLabel.date = Date()
        updateLabel.update()
    }
}

private extension StockListViewController {
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

// MARK: - UITableViewDelegate

extension StockListViewController: UITableViewDelegate {

    // TODO: UI Header View 를 따로 만들자. (어떤 지표인지 알려주는 Label 도 같이 넣어주자.)
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

        // TODO: BUTTON TITLE
        let title = "   \(sort.header)    "
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
        return "test"
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stockItems?.remove(at: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = stockItems?[indexPath.row] else { return }

        // TODO: - Coordinate pattern 으로 극복하기.
        let d = DetailViewController()
        d.provider = .finnhub
        d.item = item
        d.modalPresentationStyle = .formSheet

        let n = UINavigationController(rootViewController: d)
        n.navigationBar.prefersLargeTitles = true
        n.navigationBar.largeTitleTextAttributes = Theme.attributes
        present(n, animated: true, completion: nil)
    }

}

// MARK: - UITableViewDataSource

extension StockListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: - customCell 로 만들어 cell 에서 처리하기.
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "id")

        if let item = stockItems?[indexPath.row] {
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

extension StockListViewController: AddStockViewControllerDelegate {
    func didSelect(stock: String?) {
        guard let stock = stock else { return }

        let item = StockItem(symbol: stock)

        guard stockItems?.contains(item) == false else { return }

        stockItems?.append(item)

        updateNavBar()
        loadStockItems()
    }
}

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
