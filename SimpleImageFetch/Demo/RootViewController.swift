//
//  RootViewController.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

final class RootViewController: UIViewController {
    private var cache = [DisplayType: UIViewController]()
    private var segments: [DisplayType] = [.tableView, .collectionView]
    private lazy var segmentControl: UISegmentedControl = UISegmentedControl(items: segments.map(\.title))

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentControl.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)
        navigationItem.titleView = segmentControl
    }

    @objc private func segmentChanged(sender: UISegmentedControl) {
        let displayType = segments[sender.selectedSegmentIndex]
        setDisplayType(displayType)
    }

    private func setDisplayType(_ type: DisplayType) {
        let new: UIViewController

        if let cached = cache[type] {
            new = cached
        } else {
            switch type {
            case .collectionView:
                new =  CollectionViewController()
            case .tableView:
                new = TableViewController()
            }

            cache[type] = new
        }

        if let old = children.first {
            add(viewController: new)
            remove(viewController: old)
        } else {
            add(viewController: new)
        }
    }

    private func add(viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    private func remove(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

}

private enum DisplayType {
    case tableView
    case collectionView

    var title: String {
        switch self {
        case .collectionView:
            return "CollectionView"
        case .tableView:
            return "TableView"
        }
    }
}
