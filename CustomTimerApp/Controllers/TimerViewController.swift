//
//  TimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

final class TimerViewController: UIViewController {
    
    private enum Section {
        case mainTimer
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, CustomTimerComponent>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
        displayAllTimer()
        
    }
    
    @IBAction func addTimerButtonTapped(_ sender: Any) {
        let customTimerVC = CustomTimerViewController.instantiate()
        let navVC = UINavigationController(rootViewController: customTimerVC)
        present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let settingVC = SettingViewController.instantiate()
        let navVC = UINavigationController(rootViewController: settingVC)
        present(navVC, animated: true, completion: nil)
    }
    
    private func displayAllTimer(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CustomTimerComponent>()
        snapshot.appendSections([.mainTimer])
        let demo = [CustomTimerComponent(name: "ストレッチ", timeInfomations: [TimeInfomation(time: 10, photo: nil, text: nil)]),
                    CustomTimerComponent(name: "スクワット", timeInfomations: [TimeInfomation(time: 10, photo: nil, text: nil)]),
                    CustomTimerComponent(name: "ランニング", timeInfomations: [TimeInfomation(time: 10, photo: nil, text: nil)])]
        snapshot.appendItems(demo)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

}

extension TimerViewController: UICollectionViewDelegate {
    
}

extension TimerViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 1)
        let groupSpace = CGFloat(20)
        group.contentInsets = NSDirectionalEdgeInsets(top: groupSpace, leading: groupSpace, bottom: groupSpace, trailing: groupSpace)
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(TimerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: TimerCollectionViewCell.identifier)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CustomTimerComponent>(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, customTimerComponent in
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TimerCollectionViewCell.identifier, for: indexPath
            ) as? TimerCollectionViewCell else { fatalError("セルが見つかりませんでした") }
            cell.configure(timerName: customTimerComponent.name)
            cell.backgroundColor = .gray
            cell.layer.cornerRadius = 10
            return cell
        })
    }

}
