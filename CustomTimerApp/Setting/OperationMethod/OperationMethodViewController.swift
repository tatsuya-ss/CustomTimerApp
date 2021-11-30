//
//  OperationMethodViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/30.
//

import UIKit

final class OperationMethodViewController: UIPageViewController {
    
    private var controllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
}

// MARK: - UIPageViewControllerDelegate
extension OperationMethodViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        controllers.count
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),
           index > 0 {
            return controllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),
           index < controllers.count - 1 {
            return controllers[index + 1]
        }
        return nil
    }
    
}

// MARK: - func
extension OperationMethodViewController {
    
    private func setupPageViewController() {
        controllers = makeViewControllers()
        self.dataSource = self
        setViewControllers([controllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    private func makeViewControllers() -> [UIViewController] {
        let customTimerOperationVC = CustomTimerOperationViewController.instantiate()
        let startTimerOperationVC = StartTimerOperationViewController.instantiate()
        let countDownOperationVC = CountDownOperationViewController.instantiate()
        let notificationOperationVC = NotificationOperationViewController.instantiate()
        let viewControllers =  [customTimerOperationVC,
                                startTimerOperationVC,
                                countDownOperationVC,
                                notificationOperationVC]
        
        return viewControllers
    }
    
}

// MARK: - instantiate
extension OperationMethodViewController {
    
    static func instantiate() -> OperationMethodViewController {
        guard let operationMethodVC = UIStoryboard(name: "OperationMethod", bundle: nil).instantiateViewController(withIdentifier: String(describing: OperationMethodViewController.self)) as? OperationMethodViewController else { fatalError("OperationMethodViewControllerが見つかりません。") }
        return operationMethodVC
    }
    
}
