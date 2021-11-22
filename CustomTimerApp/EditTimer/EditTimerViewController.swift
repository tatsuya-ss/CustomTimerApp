//
//  EditTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/15.
//

import UIKit
import Photos

extension EditTimerViewController: ShowAlertProtocol { }
extension EditTimerViewController: PerformBatchUpdatesProtocol { }

final class EditTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var restButton: UIButton!
    @IBOutlet private weak var photoButton: UIButton!
    
    private var customTimerComponent: CustomTimerComponent!
    private var editingIndexPath: IndexPath!
    private var timerUseCase: TimerUseCaseProtocol!
    func receiveCustomTimerComponent(customTimerComponent: CustomTimerComponent,
                                     editingIndexPath: IndexPath) {
        self.customTimerComponent = customTimerComponent
        self.editingIndexPath = editingIndexPath
    }
    private let indicator = Indicator()
    private let TimeStructures: [TimePickerViewStructure] = [Hour(), Minute(), Second()]
    private var selectedIndexPath: IndexPath = [0, 0]
    var didTappedSaveButton: ((IndexPath, CustomTimerComponent) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupModelInPresentation()
        setupTextField()
        setupPickerView()
        setupButton()
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        plusButton.layer.cornerRadius = plusButton.layer.frame.height / 2
        deleteButton.layer.cornerRadius = deleteButton.layer.frame.height / 2
        restButton.layer.cornerRadius = restButton.layer.frame.height / 2
        photoButton.layer.cornerRadius = photoButton.layer.frame.height / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        timerNameTextField.resignFirstResponder()
    }
    
    @IBAction private func saveButtonDidTapped(_ sender: Any) {
        guard let text = timerNameTextField.text,
              !text.isEmpty else {
                  showTimerNameEmptyAlert()
                  return
              }
        indicator.show(flashType: .progress)
        customTimerComponent.name = text
        timerUseCase.save(customTimer: customTimerComponent) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.indicator.flash(flashType: .error) {
                    self?.showErrorAlert(title: error.errorMessage)
                }
            case .success:
                self?.indicator.flash(flashType: .success) {
                    self?.writePhotoDataToCached()
                    guard let editingIndexPath = self?.editingIndexPath,
                          let customTimerComponent = self?.customTimerComponent else {
                              self?.dismiss(animated: true, completion: nil)
                              return
                          }
                    self?.didTappedSaveButton?(editingIndexPath, customTimerComponent)
                }
            }
        }
    }
    
    @IBAction private func cancelButtonDidTapped(_ sender: Any) {
        showDiscardChangesAlert()
    }
    
    @IBAction private func plusButtonDidTapped(_ sender: Any) {
        timerNameTextField.resignFirstResponder()
        let insertIndexPath = IndexPath(item: selectedIndexPath.item + 1, section: 0)
        let deselectedIndexPath = selectedIndexPath
        selectedIndexPath = insertIndexPath
        customTimerComponent.timeInfomations.insert(TimeInfomation(time: Time(hour: 0, minute: 0, second: 0), id: UUID().uuidString), at: insertIndexPath.item)
        insertCellWithAnimation(collectionView: collectionView,
                                insertIndexPath: insertIndexPath,
                                deselectedIndexPath: deselectedIndexPath)
        showSelectedTimeInPicker(indexPath: insertIndexPath)
    }
    
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        timerNameTextField.resignFirstResponder()
        getPhotosAuthorization()
    }
    
    @IBAction private func restButtonDidTapped(_ sender: Any) {
        timerNameTextField.resignFirstResponder()
        let insertIndexPath = IndexPath(item: selectedIndexPath.item + 1, section: 0)
        let deselectedIndexPath = selectedIndexPath
        selectedIndexPath = insertIndexPath
        customTimerComponent.timeInfomations
            .insert(TimeInfomation(time: Time(hour: 0, minute: 0, second: 0), type: .rest, id: UUID().uuidString),
                    at: insertIndexPath.item)
        insertCellWithAnimation(collectionView: collectionView,
                                insertIndexPath: insertIndexPath,
                                deselectedIndexPath: deselectedIndexPath)
        showSelectedTimeInPicker(indexPath: insertIndexPath)
    }
    
    @IBAction private func deleteButtonDidTapped(_ sender: Any) {
        timerNameTextField.resignFirstResponder()
        guard !customTimerComponent.timeInfomations.isEmpty else { return }
        customTimerComponent.timeInfomations.remove(at: selectedIndexPath.item)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [selectedIndexPath])
            adjustSelectedIndexWhenLastIndex()
        } completion: { [weak self] _ in
            self?.collectionView.reloadItems(at: [self?.selectedIndexPath ?? [0, 0]])
            self?.collectionView.scrollToItem(at: self?.selectedIndexPath ?? [0,0],
                                              at: .centeredHorizontally,
                                              animated: true)
        }
    }
    
    private func writePhotoDataToCached() {
        customTimerComponent.timeInfomations.forEach {
            let fileName = $0.id.makeJPGFileName()
            let cachesDirectoryPathURL = DirectoryManagement().makeCacheDirectoryPathURL(fileName: fileName)
            do {
                try $0.photo?.write(to: cachesDirectoryPathURL)
            } catch {
                print(error, "失敗")
            }
        }
    }
    
    private func adjustSelectedIndexWhenLastIndex() {
        let isLastIndex = (selectedIndexPath.item == customTimerComponent.timeInfomations.count)
        if isLastIndex { selectedIndexPath.item -= 1 }
    }
    
    private func showTimerNameEmptyAlert() {
        let alert = UIAlertController(title: "タイマー名を設定してください",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func getPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.showImagePickerController()
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showPhotosAuthorizationDeniedAlert()
                }
            default:
                break
            }
        }
    }
    
    private func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func makePhotoImage(timeInfomation: TimeInfomation) -> UIImage? {
        guard let imageData = timeInfomation.photo,
              let image = UIImage(data: imageData) else {
                  switch timeInfomation.type {
                  case .action: return UIImage(systemName: "timer")
                  case .rest: return UIImage(named: "yasumi")
                  }
              }
        return image
    }
    
    private func showDiscardChangesAlert() {
        showTwoChoicesAlert(alertTitle: "画面を閉じると編集中のタイマーの変更内容は反映されません。画面を閉じますか？",
                            cancelMessage: "キャンセル",
                            destructiveTitle: "閉じる",
                            handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func changeTimeOfSelectedTimer(row: Int, component: Int) {
        switch component {
        case 0: customTimerComponent.timeInfomations[selectedIndexPath.item].time.hour = row
        case 1: customTimerComponent.timeInfomations[selectedIndexPath.item].time.minute = row
        case 2: customTimerComponent.timeInfomations[selectedIndexPath.item].time.second = row
        default:
            break
        }
    }
    
    private func showSelectedTimeInPicker(indexPath: IndexPath = [0, 0]) {
        let currentTime = customTimerComponent.timeInfomations[indexPath.item].time
        timePickerView.selectRow(currentTime.hour, inComponent: 0, animated: true)
        timePickerView.selectRow(currentTime.minute, inComponent: 1, animated: true)
        timePickerView.selectRow(currentTime.second, inComponent: 2, animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension EditTimerViewController: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
                               [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        customTimerComponent.timeInfomations[selectedIndexPath.item].photo = selectedImage.convertImageToData()
        collectionView.reloadItems(at: [selectedIndexPath])
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension EditTimerViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDiscardChangesAlert()
    }
}

// MARK: - UITextFieldDelegate
extension EditTimerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

// MARK: - UICollectionViewDataSource
extension EditTimerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        customTimerComponent.timeInfomations.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EditTimerCollectionViewCell.identifier, for: indexPath
        ) as? EditTimerCollectionViewCell else { fatalError("セルが見つかりません") }
        let timeString = customTimerComponent.timeInfomations[indexPath.item].time.makeTimeString()
        let image = makePhotoImage(timeInfomation: customTimerComponent.timeInfomations[indexPath.item])
        let isYasumiImage = (image == UIImage(named: "yasumi"))
        let contentMode: UIView.ContentMode = isYasumiImage ? .scaleAspectFit : .scaleAspectFill
        let cellState: SelectCellState = (indexPath == selectedIndexPath) ? SelectedCell() : UnSelectedCell()
        cell.configure(image: image, timeString: timeString, contentMode: contentMode, cellState: cellState)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension EditTimerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        timerNameTextField.resignFirstResponder()
        let deselectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [deselectedIndexPath, indexPath])
        } completion: { _ in
            collectionView.scrollToItem(at: indexPath,
                                        at: .centeredHorizontally,
                                        animated: true)
        }
        
        showSelectedTimeInPicker(indexPath: indexPath)
    }
}

