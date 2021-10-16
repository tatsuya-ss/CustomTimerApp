//
//  CustomTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit
import Photos

extension CustomTimerViewController: ShowAlertProtocol{ }

protocol CustomTimerViewControllerDelegate: AnyObject {
    func didTapSaveButton(_ customTimerViewController: CustomTimerViewController,
                          customTimerComponent: CustomTimerComponent)
}

final class CustomTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var plusButton: UIButton!
    
    private var customTimerComponent = CustomTimerComponent(
        name: "タイマー１",
        timeInfomations: [TimeInfomation(time: Time(hour: 0, minute: 0, second: 0))]
    )
    private var deselectedIndexPath: IndexPath = []
    private var selectedIndexPath: IndexPath = [0, 0]
    private let TimeStructures: [TimePickerViewStructure] = [Hour(), Minute(), Second()]
    private var unitlabels: [UILabel] = []
    weak var delegate: CustomTimerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupPickerView()
        setupTextField()
        setupModelInPresentation()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        plusButton.layer.cornerRadius = plusButton.layer.frame.height / 2
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
    
    private func showDiscardChangesAlert() {
        showTwoChoicesAlert(alertTitle: "画面を閉じると編集中のタイマーは破棄されます。よろしいですか？",
                            cancelMessage: "キャンセル",
                            destructiveTitle: "破棄する",
                            handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func plusButtonDidTapped(_ sender: Any) {
        insertCell()
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
    
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        getPhotosAuthorization()
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
              let image = UIImage(data: imageData) else { return UIImage(systemName: "timer") }
        return image
    }
    
    
}

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
        selectedIndexPath = indexPath
        collectionView.reloadData()
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
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = CustomTimerCollectionViewFlowLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
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
        let fontSize = CGFloat(15)
        let labelTop = timePickerView.bounds.origin.y + timePickerView.bounds.height / 2 - fontSize
        let labelHeight = timePickerView.rowSize(forComponent: 0).height
        var labelOffset = timePickerView.bounds.origin.x
        // 変更
        TimeStructures.forEach {
            let row = $0.row
            if self.unitlabels.count == row {
                let label = UILabel()
                label.backgroundColor = .systemBlue
                label.text = $0.unit
                label.font = UIFont.boldSystemFont(ofSize: fontSize)
                label.sizeToFit()
                
                timePickerView.addSubview(label)
                self.unitlabels.append(label)
            }
            let labelWidth = self.unitlabels[row].frame.width
            labelOffset += timePickerView.rowSize(forComponent: row).width
            print(labelWidth, labelOffset)
            self.unitlabels[row].frame = CGRect(x: labelOffset - labelWidth,
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
    
}
