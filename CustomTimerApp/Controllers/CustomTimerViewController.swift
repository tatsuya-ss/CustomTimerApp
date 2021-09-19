//
//  CustomTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit
import Photos

extension TimeInfomation {
    static var testTimerInfomations: [TimeInfomation] = [TimeInfomation(time: 10, photo: nil, text: "テストa"),
                                                         TimeInfomation(time: 9, photo: nil, text: "テストb"),
                                                         TimeInfomation(time: 8, photo: nil, text: "テストc"),
                                                         TimeInfomation(time: 7, photo: nil, text: "テストd"),
                                                         TimeInfomation(time: 6, photo: nil, text: "テストe"),
                                                         TimeInfomation(time: 5, photo: nil, text: "テストf"),
                                                         TimeInfomation(time: 4, photo: nil, text: "テストg"),
                                                         TimeInfomation(time: 3, photo: nil, text: "テストh"),
                                                         TimeInfomation(time: 2, photo: nil, text: "テストi"),
                                                         TimeInfomation(time: 1, photo: nil, text: "テストj"),
                                                         TimeInfomation(time: 0, photo: nil, text: "テストk")]
    static var testNoTimes: [TimeInfomation] = [TimeInfomation(time: 0)]
}

final class CustomTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var plusButton: UIButton!
    
    private var timerInfomations: [TimeInfomation] = TimeInfomation.testTimerInfomations
    private var selectedIndexPath: IndexPath = [0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layer.cornerRadius = 20
        plusButton.layer.cornerRadius = plusButton.layer.frame.height / 2
    }
    
    @IBAction private func saveTimerButtonTapped(_ sender: Any) {
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusButtonDidTapped(_ sender: Any) {
        
        DispatchQueue.main.async {
            self.deselectCell()
            DispatchQueue.main.async {
                self.insertCell()
            }
        }
        
    }
    
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        getPhotosAuthorization()
    }
    
    // MARK: - Authorization
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
    
    private func showPhotosAuthorizationDeniedAlert() {
        let alert = UIAlertController(title: "写真へのアクセスを許可しますか？",
                                      message: nil,
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定画面へ",
                                           style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL,
                                      options: [:],
                                      completionHandler: nil)
        }
        let closeAction = UIAlertAction(title: "キャンセル",
                                        style: .cancel,
                                        handler: nil)
        [settingsAction, closeAction]
            .forEach { alert.addAction($0) }
        present(alert,
                animated: true,
                completion: nil)
    }
    
    private func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController,
                animated: true,
                completion: nil)
    }
    
    private func deselectCell() {
        selectedIndexPath = []
        collectionView.reloadData()
    }
    
    private func insertCell() {
        timerInfomations.append(TimeInfomation(time: 0))
        let insertIndexPath = IndexPath(item: timerInfomations.count - 1,
                                        section: 0)
        selectedIndexPath = insertIndexPath
        collectionView.insertItems(at: [insertIndexPath])
        self.collectionView.scrollToItem(at: insertIndexPath,
                                         at: .centeredHorizontally,
                                         animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension CustomTimerViewController: UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { dismiss(animated: true, completion: nil) }
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        timerInfomations[selectedIndexPath.item].photo = convertImageToData(image: selectedImage)
        collectionView.reloadItems(at: [selectedIndexPath])
    }
    
    private func convertImageToData(image: UIImage?) -> Data? {
        guard let image = image,
              let selectedImageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        return selectedImageData
    }
    
}

// MARK: - UICollectionViewDataSource
extension CustomTimerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        timerInfomations.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CustomTimerCollectionViewCell.identifier,
                for: indexPath) as? CustomTimerCollectionViewCell
        else { fatalError("セルが見つかりません") }
        if let imageData = timerInfomations[indexPath.item].photo,
           let image = UIImage(data: imageData) {
            cell.configure(image: image)
        } else {
            cell.configure(image: UIImage(systemName: "timer")!)
        }
        
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
        selectedIndexPath = indexPath
        collectionView.reloadData()
    }
    
}

// MARK: - setup
extension CustomTimerViewController {
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = CustomTimerCollectionViewFlowLayout()
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTimerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: CustomTimerCollectionViewCell.identifier)
    }

}
