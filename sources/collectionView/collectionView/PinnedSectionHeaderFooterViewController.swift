//
//  PinnedSectionHeaderFooterViewController.swift
//  collectionView
//
//  Created by Ankui on 6/27/20.
//  Copyright © 2020 Ankui. All rights reserved.
//

import UIKit

class PinnedSectionHeaderFooterViewController: UIViewController {
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    var collectionView: UICollectionView! = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Pinned Section Headers"
        
        configureView()
        configureDataSource()
    }
    
    private func createLayout() ->UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44)), elementKind: PinnedSectionHeaderFooterViewController.sectionHeaderElementKind, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44)), elementKind: PinnedSectionHeaderFooterViewController.sectionFooterElementKind, alignment: .bottom)
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = 2
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: PinnedSectionHeaderFooterViewController.sectionHeaderElementKind, withReuseIdentifier: TitleSupplementaryView.identifier)
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: PinnedSectionHeaderFooterViewController.sectionFooterElementKind, withReuseIdentifier: TitleSupplementaryView.identifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.identifier, for: indexPath) as? ListCell else {
                fatalError()
            }
            cell.label.text = "\(indexPath.section),\(indexPath.item)"
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let headerFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.identifier, for: indexPath) as? TitleSupplementaryView else {
                fatalError()
            }
            headerFooter.label.text = "\(kind) for section \(indexPath.section)"
            return headerFooter
        }
        
        let itemPerSection = 5
        let sections = Array(0..<5)
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var itemOffset = 0
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(Array(itemOffset..<itemOffset + itemPerSection))
            itemOffset += itemPerSection
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}


extension PinnedSectionHeaderFooterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
