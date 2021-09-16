//
//  CustomTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

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
    @IBOutlet weak var plusButton: UIButton!
    
    private var timerInfomations: [TimeInfomation] = TimeInfomation.testNoTimes
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
        insertCell()
    }
    
    private func insertCell() {
        timerInfomations.append(TimeInfomation(time: 0))
        let insertIndexPath = IndexPath(item: timerInfomations.count - 1,
                                        section: 0)
        collectionView.insertItems(at: [insertIndexPath])
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: insertIndexPath,
                                             at: .right,
                                             animated: true)
        }
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = CustomTimerCollectionViewFlowLayout()
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTimerCollectionViewCell.nib,
                                forCellWithReuseIdentifier: CustomTimerCollectionViewCell.identifier)
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
        cell.configure(image: UIImage(systemName: "timer")!)
        indexPath == selectedIndexPath
            ? cell.selectedCell()
            : cell.unselectedCell()
        return cell
    }
    
}
