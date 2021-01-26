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
// TODO: - naming, -> stockList: stockSubscriptionList, addStock: stockList << how about?
class StockListViewController: UIViewController {
    weak var coordinator: StockListCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addStockButton: UIButton!
    
    private var footerView: StockListFooterView?
    // TODO: - headerView 에서 어떤 부분이 있는지 표기하기 sort 에 따라서 어떤것인지 분간이 안간다.
    private var headerView: StockListHeaderView?
    
    private let networkManager = StockNetworkManager.shared
    private let storage = StockStorage.shared
    
    // TODO: - naming 에 관한 고민..!
    private var stockItems: [StockItem]? {
        didSet {
            stockItemsDidSet()
        }
    }
    
    private var sort: Sort = .percent {
        didSet {
            headerView?.sortButtonTitle = sort.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupView()
        setItems()
        loadStockItems()
    }
}

// MARK: - Setup

private extension StockListViewController {
    func setupNavigation() {
        // TODO: - 왜? navigationController 에서 타이틀을 정하는게아니라 ViewController 에서 정하는지 알아보기.
        title = "Stock List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        updateNavigationBarButtons()
    }
    
    // 계속 새로 만들고 있는데 만들어놓고 hidden처리 하는 식으로 변경하자. -> NavigationBar 는 Hidden 이 없다.
    func updateNavigationBarButtons(_ isEditing: Bool = false) {
        if isEditing {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(setEditingButton))

            navigationItem.rightBarButtonItems = [doneButton]
        }
        else {
            let image = UIImage(systemName: "plus")
            let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showAddStockViewController))

            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(setEditingButton))

            navigationItem.rightBarButtonItems = stockItems?.count ?? 0 == 0 ?
                [addButton] : [editButton, addButton]
        }
    }
    
    func setupView() {
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        setupHeaderFooterView()
        setupRefreshControl()
    }

    func setupHeaderFooterView() {
        footerView = StockListFooterView()
        tableView.tableFooterView = footerView
        
        headerView = StockListHeaderView()
        headerView?.frame = tableView.bounds
        headerView?.frame.size.height = 40
        tableView.tableHeaderView = headerView
        
        headerView?.sortButtonTitle = sort.title
        
        // TODO: - 여기서 말고 headerView 자체 func 에서 해결하도록 해 보자
        headerView?.sortButton.addTarget(self, action: #selector(sortButtonDidTapped), for: .touchUpInside)
    }
    
    func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadStockItems), for: .valueChanged)
    }
    
    func setItems() {
        stockItems = storage.loadStockItems()
        tableView.isHidden = stockItems?.count == 0
        addStockButton.isHidden = !tableView.isHidden
    }
}

// MARK: - Objc Func

@objc
private extension StockListViewController {
    func showAddStockViewController() {
        coordinator?.createAddStockViewController()
    }

    func setEditingButton() {
        let isEditing = !tableView.isEditing
        updateNavigationBarButtons(isEditing)
        tableView.setEditing(isEditing, animated: true)
    }
    
    func loadStockItems() {
        guard let items = stockItems else { return }
        let symbols = items.compactMap { $0.symbol }

        networkManager.fetch(dataType: StockNetworkModel.Quote.self, for: symbols) { [weak self] results in
            guard let self = self else { return }
    
            var fetchItems = [StockItem]()
            results.forEach { symbol, result in
                switch result {
                case .success(let quote):
                    // TODO: - myQuote 개선하기
                    let fetchItem = StockItem(symbol: symbol, quoteModel: quote.quoteModel)
                    fetchItems.append(fetchItem)
                case .failure(let error):
                    // TODO: - error 처리
                    print(error)
                }
            }
            
            self.stockItems = fetchItems
        }
    }

    func sortButtonDidTapped() {
        sort = sort.next
        sortItems()
    }
}

// MARK: - Private Func

private extension StockListViewController {
    func updateFooterLabel() {
        footerView?.updatedInfoLabel.text = "updated Date Label"
    }
    
    func stockItemsDidSet() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        updateFooterLabel()

        // TODO: - 정렬만 해서 바뀌었을때도 저장이 되는데 이 부분은 생각 해 보자.
        guard let items = stockItems else { return }
        storage.saveStockItems(items)
    }
    
    func sortItems() {
        switch sort {
        case .symbol:
            stockItems?.sort { $0.symbol ?? "" < $1.symbol ?? "" }
        case .change:
            stockItems?.sort { $0.quoteModel?.change ?? 0 > $1.quoteModel?.change ?? 0 }
        case .percent:
            stockItems?.sort { $0.quoteModel?.percent ?? 0 > $1.quoteModel?.percent ?? 0 }
        case .price:
            stockItems?.sort { $0.quoteModel?.price ?? 0 > $1.quoteModel?.price ?? 0 }
        }
    }
}

// MARK: - UITableViewDelegate

extension StockListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stockItems?.remove(at: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = stockItems?[indexPath.row] else { return }

        coordinator?.createStockDetailViewController(item)
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

// MARK: - Action

private extension StockListViewController {
    @IBAction func addButtonTapped(_ sender: Any) {
        showAddStockViewController()
    }
}

extension StockListViewController: AddStockViewControllerDelegate {
    func didSelect(stock: String?) {
        guard let stock = stock else { return }

        let item = StockItem(symbol: stock)

        guard stockItems?.contains(item) == false else { return }

        stockItems?.append(item)

        updateNavigationBarButtons()
        loadStockItems()
    }
}
