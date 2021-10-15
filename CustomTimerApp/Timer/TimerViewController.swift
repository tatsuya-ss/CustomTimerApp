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
    private var customTimers: [CustomTimerComponent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
        displayAllTimer()
        setupLongPressRecognizer()
        
    }
    
    @IBAction func addTimerButtonTapped(_ sender: Any) {
        let customTimerVC = CustomTimerViewController.instantiate()
        customTimerVC.delegate = self
        let navigationController = UINavigationController(rootViewController: customTimerVC)
        navigationController.presentationController?.delegate = customTimerVC
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let settingVC = SettingViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: settingVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    private func displayAllTimer(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CustomTimerComponent>()
        snapshot.appendSections([.mainTimer])
        snapshot.appendItems(customTimers)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
}

extension TimerViewController: CustomTimerViewControllerDelegate {
    
    func didTapSaveButton(_ customTimerViewController: CustomTimerViewController,
                          customTimerComponent: CustomTimerComponent) {
        customTimers.append(customTimerComponent)
        var snapshot = NSDiffableDataSourceSnapshot<Section, CustomTimerComponent>()
        snapshot.appendSections([.mainTimer])
        snapshot.appendItems(customTimers, toSection: .mainTimer)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension TimerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let startTimerVC = StartTimerViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: startTimerVC)
        startTimerVC.getCustomTimer(customTimer: customTimers[indexPath.item])
        navigationController.presentationController?.delegate = startTimerVC
        present(navigationController, animated: true, completion: nil)
    }
    
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
            if let data = customTimerComponent.timeInfomations.first?.photo {
                let image = UIImage(data: data)
                cell.configure(timerName: customTimerComponent.name,
                               image: image)
            } else {
                cell.configure(timerName: customTimerComponent.name,
                image: UIImage(systemName: "timer"))
            }
            cell.backgroundColor = .gray
            cell.layer.cornerRadius = 10
            return cell
        })
    }
    
}

extension TimerViewController {
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(longPressRecognizer))
        longPressRecognizer.allowableMovement = 10
        longPressRecognizer.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func longPressRecognizer(sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        if let indexPath = indexPath {
            switch sender.state {
            case .began:
                presentCustomTimerVC()
                print("bagan, \(indexPath)")
            default: break
            }
        }
    }
    
}
