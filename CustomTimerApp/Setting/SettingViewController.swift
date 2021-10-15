//
//  SettingViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

struct TitleCellData: Hashable {
    let title: String
}

enum Item: Hashable {
    case title(TitleCellData)
}

final class SettingViewController: UIViewController {
    
    private enum Section: CaseIterable {
        case setting
        case app
        var items: [Item] {
            switch self {
            case .setting: return SettingItem.allCases.map { $0.item }
            case .app: return ApplicationItem.allCases.map { $0.item}
            }
        }
    }
    
    private enum SettingItem: CaseIterable {
        case setting
        var item: Item {
            switch self {
            case .setting: return .title(TitleCellData(title: "設定"))
            }
        }
    }
    
    private enum ApplicationItem: Int, CaseIterable {
        case operation
        case evaluation
        case inquiry
        case share
        var item: Item {
            switch self {
            case .operation: return .title(TitleCellData(title: "操作方法"))
            case .evaluation: return .title(TitleCellData(title: "このアプリを評価する"))
            case .inquiry: return .title(TitleCellData(title: "お問い合わせ"))
            case .share: return .title(TitleCellData(title: "このアプリをシェアする"))
            }
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func showActivityVC() {
        // TODO: このアプリのURLに変更
        guard let shareUrl = URL(string: "https://apps.apple.com/jp/app/movie-reviews-%E6%98%A0%E7%94%BB%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC%E7%AE%A1%E7%90%86/id1578614989")
        else { return }
        let activityVC = UIActivityViewController(activityItems: [shareUrl],
                                                  applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    private func showRequestReviewManually() {
        // TODO: このアプリのURLに変更
        guard let writeReviewURL = URL(string: "https://apps.apple.com/jp/app/movie-reviews-%E6%98%A0%E7%94%BB%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC%E7%AE%A1%E7%90%86/id1578614989?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
}

extension SettingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let section = Section.allCases[indexPath.section]
        switch section {
        case .setting:
            switch SettingItem.allCases[indexPath.item] {
            case .setting: break
            }
        case .app:
            switch ApplicationItem.allCases[indexPath.item] {
            case .operation: break
            case .evaluation: showRequestReviewManually()
            case .inquiry: break
            case .share: showActivityVC()
            }
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            cell.accessories = [.disclosureIndicator()]
            var content = cell.defaultContentConfiguration() // デフォルトのListCellを取得
            switch item {
            case .title(let data): content.text = data.title
            }
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        Section.allCases.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
