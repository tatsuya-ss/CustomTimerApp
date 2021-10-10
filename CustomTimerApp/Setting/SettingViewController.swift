//
//  SettingViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

final class SettingViewController: UIViewController {
    
    private enum Section: CaseIterable {
        case setting
        case app
    }
    
    private enum SettingCellType: CaseIterable {
        case setting
        
        var title: String {
            switch self {
            case .setting:
                return "設定"
            }
        }
    }
    
    private enum ApplicationCellType: CaseIterable {
        case operation
        case evaluation
        case inquiry
        case share
        
        var title: String {
            switch self {
            case .operation:
                return "操作方法"
            case .evaluation:
                return "このアプリを評価する"
            case .inquiry:
                return "お問い合わせ"
            case .share:
                return "このアプリをシェアする"
            }
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SettingViewController: UICollectionViewDelegate {
    
}

extension SettingViewController {
    
    private func createListLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createListLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration() // デフォルトのListCellを取得
            content.text = item
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        Section.allCases.forEach { section in
            snapshot.appendSections([section])
            switch section {
            case .setting:
                SettingCellType.allCases.forEach {
                    snapshot.appendItems([$0.title], toSection: section)
                }
            case .app:
                ApplicationCellType.allCases.forEach {
                    snapshot.appendItems([$0.title], toSection: section)
                }
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}
