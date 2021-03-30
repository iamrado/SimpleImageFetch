//
//  ViewController.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

class TableViewController: UITableViewController {
    private let clearCacheButton = UIButton(type: .system)
    private var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        clearCacheButton.tintColor = .systemRed
        clearCacheButton.setTitle("Clear Cache", for: .normal)
        clearCacheButton.addTarget(self, action: #selector(clearCacheTapped), for: .touchUpInside)
        clearCacheButton.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
        clearCacheButton.layer.borderColor = UIColor.systemRed.cgColor
        clearCacheButton.layer.cornerRadius = 8
        clearCacheButton.layer.borderWidth = 1

        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: PhotoTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 300

        load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func load() {
        APIClient.fetchPhotos(completion: { [weak self] photos in
            self?.photos = photos
            self?.tableView.reloadData()
            self?.tableView.tableFooterView = photos.isEmpty ? UIView() : self?.clearCacheButton
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.identifier) as? PhotoTableViewCell else {
            fatalError("Check the implementation: could not dequeue cell for identifier: cellId!")
        }

        let photo = photos[indexPath.row]
        cell.authorLabel.text = photo.author
        cell.photoView.setImage(withURL: photo.downloadUrl)

        return cell
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let footer = tableView.tableFooterView else { return }
        footer.frame = CGRect(x: 0, y: footer.frame.origin.y, width: tableView.frame.width, height: 44).insetBy(dx: 24, dy: 0)
    }

    @objc private func clearCacheTapped() {
        ImageFetcher.shared.clearCache()
    }
}

