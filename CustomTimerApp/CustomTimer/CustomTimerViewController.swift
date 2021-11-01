//
//  CustomTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit
import Photos

extension CustomTimerViewController: ShowAlertProtocol { }
extension CustomTimerViewController: PerformBatchUpdatesProtocol { }

protocol CustomTimerViewControllerDelegate: AnyObject {
    func didTapSaveButton(_ customTimerViewController: CustomTimerViewController,
                          customTimerComponent: CustomTimerComponent)
}

final class CustomTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var restButton: UIButton!
    @IBOutlet private weak var photoButton: UIButton!
    
    private var customTimerComponent = CustomTimerComponent(
        name: "タイマー１",
        timeInfomations: [TimeInfomation(time: Time(hour: 0, minute: 0, second: 0))]
    )
    private var selectedIndexPath: IndexPath = [0, 0]
    private let TimeStructures: [TimePickerViewStructure] = [Hour(), Minute(), Second()]
    weak var delegate: CustomTimerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPickerView()
        setupTextField()
        setupModelInPresentation()
        setupButton()
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
    
    @IBAction private func saveTimerButtonDidTapped(_ sender: Any) {
        guard let text = timerNameTextField.text,
              !text.isEmpty else {
                  showAlert(title: "タイマー名を設定してください",
                            defaultTitle: "閉じる")
                  return
              }
        customTimerComponent.name = text
        delegate?.didTapSaveButton(self, customTimerComponent: customTimerComponent)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        showDiscardChangesAlert()
    }
    
    // TODO: plusを押してすぐdeleteを押すと出るエラー修正 "Attempted to scroll the collection view to an out-of-bounds item (0) when there are only 0 items in section 0."
    @IBAction func plusButtonDidTapped(_ sender: Any) {
        let insertIndexPath = IndexPath(item: selectedIndexPath.item + 1, section: 0)
        let deselectedIndexPath = selectedIndexPath
        selectedIndexPath = insertIndexPath
        customTimerComponent.timeInfomations.insert(TimeInfomation(time: Time(hour: 0, minute: 0, second: 0)), at: insertIndexPath.item)
        insertCellWithAnimation(collectionView: collectionView,
                                insertIndexPath: insertIndexPath,
                                deselectedIndexPath: deselectedIndexPath)
        showSelectedTimeInPicker(indexPath: insertIndexPath)
    }
    
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        getPhotosAuthorization()
    }
    
    @IBAction private func restButtonDidTapped(_ sender: Any) {
        let insertIndexPath = IndexPath(item: selectedIndexPath.item + 1, section: 0)
        let deselectedIndexPath = selectedIndexPath
        selectedIndexPath = insertIndexPath
        customTimerComponent.timeInfomations
            .insert(TimeInfomation(time: Time(hour: 0, minute: 0, second: 0), type: .rest),
                    at: insertIndexPath.item)
        insertCellWithAnimation(collectionView: collectionView,
                                insertIndexPath: insertIndexPath,
                                deselectedIndexPath: deselectedIndexPath)
        showSelectedTimeInPicker(indexPath: insertIndexPath)
    }
    
    @IBAction func deleteButtonDidTapped(_ sender: Any) {
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
    
    private func adjustSelectedIndexWhenLastIndex() {
        let isLastIndex = (selectedIndexPath.item == customTimerComponent.timeInfomations.count)
        if isLastIndex { selectedIndexPath.item -= 1 }
    }
    
    private func showDiscardChangesAlert() {
        showTwoChoicesAlert(alertTitle: "画面を閉じると編集中のタイマーは破棄されます。よろしいですか？",
                            cancelMessage: "キャンセル",
                            destructiveTitle: "破棄する",
                            handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
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
    
    private func changeTimeOfSelectedTimer(row: Int, component: Int) {
        switch component {
        case 0: customTimerComponent.timeInfomations[selectedIndexPath.item].time.hour = row
        case 1: customTimerComponent.timeInfomations[selectedIndexPath.item].time.minute = row
        case 2: customTimerComponent.timeInfomations[selectedIndexPath.item].time.second = row
        default:
            break
        }
    }
    
    private func makePhotoImage(timeInfomation: TimeInfomation) -> UIImage? {
        guard let imageData = timeInfomation.photo,
              let image = UIImage(data: imageData) else {
                  switch timeInfomation.type {
                  case .action: return UIImage(systemName: "timer")
                  case .rest: return UIImage(systemName: "stop.circle")
                  }
              }
        return image
    }
    
    private func showSelectedTimeInPicker(indexPath: IndexPath = [0, 0]) {
        let currentTime = customTimerComponent.timeInfomations[indexPath.item].time
        timePickerView.selectRow(currentTime.hour, inComponent: 0, animated: true)
        timePickerView.selectRow(currentTime.minute, inComponent: 1, animated: true)
        timePickerView.selectRow(currentTime.second, inComponent: 2, animated: true)
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CustomTimerViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDiscardChangesAlert()
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension CustomTimerViewController: UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        customTimerComponent.timeInfomations[selectedIndexPath.item].photo = selectedImage.convertImageToData()
        collectionView.reloadItems(at: [selectedIndexPath])
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDataSource
extension CustomTimerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        customTimerComponent.timeInfomations.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomTimerCollectionViewCell.identifier,
            for: indexPath) as? CustomTimerCollectionViewCell
        else { fatalError("セルが見つかりません") }
        
        let timeString = customTimerComponent.timeInfomations[indexPath.item].time.makeTimeString()
        let image = makePhotoImage(timeInfomation: customTimerComponent.timeInfomations[indexPath.item])
        switch customTimerComponent.timeInfomations[indexPath.item].type {
        case .action: cell.changeBackgroungOfImageView(color: .systemBackground)
        case .rest: cell.changeBackgroungOfImageView(color: .systemGreen)
        }
        cell.configure(image: image, timeString: timeString)
        indexPath == selectedIndexPath
        ? cell.selectedCell()
        : cell.unselectedCell()
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension CustomTimerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
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
// TODO: ドラッグの際に消してる背景が表示される
extension CustomTimerViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let timeInfomation = customTimerComponent.timeInfomations[indexPath.item]
        let object = timeInfomation.id.uuidString as NSString
        let itemProvider = NSItemProvider(object: object)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
}

// MARK: - UICollectionViewDropDelegate
extension CustomTimerViewController: UICollectionViewDropDelegate {
    
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
extension CustomTimerViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        TimeStructures.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        TimeStructures[component].timeRange.count
    }
    
}

// MARK: - UIPickerViewDelegate
extension CustomTimerViewController: UIPickerViewDelegate {
    
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

// MARK: - UITextFieldDelegate
extension CustomTimerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

// MARK: - setup
extension CustomTimerViewController {
    
    static func instantiate() -> CustomTimerViewController {
        guard let customTimerVC = UIStoryboard(name: "CustomTimer", bundle: nil)
                .instantiateViewController(withIdentifier: "CustomTimerViewController")
                as? CustomTimerViewController
        else { fatalError("CustomTimerViewControllerが見つかりません。") }
        return customTimerVC
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = CustomTimerCollectionViewFlowLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTimerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: CustomTimerCollectionViewCell.identifier)
        collectionView.layer.cornerRadius = 20
    }
    
    private func setupPickerView() {
        timePickerView.dataSource = self
        timePickerView.delegate = self
        setupPickerViewUnits()
    }
    
    private func setupPickerViewUnits() {
        var unitlabels: [UILabel] = []
        let fontSize = CGFloat(15)
        let labelTop = timePickerView.bounds.origin.y + timePickerView.bounds.height / 2 - fontSize
        let labelHeight = timePickerView.rowSize(forComponent: 0).height
        var labelOffset = timePickerView.bounds.origin.x
        // 変更
        TimeStructures.forEach {
            let row = $0.row
            if unitlabels.count == row {
                let label = UILabel()
                label.backgroundColor = .systemBlue
                label.text = $0.unit
                label.font = UIFont.boldSystemFont(ofSize: fontSize)
                label.sizeToFit()
                
                timePickerView.addSubview(label)
                unitlabels.append(label)
            }
            let labelWidth = unitlabels[row].frame.width
            labelOffset += timePickerView.rowSize(forComponent: row).width
            print(labelWidth, labelOffset)
            unitlabels[row].frame = CGRect(x: labelOffset - labelWidth,
                                           y: labelTop,
                                           width: labelWidth,
                                           height: labelHeight)
        }
    }
    
    private func setupTextField() {
        timerNameTextField.delegate = self
        timerNameTextField.keyboardType = .namePhonePad
    }
    
    private func setupModelInPresentation() {
        // プルダウンジェスチャーによる解除を無効
        isModalInPresentation = true
    }
    
    private func setupButton() {
        [photoButton, restButton, deleteButton, plusButton]
            .forEach { $0?.isExclusiveTouch = true }
    }
    
}
