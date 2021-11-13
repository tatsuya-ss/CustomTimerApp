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
        fetchTimers()
    }
    
    @IBAction private func settingButtonDidTapped(_ sender: Any) {
        let settingVC = SettingViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: settingVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonDidTapped(_ sender: Any) {
        selectedIndexPath
            .sorted { $1 < $0 }
            .forEach { customTimers.remove(at: $0.item) }
        updateCollectionView()
        selectedIndexPath.removeAll()
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
                        self?.customTimers = customTimers
                        self?.updateCollectionView()
                    }
                }
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
            self?.presentCustomTimerVC()
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
            let startTimerVC = StartTimerViewController.instantiate()
            let navigationController = UINavigationController(rootViewController: startTimerVC)
            startTimerVC.getCustomTimer(customTimerComponent: customTimers[indexPath.item])
            navigationController.presentationController?.delegate = startTimerVC
            present(navigationController, animated: true, completion: nil)
        case .edit:
            presentEditTimerVC(indexPath: indexPath)
        case .delete:
            customTimers[indexPath.item].isSelected.toggle()
            updateCollectionView()
            let isSelected = selectedIndexPath.contains(indexPath)
            if isSelected { selectedIndexPath.removeAll(where: { $0 == indexPath }) }
            else { selectedIndexPath.append(indexPath) }
            if selectedIndexPath.isEmpty { deleteButton.isEnabled = false }
            else { deleteButton.isEnabled = true }
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
        collectionView.backgroundColor = .systemBackground
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
            let image = (customTimerComponent.timeInfomations.first?.photo == nil)
            ? UIImage(systemName: "timer")
            : UIImage(data: customTimerComponent.timeInfomations.first!.photo!)
            cell.configure(timerName: customTimerComponent.name,
                           image: image,
                           isHidden: isHidden)
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
                let signUpOrLogInVC = SignUpOrLogInViewController.instantiate()
                let navigationController = UINavigationController(rootViewController: signUpOrLogInVC)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true, completion: nil)
            case .success:
                print("ログイン済み")
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
    }
    
    private func setupToolBar() {
        toolBar.isHidden = true
    }
    
}

// MARK: - @objc
extension TimerViewController {
    
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

// MARK: - errorMessage
private extension DataBaseError {
    
    var errorMessage: String {
        switch self {
        case .aborted: return "操作中止されました。"
        case .alreadyExists: return "すでに保存されています。"
        case .cancelled: return "捜査がキャンセルされました。"
        case .deadlineExceeded: return "時間内に保存が完了しませんでした。"
        case .notFound: return "ドキュメントが見つかりませんでした。"
        case .permissionDenied: return "権限がありません。"
        case .unauthenticated: return "有効な認証情報がありません。"
        case .unknown: return "予期しないエラーが発生しました。"
      
        case .objectNotFound: return "オブジェクトが存在しません。"
        case .bucketNotFound: return "設定されているバケットはありません。"
        case .projectNotFound: return "プロジェクトがありません。"
        case .quotaExceeded: return "バケットのクオータが超過しました。"
        case .unauthorized: return "実行権限がありません。"
        case .retryLimitExceeded: return "操作の最大制限時間を超えました。"
        case .nonMatchingChecksum: return "チェックサムが一致しません。"
        case .downloadSizeExceeded: return "ダウンロードファイルのサイズがメモリ容量を超えています。"
        case .invalidArgument: return "無効な引数が指定されました。"
        }
    }

}
