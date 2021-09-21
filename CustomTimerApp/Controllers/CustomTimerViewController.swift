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
    private let TimeStructures: [TimeStructure] = [Hour(), Minute(), Second()]
    private var unitlabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupPickerView()
        
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
        timerInfomations[selectedIndexPath.item].photo = selectedImage.convertImageToData()
        collectionView.reloadItems(at: [selectedIndexPath])
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
    
}