// MARK: - UICollectionViewDragDelegate
extension EditTimerViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let timeInfomation = customTimerComponent.timeInfomations[indexPath.item]
        let object = timeInfomation.id as NSString
        let itemProvider = NSItemProvider(object: object)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
}

// MARK: - UICollectionViewDropDelegate
extension EditTimerViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if session.localDragSession == nil {
            return UICollectionViewDropProposal(operation: .copy,
                                                intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .move,
                                                intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let sourceIndexPath = coordinator.items.first?.sourceIndexPath,
              let dragItem = coordinator.items.first?.dragItem
        else { return }
        selectedIndexPath = destinationIndexPath
        collectionView.performBatchUpdates {
            let sourceItem = customTimerComponent.timeInfomations.remove(at: sourceIndexPath.item)
            customTimerComponent.timeInfomations.insert(sourceItem, at: destinationIndexPath.item)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        }
        coordinator.drop(dragItem, toItemAt: destinationIndexPath)
    }
    
}


// MARK: - UIPickerViewDataSource
extension EditTimerViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        TimeStructures.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        TimeStructures[component].timeRange.count
    }
    
}

// MARK: - UIPickerViewDelegate
extension EditTimerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        row.description
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        changeTimeOfSelectedTimer(row: row, component: component)
        collectionView.reloadItems(at: [selectedIndexPath])
    }
    
}

