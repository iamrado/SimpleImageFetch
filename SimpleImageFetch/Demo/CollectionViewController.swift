//
//  CollectionViewController.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

final class CollectionViewController: UICollectionViewController {
    private let layout = UICollectionViewFlowLayout()
    private var photos = [Photo]()

    init() {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = layout
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)

        load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    private func load() {
        APIClient.fetchPhotos(limit: 300, completion: { [weak self] photos in
            self?.photos = photos
            self?.collectionView.reloadData()
        })
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotoCollectionViewCell {
            let item = photos[indexPath.row]
            cell.imageView.setImage(withURL: item.downloadUrl)
        }
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        let itemsPerLine: CGFloat = 3
        let interItemSpacing: CGFloat = 1
        let width = (view.frame.width - (interItemSpacing * (itemsPerLine - 1))) / itemsPerLine
        layout.minimumLineSpacing = interItemSpacing
        layout.minimumInteritemSpacing = interItemSpacing
        layout.itemSize = .init(width: width, height: width)
        layout.sectionInset = .init(top: interItemSpacing, left: 0, bottom: interItemSpacing, right: 0)
    }
}
