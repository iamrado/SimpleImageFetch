//
//  ViewController.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

class ViewController: UITableViewController {
    private var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: PhotoTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        load()
    }

    private func load() {
        APIClient.fetchPhotos(completion: { [weak self] photos in
            self?.photos = photos
            self?.tableView.reloadData()
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
}

