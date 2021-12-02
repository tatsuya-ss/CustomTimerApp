//
//  TimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

extension TimerViewController: ShowAlertProtocol { }

final class TimerViewController: UIViewController {
    
    private enum Section {
        case mainTimer
    }
    
    private enum OperationState {
        case timer
        case edit
        case delete
        
        init(operationState: Self = .timer) {
            self = operationState
        }
        
        mutating func changeState(state: Self) {
            self = state
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var settingButton: UIBarButtonItem!
    @IBOutlet private weak var toolBar: UIToolbar!
    @IBOutlet private weak var deleteButton: UIBarButtonItem!
    
    private var editBarButton: UIBarButtonItem {
        UIBarButtonItem(title: "編集", menu: makeEditMenu())
    }
    private var cancelBarButton: UIBarButtonItem {
        UIBarButtonItem(title: "キャンセル",
                        style: .plain,
                        target: self,
                        action: #selector(cancelBarButtonDidTapped))
    }
    
    private var userUseCase: UserUseCaseProtocol = UserUseCase()
    private var timerUseCase: TimerUseCaseProtocol = TimerUseCase()
    private var dataSource: UICollectionViewDiffableDataSource<Section, CustomTimerComponent>! = nil
    private var customTimers: [CustomTimerComponent] = []
    private var operationState = OperationState()
    // DiffableDataSourceの性質上,didselectRowAtやdidDeselectRowAtが上手くいかないので、ここで選択したindexを管理して、全部の処理をdidSelectItemAtで行う(他にいい方法あるかもしれないが)
    private var selectedIndexPath: [IndexPath] = []
    private let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogInState()
        configureHierarchy()
        configureDataSource()
        updateCollectionView()
        setupLongPressRecognizer()
        setupNavigation()
        setupToolBar()
    }
    
    @IBAction private func settingButtonDidTapped(_ sender: Any) {
        let settingVC = SettingViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: settingVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonDidTapped(_ sender: Any) {
        showDeleteAlert()
    }
    
}

// MARK: - func
extension TimerViewController {
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "選択したタイマーを削除しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { [weak self] alert in
            guard let selectedIndexPath = self?.selectedIndexPath,
                  let customTimers = self?.customTimers else { return }
            self?.indicator.show(flashType: .progress)
            let deleteTimers = selectedIndexPath.map { customTimers[$0.item] }
            self?.timerUseCase.delete(customTimer: deleteTimers) { result in
                switch result {
                case .failure(let error):
                    self?.indicator.flash(flashType: .error) {
                        print(error)
                    }
                case .success:
                    self?.indicator.flash(flashType: .success) {
                        self?.selectedIndexPath
                            .sorted { $1 < $0 }
                            .forEach { self?.customTimers.remove(at: $0.item) }
                        self?.updateCollectionView()
                        self?.selectedIndexPath.removeAll()
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func fetchTimers() {
        indicator.show(flashType: .progress)
        timerUseCase.fetch { [weak self] result in
            switch result {
            case .failure(let error):
                self?.indicator.flash(flashType: .error) {
                    self?.showErrorAlert(title: error.errorMessage)
                }
            case .success(let customTimers):
                self?.indicator.flash(flashType: .success) {
                    DispatchQueue.main.async {
                        self?.customTimers = self?.sortCreatedDate(customTimers: customTimers) ?? customTimers
                        self?.updateCollectionView()
                        self?.deleteUnnecessaryStorage()
                    }
                }
            }
        }
    }
    
    private func deleteUnnecessaryStorage() {
        // アプリ起動時に不要データがあれば削除するだけの処理なので、削除処理が失敗しても成功しても特にやることはない
        timerUseCase.deleteUnnecessaryStorage(customTimer: customTimers) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
    }
    
    // オプショナル値のsortのやり方。以下の記事参考にした。
    // https://qiita.com/mishimay/items/59fba10170ed2ff7690a
    private func sortCreatedDate(customTimers: [CustomTimerComponent]) -> [CustomTimerComponent] {
        customTimers.sorted { l,r -> Bool in
            switch (l.createdDate, r.createdDate) {
            case (.some(let l), .some(let r)):
                return l < r
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return false
            }
        }
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
            self?.customTimers[indexPath.item] = customTimerComponent
            self?.updateCollectionView()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateCollectionView(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CustomTimerComponent>()
        snapshot.appendSections([.mainTimer])
        snapshot.appendItems(customTimers, toSection: .mainTimer)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func makeEditMenu() -> UIMenu {
        let addTimerAction = UIAction(title: "タイマーを作成",
                                      state: .off) { [weak self] _ in
            if let customTimers = self?.customTimers,
               customTimers.count < 3 {
                self?.presentCustomTimerVC()
            } else {
                self?.showBillingAlert()
            }
        }
        let editTimerAction = UIAction(title: "タイマーを編集",
                                       state: .off) { [weak self] _ in
            self?.navigationItem.title = "タイマーを編集"
            self?.navigationItem.rightBarButtonItem = self?.cancelBarButton
            self?.settingButton.isEnabled = false
            self?.operationState.changeState(state: .edit)
        }
        let deleteTimerAction = UIAction(title: "タイマーを削除",
                                         state: .off) { [weak self] _ in
            self?.navigationItem.title = "削除するタイマーを選択"
            self?.navigationItem.rightBarButtonItem = self?.cancelBarButton
            self?.settingButton.isEnabled = false
            self?.toolBar.isHidden = false
            self?.deleteButton.isEnabled = false
            self?.operationState.changeState(state: .delete)
            guard let selectedIndexPath = self?.collectionView.indexPathsForSelectedItems else { return }
            selectedIndexPath.forEach { self?.collectionView.deselectItem(at: $0, animated: true) }
        }
        let editMenu = UIMenu(children: [addTimerAction,
                                         editTimerAction,
                                         deleteTimerAction])
        return editMenu
    }
    
    private func showBillingAlert() {
        let alert = UIAlertController(title: "４つ以上のタイマー作成は課金が必要になります。課金機能は今後実装予定です。", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
        switch operationState {
        case .timer:
            let startTimerVC = StartTimerViewController.instantiate(customTimerComponent: customTimers[indexPath.item])
            let navigationController = UINavigationController(rootViewController: startTimerVC)
            navigationController.presentationController?.delegate = startTimerVC
            present(navigationController, animated: true, completion: nil)
            collectionView.deselectItem(at: indexPath, animated: true)
        case .edit:
            collectionView.deselectItem(at: indexPath, animated: true)
            presentEditTimerVC(indexPath: indexPath)
        case .delete:
            customTimers[indexPath.item].isSelected.toggle()
            updateCollectionView()
            let isSelected = selectedIndexPath.contains(indexPath)
            if isSelected { selectedIndexPath.removeAll(where: { $0 == indexPath }) }
            else { selectedIndexPath.append(indexPath) }
            deleteButton.isEnabled = !selectedIndexPath.isEmpty
            print(selectedIndexPath)
        }
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
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(TimerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: TimerCollectionViewCell.identifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CustomTimerComponent>(collectionView: collectionView, cellProvider: {
            collectionView, indexPath, customTimerComponent in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TimerCollectionViewCell.identifier, for: indexPath
            ) as? TimerCollectionViewCell else { fatalError("セルが見つかりませんでした") }
            let isHidden = (self.customTimers[indexPath.item].isSelected == true) ? false : true
            let alpha = isHidden ? 1.0 : 0.5
            let image = (customTimerComponent.timeInfomations.first?.photo == nil)
            ? UIImage(systemName: "timer")
            : UIImage(data: customTimerComponent.timeInfomations.first!.photo!)
            cell.configure(timerName: customTimerComponent.name,
                           image: image,
                           isHidden: isHidden,
                           alpha: alpha)
            return cell
        })
    }
    
}

// MARK: - setup
extension TimerViewController {
    
    static func instantiate(userUseCase: UserUseCaseProtocol = UserUseCase()) -> TimerViewController {
        guard let timerVC = UIStoryboard(name: "Timer", bundle: nil)
                .instantiateViewController(withIdentifier: "TimerViewController")
                as? TimerViewController
        else { fatalError("TimerViewControllerが見つかりません。") }
        return timerVC
    }
    
    
    private func setupLogInState() {
        userUseCase.logInStateListener { [weak self] result in
            switch result {
            case .failure:
                self?.customTimers.removeAll()
                self?.updateCollectionView()
                let signUpOrLogInVC = SignUpOrLogInViewController.instantiate()
                let navigationController = UINavigationController(rootViewController: signUpOrLogInVC)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true, completion: nil)
            case .success:
                self?.fetchTimers()
            }
        }
    }
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                               action: #selector(longPressRecognizer))
        longPressRecognizer.allowableMovement = 10
        longPressRecognizer.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = editBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func setupToolBar() {
        toolBar.isHidden = true
    }
    
}

// MARK: - @objc
extension TimerViewController {
    
    @objc private func longPressRecognizer(sender: UILongPressGestureRecognizer) {
        guard operationState == .timer || operationState == .edit else { return }
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
    
    @objc private func cancelBarButtonDidTapped() {
        navigationItem.rightBarButtonItem = editBarButton
        settingButton.isEnabled = true
        navigationItem.title = "タイマー"
        toolBar.isHidden = true
        operationState.changeState(state: .timer)
        selectedIndexPath.removeAll()
        customTimers.enumerated()
            .filter { $0.element.isSelected == true }
            .forEach { customTimers[$0.offset].isSelected = false }
        updateCollectionView()
    }
    
}

