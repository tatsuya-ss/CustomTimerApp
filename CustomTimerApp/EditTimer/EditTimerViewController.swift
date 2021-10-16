//
//  EditTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/15.
//

import UIKit
import Photos

extension EditTimerViewController: ShowAlertProtocol{ }

final class EditTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var plusButton: UIButton!
    
    private var customTimerComponent: CustomTimerComponent!
    func receiveCustomTimerComponent(customTimerComponent: CustomTimerComponent) {
        self.customTimerComponent = customTimerComponent
    }
    
    private var deselectedIndexPath: IndexPath = []
    private var selectedIndexPath: IndexPath = [0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupModelInPresentation()
        setupTextField()
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        plusButton.layer.cornerRadius = plusButton.layer.frame.height / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        timerNameTextField.resignFirstResponder()
    }
    
    @IBAction private func saveButtonDidTapped(_ sender: Any) {
        
    }
    
    @IBAction private func cancelButtonDidTapped(_ sender: Any) {
        showDiscardChangesAlert()
    }
    
    @IBAction private func plusButtonDidTapped(_ sender: Any) {
        insertCell()
    }
        
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        getPhotosAuthorization()
    }
    
    private func insertCell() {
        customTimerComponent.timeInfomations.append(
            TimeInfomation(time: Time(hour: 0, minute: 0, second: 0))
        )
        let lastIndexPathItem = customTimerComponent.timeInfomations.count - 1
        let insertIndexPath = IndexPath(item: lastIndexPathItem,
                                        section: 0)
        deselectedIndexPath = selectedIndexPath
        selectedIndexPath = insertIndexPath
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [insertIndexPath])
            collectionView.reloadItems(at: [deselectedIndexPath])
        } completion: { _ in
            self.collectionView.scrollToItem(at: insertIndexPath,
                                             at: .centeredHorizontally,
                                             animated: true)
        }
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
              let image = UIImage(data: imageData) else { return UIImage(systemName: "timer") }
        return image
    }
    
    private func showDiscardChangesAlert() {
        showTwoChoicesAlert(alertTitle: "画面を閉じると編集中のタイマーは破棄されます。よろしいですか？",
                            cancelMessage: "キャンセル",
                            destructiveTitle: "破棄する",
                            handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
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
        cell.configure(image: image, timeString: timeString)
        indexPath == selectedIndexPath
        ? cell.selectedCell()
        : cell.unselectedCell()
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension EditTimerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        deselectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: [deselectedIndexPath, indexPath])
        } completion: { _ in
            collectionView.scrollToItem(at: indexPath,
                                        at: .centeredHorizontally,
                                        animated: true)
        }
    }
}

// MARK: - setup
extension EditTimerViewController {
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = EditTimerCollectionViewFlowLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
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
    
}
