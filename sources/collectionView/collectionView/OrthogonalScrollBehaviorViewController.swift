//
//  OrthogonalScrollBehaviorViewController.swift
//  collectionView
//
//  Created by Ankui on 6/28/20.
//  Copyright © 2020 Ankui. All rights reserved.
//

import UIKit

class OrthogonalScrollBehaviorViewController: UIViewController {
    static let headerElementKind = "header-element-kind"
    
    enum SectionKind: Int, CaseIterable {
        case continuous, continuousGroupLeadingBoundary, paging, groupPaging, groupPagingCentered, none
        func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .none:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.none
            case .continuous:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
            case .continuousGroupLeadingBoundary:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
            case .paging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.paging
            case .groupPaging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPaging
            case .groupPagingCentered:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Orthogonal Section Behaviors"
        
        configureView()
        configureDataSource()
    }

    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else { fatalError("unknown section kind") }
            
            let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)), subitem: trailingItem, count: 2)
            
            let orthogonallyScrolls = sectionKind.orthogonalScrollingBehavior() != .none
            let containerGroupFractionalWidth = orthogonallyScrolls ? CGFloat(0.85) : CGFloat(1.0)
            let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth), heightDimension: .fractionalHeight(0.4)), subitems: [leadingItem, trailingGroup])
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44)), elementKind: OrthogonalScrollBehaviorViewController.headerElementKind, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }, configuration: config)
        
        return layout
    }
    
    private func configureView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: OrthogonalScrollBehaviorViewController.headerElementKind, withReuseIdentifier: TitleSupplementaryView.identifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as? GridCell else {
                fatalError()
            }
            cell.label.text = "\(indexPath.section), \(indexPath.item)"
            cell.contentView.layer.cornerRadius = 8
            return cell
        }
        dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.identifier, for: indexPath) as? TitleSupplementaryView else {
                fatalError()
            }
            guard let sectionKind = SectionKind(rawValue: indexPath.section) else {
                fatalError()
            }
            header.label.text = "." + String(describing: sectionKind)
            return header
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var identifierOffset = 0
        let itemsPerSection = 18
        SectionKind.allCases.forEach {
            snapshot.appendSections([$0.rawValue])
            let maxIdentifier = identifierOffset + itemsPerSection
            snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
            identifierOffset += itemsPerSection
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}


extension OrthogonalScrollBehaviorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