// MARK: - setup
extension EditTimerViewController {
    
    static func instantiate(timerUseCase: TimerUseCaseProtocol = TimerUseCase()) -> EditTimerViewController {
        guard let editTimerVC = UIStoryboard(name: "EditTimer", bundle: nil)
                .instantiateViewController(withIdentifier: "EditTimerViewController")
                as? EditTimerViewController
        else { fatalError("EditTimerViewControllerが見つかりません。") }
        editTimerVC.timerUseCase = timerUseCase
        return editTimerVC
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = EditTimerCollectionViewFlowLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.register(EditTimerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: EditTimerCollectionViewCell.identifier)
        collectionView.layer.cornerRadius = 20
    }
    
    private func setupModelInPresentation() {
        // プルダウンジェスチャーによる解除を無効
        isModalInPresentation = true
    }
    
    private func setupTextField() {
        timerNameTextField.delegate = self
        timerNameTextField.keyboardType = .namePhonePad
        timerNameTextField.text = customTimerComponent.name
    }
    
    private func setupPickerView() {
        timePickerView.dataSource = self
        timePickerView.delegate = self
//        setupPickerViewUnits()
        showSelectedTimeInPicker()
    }
    
//    private func setupPickerViewUnits() {
//        // 後に表示修正
//        var unitlabels: [UILabel] = []
//        let fontSize = CGFloat(15)
//        let labelTop = timePickerView.bounds.origin.y + timePickerView.bounds.height / 2 - fontSize
//        let labelHeight = timePickerView.rowSize(forComponent: 0).height
//        var labelOffset = timePickerView.bounds.origin.x
//        // 変更
//        TimeStructures.forEach {
//            let row = $0.row
//            if unitlabels.count == row {
//                let label = UILabel()
//                label.backgroundColor = .systemBlue
//                label.text = $0.unit
//                label.font = UIFont.boldSystemFont(ofSize: fontSize)
//                label.sizeToFit()
//
//                timePickerView.addSubview(label)
//                unitlabels.append(label)
//            }
//            let labelWidth = unitlabels[row].frame.width
//            labelOffset += timePickerView.rowSize(forComponent: row).width
//            print(labelWidth, labelOffset)
//            unitlabels[row].frame = CGRect(x: labelOffset - labelWidth,
//                                           y: labelTop,
//                                           width: labelWidth,
//                                           height: labelHeight)
//        }
//    }
    
    private func setupButton() {
        [photoButton, restButton, deleteButton, plusButton]
            .forEach { $0?.isExclusiveTouch = true }
    }

}
