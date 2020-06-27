//
//  WiFiSettingsViewController.swift
//  collectionView
//
//  Created by Ankui on 6/26/20.
//  Copyright © 2020 Ankui. All rights reserved.
//

import UIKit



class WiFiController {
    struct Network: Hashable {
        let name: String
        
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: Network, rhs: Network) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }
    
    typealias UpdateHanler = (WiFiController) -> Void
    
    init(updateHandler: @escaping UpdateHanler) {
        self.updateHandler = updateHandler
        updateAvailableNetworks(allNetworks)
        _perfomRandomUpdate()
    }
    
    var scanForNetworks = true
    var wifiEnabled = true
    var availableNetworks: Set<Network> {
        _availableNetworks
    }
    
    func network(for identifier: UUID) -> Network? {
        _availableNetworksDict[identifier]
    }
    
    
    
    // MARK: - Internal
    private let updateHandler: UpdateHanler
    private var _availableNetworks = Set<Network>()
    private let updateInterval = 2000
    private var _availableNetworksDict = [UUID: Network]()
    
    private func _perfomRandomUpdate() {
        if wifiEnabled && scanForNetworks {
            let shouldUpdate = true
            if shouldUpdate {
                var updatedNetworks = Array(_availableNetworks)
                if updatedNetworks.isEmpty {
                    _availableNetworks = Set<Network>(allNetworks)
                } else {
                    let shouldRemove = Int.random(in: 0..<3) == 0
                    if shouldRemove {
                        let removeCount = Int.random(in: 0..<updatedNetworks.count)
                        for _ in 0..<removeCount {
                            let removeIndex = Int.random(in: 0..<updatedNetworks.count)
                            updatedNetworks.remove(at: removeIndex)
                        }
                    }
                    
                    let shouldAdd = Int.random(in: 0..<3) == 0
                    if shouldAdd {
                        let allNetworksSet = Set<Network>(allNetworks)
                        var updateedNetworksSet = Set<Network>(updatedNetworks)
                        let notPresentNetworksSet = allNetworksSet.subtracting(updateedNetworksSet)
                        if !notPresentNetworksSet.isEmpty {
                            let addCount = Int.random(in: 0..<notPresentNetworksSet.count)
                            var notPresentNetworks = [Network](notPresentNetworksSet)
                            for _ in 0..<addCount {
                                let removeIndex = Int.random(in: 0..<notPresentNetworks.count)
                                let networkToAdd = notPresentNetworks[removeIndex]
                                notPresentNetworks.remove(at: removeIndex)
                                updateedNetworksSet.insert(networkToAdd)
                            }
                        }
                        updatedNetworks = [Network](updateedNetworksSet)
                    }
                    updateAvailableNetworks(updatedNetworks)
                }
                // notify
                updateHandler(self)
            }
        }
        
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(updateInterval)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self._perfomRandomUpdate()
        }
    }
    
    func updateAvailableNetworks(_ networks: [Network]) {
        _availableNetworks = Set<Network>(networks)
        _availableNetworksDict.removeAll()
        for network in _availableNetworks {
            _availableNetworksDict[network.identifier] = network
        }
    }
    
    private let allNetworks = [ Network(name: "AirSpace1"),
                                Network(name: "Living Room"),
                                Network(name: "Courage"),
                                Network(name: "Nacho WiFi"),
                                Network(name: "FBI Surveillance Van"),
                                Network(name: "Peacock-Swagger"),
                                Network(name: "GingerGymnist"),
                                Network(name: "Second Floor"),
                                Network(name: "Evergreen"),
                                Network(name: "__hidden_in_plain__sight__"),
                                Network(name: "MarketingDropBox"),
                                Network(name: "HamiltonVille"),
                                Network(name: "404NotFound"),
                                Network(name: "SNAGVille"),
                                Network(name: "Overland101"),
                                Network(name: "TheRoomWiFi"),
                                Network(name: "PrivateSpace")
    ]
}




class WiFiSettingsViewController: UIViewController {
    enum Section: CaseIterable {
        case config, networks
    }
    
    enum ItemType {
        case wifiEnabled, currentNetwork, availableNetwork
    }
    
    struct Item: Hashable {
        let title: String
        let type: ItemType
        let network: WiFiController.Network?
        
        private let identifier: UUID
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        init(title: String, type: ItemType) {
            self.title = title
            self.type = type
            self.network = nil
            self.identifier = UUID()
        }
        init(network: WiFiController.Network) {
            self.title = network.name
            self.type = .availableNetwork
            self.network = network
            self.identifier = network.identifier
        }
        var isConfig: Bool {
            let configItems: [ItemType] = [.currentNetwork, .wifiEnabled]
            return configItems.contains(type)
        }
        var isNetwork: Bool {
            return type == .availableNetwork
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var dataSource: UITableViewDiffableDataSource<Section, Item>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>! = nil
    var wifiController: WiFiController! = nil
    lazy var configurationItems: [Item] = {
        [Item(title: "Wi-Fi", type: .wifiEnabled),
         Item(title: "breeno-net", type: .currentNetwork)]
    }()
    
    static let reuseIdentifier = "reuse-identifier"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Wi-Fi"
        
        configureView()
        configureDataSource()
        updateUI(animated: false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Insertion Sort", style: .plain, target: self, action: #selector(pushNextPage))
    }
    
    @objc private func pushNextPage() {
        let vc = InsertionSortViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: WiFiSettingsViewController.reuseIdentifier)
    }
    
    private func configureDataSource() {
        wifiController = WiFiController { [weak self] (controller: WiFiController) in
            guard let self = self else { return }
            self.updateUI()
        }
        
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
            guard let self = self, let wifiController = self.wifiController else { return nil }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: WiFiSettingsViewController.reuseIdentifier, for: indexPath)
//            var content = cell.def
            
            // network cell
            if item.isNetwork {
                cell.textLabel?.text = item.title
                cell.accessoryType = .detailDisclosureButton
                cell.accessoryView = nil
                
            // configuration cells
            } else if item.isConfig {
                cell.textLabel?.text = item.title
                if item.type == .wifiEnabled {
                    let enableWiFiSwitch = UISwitch()
                    enableWiFiSwitch.isOn = wifiController.wifiEnabled
                    enableWiFiSwitch.addTarget(self, action: #selector(self.toggleWiFi(_:)), for: .touchUpInside)
                    cell.accessoryView = enableWiFiSwitch
                } else {
                    cell.accessoryView = nil
                    cell.accessoryType = .detailDisclosureButton
                }
            } else {
                fatalError("Unknown item type!")
            }
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        
        wifiController.scanForNetworks = true
    }
    
    @objc private func toggleWiFi(_ wifiEnableSwitch: UISwitch) {
        wifiController.wifiEnabled = wifiEnableSwitch.isOn
        updateUI()
    }
    
    private func updateUI(animated: Bool = true) {
        guard let controller = wifiController else { return }
        
        let configItems = configurationItems.filter { !($0.type == .currentNetwork && !controller.wifiEnabled) }
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        currentSnapshot.appendSections([.config])
        currentSnapshot.appendItems(configItems, toSection: .config)
        if controller.wifiEnabled {
            let sortedNetworks = controller.availableNetworks.sorted { $0.name < $1.name }
            let networkItems = sortedNetworks.map { Item(network: $0) }
            currentSnapshot.appendSections([.networks])
            currentSnapshot.appendItems(networkItems, toSection: .networks)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}
