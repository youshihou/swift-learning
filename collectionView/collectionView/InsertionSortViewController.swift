//
//  InsettionSortViewController.swift
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
        index = -1
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

        navigationItem.title = "Insertation"
    }

}
