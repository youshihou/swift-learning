//
//  InsertionSortViewController.swift
//  collectionView
//
//  Created by Ankui on 6/26/20.
//  Copyright © 2020 Ankui. All rights reserved.
//

import UIKit


class InsertionSortArray: Hashable {
    struct SortNode: Hashable {
        let value: Int
        let color: UIColor
        
        private let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: SortNode, rhs: SortNode) -> Bool {
            lhs.identifier == rhs.identifier
        }

        
        init(value: Int, maxValue: Int) {
            self.value = value
            let hue = CGFloat(value) / CGFloat(maxValue)
            self.color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
    }
    
    var values: [SortNode] {
        return nodes
    }
    var isSorted: Bool {
        return isSortedInternal
    }

    func sortNext() {
        performNextSortStep()
    }
    private func performNextSortStep() {
        if isSortedInternal { return }
        if nodes.count == 1 {
            isSortedInternal = true
            return
        }
        
        var index = currentIndex
        let currentNode = nodes[index]
        index -= 1
        while index >= 0 && currentNode.value < nodes[index].value {
            let tmp = nodes[index]
            nodes[index] = currentNode
            nodes[index + 1] = tmp
            index -= 1
        }
        currentIndex += 1
        if currentIndex >= nodes.count {
            isSortedInternal = true
        }
    }
    
    init(count: Int) {
        nodes = (0..<count).map { SortNode(value: $0, maxValue: count) }.shuffled()
    }
    
    private var currentIndex = 1
    private var isSortedInternal = false
    private var nodes: [SortNode]
    
    private var identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: InsertionSortArray, rhs: InsertionSortArray) -> Bool {
        lhs.identifier == rhs.identifier
    }
}




class InsertionSortViewController: UIViewController {
    static let nodeSize = CGSize(width: 16, height: 34)
    static let resuseIdentifier = "cell-id"
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<InsertionSortArray, InsertionSortArray.SortNode>! = nil
    var isSorting = false
    var isSorted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Insertion Sort Visualizer"
        
        congigureView()
        congigureDataSource()
        congigureNavItem()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if dataSource != nil {
            let bounds = collectionView.bounds
            let snapshot = randomizedSnapshot(for: bounds)
            dataSource.apply(snapshot)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = Int(contentSize.width / InsertionSortViewController.nodeSize.width)
            let rowHeight = InsertionSortViewController.nodeSize.height
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(rowHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
    
    private func congigureView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .black
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: InsertionSortViewController.resuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func congigureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<InsertionSortArray, InsertionSortArray.SortNode>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, node: InsertionSortArray.SortNode) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InsertionSortViewController.resuseIdentifier, for: indexPath)
            cell.backgroundColor = node.color
            return cell
        }
        
        let bounds = collectionView.bounds
        let snapshot = randomizedSnapshot(for: bounds)
        dataSource.apply(snapshot)
    }

    private func congigureNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: isSorting ? "Stop" : "Sort", style: .plain, target: self, action: #selector(toggleSort))
    }
    @objc private func toggleSort() {
        isSorting.toggle()
        if isSorting {
            performSortStep()
        }
        congigureNavItem()
    }
    private func performSortStep() {
        if !isSorting { return }
        
        var sectionCountNeedingSort = 0
        
        // get the current state of the UI from the data source.
        var updatedSnapshot = dataSource.snapshot()
        
        // for each section, if neeed, step through and perform the next sorting step.
        updatedSnapshot.sectionIdentifiers.forEach {
            let section = $0
            if !section.isSorted {
                // step the sort algorithm
                section.sortNext()
                let items = section.values
                // replace the items for this section with the newly sorted items.
                updatedSnapshot.deleteItems(items)
                updatedSnapshot.appendItems(items, toSection: section)
                
                sectionCountNeedingSort += 1
            }
        }
        
        var shouldRest = false
        var delay = 125
        if sectionCountNeedingSort > 0 {
            dataSource.apply(updatedSnapshot)
        } else {
            delay = 1000
            shouldRest = true
        }
        let bounds = collectionView.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            if shouldRest {
                let snapshot = self.randomizedSnapshot(for: bounds)
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            self.performSortStep()
        }
    }
    private func randomizedSnapshot(for bounds: CGRect) -> NSDiffableDataSourceSnapshot<InsertionSortArray, InsertionSortArray.SortNode> {
        var snapshot = NSDiffableDataSourceSnapshot<InsertionSortArray, InsertionSortArray.SortNode>()
        let rowCount = rows(for: bounds)
        let columnCout = columns(for: bounds)
        for _ in 0..<rowCount {
            let section = InsertionSortArray(count: columnCout)
            snapshot.appendSections([section])
            snapshot.appendItems(section.values)
        }
        return snapshot
    }
    private func rows(for bounds: CGRect) -> Int {
        Int(bounds.height / InsertionSortViewController.nodeSize.height)
    }
    private func columns(for bounds: CGRect) -> Int {
        Int(bounds.width / InsertionSortViewController.nodeSize.width)
    }
}
