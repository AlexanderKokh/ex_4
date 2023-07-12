
import UIKit

struct TemplateData: Hashable {
    
    let number: Int
    var checked: Bool
}

final class ViewController: UIViewController {
    
    let tableView = UITableView()
    private lazy var navBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        return navBar
    }()
    var data: [TemplateData] = []
                    
    var dataSource: UITableViewDiffableDataSource<Int, TemplateData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 1...40 {
            data.append(TemplateData(number: index, checked: false))
        }
        
        configureNavBar()
   
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        ])
        
        tableView.rowHeight = 30
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource = UITableViewDiffableDataSource<Int, TemplateData>(tableView: tableView) { (tableView, indexPath, model) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell else {
                return UITableViewCell()
            }
            
            cell.textLabel?.text = "\(model.number)"
            cell.isChecked = model.checked
            cell.tapHandler = { [weak self] in
                self?.toggleCheckmark(for: model)
            }
            
            return cell
        }
        
        applySnapshot()
    }
    
    private func configureNavBar() {
        navBar.backgroundColor = .white
        view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: "Task 4")
        let doneItem = UIBarButtonItem(title: "Перемешать", image: nil, target: nil, action: #selector(shuffleCells))
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        navBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, TemplateData>()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func toggleCheckmark(for number: TemplateData) {
        guard let index = data.firstIndex(of: number) else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        
        if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
            cell.isChecked.toggle()
            data[index].checked = cell.isChecked
            if cell.isChecked {
                let item = data[index]
                data.remove(at: index)
                data.insert(item, at: 0)
                UIView.animate(withDuration: 0.5) {
                    self.applySnapshot()
                }
            }
        }
    }
    
    @objc
    private func shuffleCells() {
        data.shuffle()
        applySnapshot()
    }
}

final class TableViewCell: UITableViewCell {
    var isChecked = false {
        didSet {
            accessoryType = isChecked ? .checkmark : .none
        }
    }
    
    var tapHandler: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cellTapped() {
        tapHandler?()
    }
}
