//
//  CustomTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

extension TimeInfomation {
    static var testTimerInfomations: [TimeInfomation] = [TimeInfomation(time: 10, photo: nil, text: "テストa"),
                                                         TimeInfomation(time: 9, photo: nil, text: "テストb"),
                                                         TimeInfomation(time: 8, photo: nil, text: "テストc"),
                                                         TimeInfomation(time: 7, photo: nil, text: "テストd"),
                                                         TimeInfomation(time: 6, photo: nil, text: "テストe")]
    static var testNoTimes: [TimeInfomation] = []
}

final class CustomTimerViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var timerContentsCollectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    
    private var timerInfomations: [TimeInfomation] = TimeInfomation.testNoTimes
    private var dataSource: UICollectionViewDiffableDataSource<Section,TimeInfomation>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
        
    }
    
    @IBAction private func saveTimerButtonTapped(_ sender: Any) {
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension CustomTimerViewController: UICollectionViewDelegate {
    
}

extension CustomTimerViewController {
    
    private func configureHierarchy() {
        timerContentsCollectionView.collectionViewLayout = createLayout()
        timerContentsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timerContentsCollectionView.backgroundColor = .systemBackground
        timerContentsCollectionView.delegate = self
        timerContentsCollectionView.register(CustomTimerCollectionViewCell.nib,
                                             forCellWithReuseIdentifier: CustomTimerCollectionViewCell.identifier)
        timerContentsCollectionView.register(PlusButtonCollectionViewCell.nib,
                                             forCellWithReuseIdentifier: PlusButtonCollectionViewCell.identifier)
        timerContentsCollectionView.isScrollEnabled = false
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, TimeInfomation>(
            collectionView: timerContentsCollectionView,
            cellProvider: { collectionView, indexPath, timeInfomationItem in
                if indexPath.item == self.timerInfomations.count {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PlusButtonCollectionViewCell.identifier, for: indexPath
                    ) as? PlusButtonCollectionViewCell else { fatalError("セルが見つかりません") }
                    cell.configure(image: UIImage(systemName: "plus")!)
                    return cell
                }
                
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CustomTimerCollectionViewCell.identifier,
                        for: indexPath) as? CustomTimerCollectionViewCell else { fatalError("セルが見つかりません") }
                cell.configure(image: UIImage(systemName: "timer")!)
                return cell
            })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, TimeInfomation>()
        Section.allCases.forEach {
            snapshot.appendSections([$0])
            switch $0 {
            case .main:
                snapshot.appendItems(timerInfomations)
                snapshot.appendItems([TimeInfomation(time: 0, photo: nil, text: nil)])
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitem: item,
                                                     count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5,
                                                      leading: 5,
                                                      bottom: 5,
                                                      trailing: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    
}
