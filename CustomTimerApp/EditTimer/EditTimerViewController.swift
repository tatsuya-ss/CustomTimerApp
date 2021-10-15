//
//  EditTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/15.
//

import UIKit

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

    @IBAction private func saveButtonDidTapped(_ sender: Any) {
        
    }
    
    @IBAction private func cancelButtonDidTapped(_ sender: Any) {
        showDiscardChangesAlert()
    }
    
    @IBAction private func plusButtonDidTapped(_ sender: Any) {
        
    }
    
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        
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

extension EditTimerViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDiscardChangesAlert()
    }
}

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

extension EditTimerViewController: UICollectionViewDelegate {
    
}

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
        timerNameTextField.text = customTimerComponent.name
    }

}
