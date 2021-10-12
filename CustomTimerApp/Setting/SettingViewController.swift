//
//  SettingViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

final class SettingViewController: UIViewController {
    
    private enum Section: Int, CaseIterable {
        case setting
        case app
        var titles: [String] {
            switch self {
            case .setting:
                return SettingItem.allCases.map { $0.title }
            case .app:
                return ApplicationItem.allCases.map { $0.title }
            }
        }
    }
    
    private enum SettingItem: Int, CaseIterable {
        case setting
        
        var title: String {
            switch self {
            case .setting:
                return "設定"
            }
        }
    }
    
    private enum ApplicationItem: Int, CaseIterable {
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
    
    private func showActivityVC() {
        guard let shareUrl = URL(string: "https://apps.apple.com/jp/app/movie-reviews-%E6%98%A0%E7%94%BB%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC%E7%AE%A1%E7%90%86/id1578614989")
        else { return }
        let activityVC = UIActivityViewController(activityItems: [shareUrl],
                                                  applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}

extension SettingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let section = Section.allCases[indexPath.section]
        let item = section.titles[indexPath.item]
        switch indexPath {
        case [Section.setting.rawValue, SettingItem.setting.rawValue]:
            break
        case [Section.app.rawValue, ApplicationItem.operation.rawValue]:
            break
        case [Section.app.rawValue, ApplicationItem.evaluation.rawValue]:
            break
        case [Section.app.rawValue, ApplicationItem.inquiry.rawValue]:
            break
        case [Section.app.rawValue, ApplicationItem.share.rawValue]:
            showActivityVC()
        default: break
        }
    }
    
}

// MARK: - CollectionView関連
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
            cell.accessories = [.disclosureIndicator()]
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
            snapshot.appendItems(section.titles, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
