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
    @IBOutlet private weak var settingButton: UIBarButtonItem!
    
    private var editBarButton: UIBarButtonItem {
        UIBarButtonItem(title: "編集", menu: makeEditMenu())
    }
    private var cancelBarButton: UIBarButtonItem {
        UIBarButtonItem(title: "キャンセル",
                        style: .plain,
                        target: self,
                        action: #selector(cancelBarButtonDidTapped))
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, CustomTimerComponent>! = nil
    private var customTimers: [CustomTimerComponent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        updateCollectionView()
        setupLongPressRecognizer()
        setupNavigation()
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let settingVC = SettingViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: settingVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    private func presentCustomTimerVC() {
        let customTimerVC = CustomTimerViewController.instantiate()
        customTimerVC.delegate = self
        let navigationController = UINavigationController(rootViewController: customTimerVC)
        navigationController.presentationController?.delegate = customTimerVC
        present(navigationController, animated: true, completion: nil)
    }

    private func presentEditTimerVC(indexPath: IndexPath) {
        let editTimerVC = EditTimerViewController.instantiate()
        editTimerVC.receiveCustomTimerComponent(customTimerComponent: customTimers[indexPath.item], editingIndexPath: indexPath)
        let navigationController = UINavigationController(rootViewController: editTimerVC)
        navigationController.presentationController?.delegate = editTimerVC
        present(navigationController, animated: true, completion: nil)
        
        // MARK: didTappedSaveButton
        editTimerVC.didTappedSaveButton = { [weak self] indexPath, customTimerComponent in
            guard let strongSelf = self else { return }
            strongSelf.customTimers[indexPath.item] = customTimerComponent
            strongSelf.updateCollectionView()
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateCollectionView(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CustomTimerComponent>()
        snapshot.appendSections([.mainTimer])
        snapshot.appendItems(customTimers, toSection: .mainTimer)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
}

// MARK: - CustomTimerViewControllerDelegate
extension TimerViewController: CustomTimerViewControllerDelegate {
    
    func didTapSaveButton(_ customTimerViewController: CustomTimerViewController,
                          customTimerComponent: CustomTimerComponent) {
        customTimers.append(customTimerComponent)
        updateCollectionView()
    }
    
}

// MARK: - UICollectionViewDelegate
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

// MARK: - UICollectionView
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

// MARK: - setup
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
                presentEditTimerVC(indexPath: indexPath)
            default: break
            }
        }
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = editBarButton
    }
    
    private func makeEditMenu() -> UIMenu {
        let addTimerAction = UIAction(title: "タイマーを作成",
                                      state: .off) { [weak self] _ in
            self?.presentCustomTimerVC()
        }
        let editTimerAction = UIAction(title: "タイマーを編集",
                                       state: .off) { [weak self] _ in
            self?.navigationItem.title = "タイマーを編集"
            self?.navigationItem.rightBarButtonItem = self?.cancelBarButton
            self?.settingButton.isEnabled = false
        }
        let deleteTimerAction = UIAction(title: "タイマーを削除",
                                       state: .off) { [weak self] _ in
            self?.navigationItem.title = "削除するタイマーを選択"
            self?.navigationItem.rightBarButtonItem = self?.cancelBarButton
            self?.settingButton.isEnabled = false
        }
        let editMenu = UIMenu(children: [addTimerAction,
                                         editTimerAction,
                                         deleteTimerAction])
        return editMenu
    }
    
    @objc private func cancelBarButtonDidTapped() {
        navigationItem.rightBarButtonItem = editBarButton
        settingButton.isEnabled = true
        navigationItem.title = "タイマー"
    }
}
