//
//  ItemBadgeSupplementaryViewController.swift
//  collectionView
//
//  Created by Ankui on 6/27/20.
//  Copyright © 2020 Ankui. All rights reserved.
//

import UIKit


class BadgeSupplementaryView: UICollectionReusableView {
    static let identifier = "badge-reues-identifier"
    
    let label = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)
        
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.textColor = .black
        
        backgroundColor = .green
        configureBorder()
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    override var frame: CGRect {
        didSet {
            configureBorder()
        }
    }
    override var bounds: CGRect {
        didSet {
            configureBorder()
        }
    }

    private func configureBorder() {
        let radius = bounds.width / 2.0
        layer.cornerRadius = radius
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
    }
}




class ItemBadgeSupplementaryViewController: UIViewController {
    static let badgeElementKind = "badge-element-kind"
    
    enum Section {
        case main
    }

    struct Model: Hashable {
        let title: String
        let badgeCount: Int
        
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Model>! = nil
    var collectionView: UICollectionView! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Item Badges"
        
        configureView()
        configureDataSource()
    }
    
    /// - Tag: Badge
    private func createLayout() -> UICollectionViewLayout {
        let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.3, y: -0.3))
        let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20), heightDimension: .absolute(20))
        let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize, elementKind: ItemBadgeSupplementaryViewController.badgeElementKind, containerAnchor: badgeAnchor)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func configureView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
        collectionView.register(BadgeSupplementaryView.self, forSupplementaryViewOfKind: ItemBadgeSupplementaryViewController.badgeElementKind, withReuseIdentifier: BadgeSupplementaryView.identifier)
        view.addSubview(collectionView)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Model>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, model: Model) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as? GridCell else {
                fatalError("Cannot create new cell")
            }
            cell.label.text = model.title
            
            cell.contentView.layer.cornerRadius = 8
            return cell
        }
        dataSource.supplementaryViewProvider = {
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let badgeView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BadgeSupplementaryView.identifier, for: indexPath) as? BadgeSupplementaryView else {
                fatalError("Cannot create new badgeView")
            }

            guard let model = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            let hasBadgeCount = model.badgeCount > 0
            // set the badge count as its label (and hide the view if the badge count is zero)
            badgeView.label.text = "\(model.badgeCount)"
            badgeView.isHidden = !hasBadgeCount
            
            return badgeView
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Model>()
        snapshot.appendSections([.main])
        let models = (0..<100).map { Model(title: "\($0)", badgeCount: Int.random(in: 0..<3)) }
        snapshot.appendItems(models)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}
