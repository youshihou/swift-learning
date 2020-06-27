//
//  AdaptiveSectionsViewController.swift
//  collectionView
//
//  Created by Ankui on 6/27/20.
//  Copyright © 2020 Ankui. All rights reserved.
//

import UIKit

class AdaptiveSectionsViewController: UIViewController {
    enum SectionLayoutKind: Int, CaseIterable {
        case list, grid5, grid3
        func columnCount(for width: CGFloat) -> Int {
            let wideMode = width > 723 // why 800 not work???, 724
            switch self {
            case .grid3:
                return wideMode ? 6 : 3
            case .grid5:
                return wideMode ? 10 : 5
            case .list:
                return wideMode ? 2 : 1
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Adaptive Sections"
        
        configureView()
        configureDataSource()
    }
    
    private func createLayout() ->UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let layoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            
            let columns = layoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupHeight = layoutKind == .list ? NSCollectionLayoutDimension.absolute(44) : NSCollectionLayoutDimension.fractionalWidth(0.2)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            return section
        }
        return layout
    }
    
    private func configureView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let layoutKind = SectionLayoutKind(rawValue: indexPath.section) else { return nil }
            if layoutKind == .list {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.identifier, for: indexPath) as? ListCell else {
                    fatalError("Cannot create new cell")
                }
                cell.label.text = "\(identifier)"
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as? GridCell else {
                    fatalError("Cannot create new cell")
                }
                cell.contentView.layer.cornerRadius = (layoutKind == .grid5) ? 8 : 0
                
                cell.label.text = "\(identifier)"
                return cell
            }
        }
        
        let itemPerSection = 10
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
        SectionLayoutKind.allCases.forEach {
            snapshot.appendSections([$0])
            let itemOffset = $0.rawValue * itemPerSection
            let itemUpperbound = itemOffset + itemPerSection
            snapshot.appendItems(Array(itemOffset..<itemUpperbound))
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}


extension AdaptiveSectionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
