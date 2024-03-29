//
//  FirstViewController.swift
//  CutomNavigationTransiotion
//
//  Created by Faiz Ul Hassan on 6/25/22.
//

import UIKit

class FirstViewController: UIViewController {

    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var panGestureRecognizer: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
    }

    func addGesture() {

        guard navigationController?.viewControllers.count ?? 0 > 1 else {
            return
        }

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {

        let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width

        switch panGesture.state {

        case .began:
            navigationController?.delegate = self
            _ = navigationController?.popViewController(animated: true)

        case .changed:
            if let percentDrivenInteractiveTransition = percentDrivenInteractiveTransition {
                percentDrivenInteractiveTransition.update(percent)
            }

        case .ended:
            let velocity = panGesture.velocity(in: view).x

            // Continue if drag more than 50% of screen width or velocity is higher than 1000
            if percent > 0.5 || velocity > 1000 {
                percentDrivenInteractiveTransition.finish()
            } else {
                percentDrivenInteractiveTransition.cancel()
            }

        case .cancelled, .failed:
            percentDrivenInteractiveTransition.cancel()

        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension FirstViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return SlideAnimatedTransitioning()
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        navigationController.delegate = nil

        if panGestureRecognizer.state == .began {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition.completionCurve = .easeOut
        } else {
            percentDrivenInteractiveTransition = nil
        }

        return percentDrivenInteractiveTransition
    }
}
