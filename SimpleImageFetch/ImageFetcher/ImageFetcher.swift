//
//  ImageFetcher.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

final class ImageFetcher {
    private let maxConcurrentTasks = 4
    private let session: URLSession
    private let cache = Cache<URL, UIImage>()
    private let queue = DispatchQueue(label: "com.iamrado.image-fetcher.queue")
    private var inProgressTasks = [URL: ImageLoadTask]()
    private var readyTasks = [URL: ImageLoadTask]()

    static let shared = ImageFetcher()

    init() {
        assert(Thread.isMainThread)
        session = URLSession(configuration: .default)
    }

    func fetchImage(url: URL, completion: @escaping ((ImageResponse) -> Void)) {
        assert(Thread.isMainThread)

        if let cachedImage = cache.object(forKey: url) {
            completion(.init(url: url, image: cachedImage, isFromCache: true))
            return
        }

        queue.async {
            self._fetchImage(url: url, completion: { completion(.init(url: $0, image: $1, isFromCache: false)) })
        }
    }

    func cancel(url: URL) {
        queue.async { self._cancel(url: url) }
    }

    func clearCache() {
        cache.removeAllObjects()
    }

    private func didFinish(taskForURL url: URL, error: Error?) {
        queue.async { self._didFinish(taskForURL: url, error: error) }
    }

    private func _cancel(url: URL) {
        if let task = inProgressTasks.removeValue(forKey: url) {
            task.dataTask?.cancel()
        }

        if let task = readyTasks.removeValue(forKey: url) {
            task.dataTask?.cancel()
        }
    }

    private func _fetchImage(url: URL, completion: @escaping ((URL, UIImage?) -> Void)) {
        let imageTask: ImageLoadTask

        if let waitingTask = readyTasks[url] {
            imageTask = waitingTask
            imageTask.requestedTime = .now()
        } else {
            imageTask = ImageLoadTask(url,
                                      session: session,
                                      onFinished: { [weak self] in self?.didFinish(taskForURL: url, error: $0) },
                                      onCompleted: completion)
        }

        if inProgressTasks.count < maxConcurrentTasks {
            fetchTask(imageTask)
        } else {
            readyTasks[url] = imageTask
        }
    }

    private func _didFinish(taskForURL url: URL, error: Error?) {
        guard let task = inProgressTasks.removeValue(forKey: url) else {
            return
        }

        assert(inProgressTasks.count < maxConcurrentTasks)

        if let task = readyTasks.values.randomElement() {
            readyTasks.removeValue(forKey: task.url)
            fetchTask(task)
        }

        if let image = task.image {
            cache.set(image, forKey: url)
        }

        DispatchQueue.main.async {
            task.onCompleted(url, task.image)
        }
    }

    private func fetchTask(_ imageTask: ImageLoadTask) {
        inProgressTasks[imageTask.url] = imageTask
        imageTask.dataTask?.resume()
    }
}

struct ImageResponse {
    let url: URL
    let image: UIImage?
    let isFromCache: Bool
}

private final class Cache<KeyType: Hashable, ObjectType: AnyObject> {
    private let storage = NSCache<Key, ObjectType>()

    func object(forKey key: KeyType) -> ObjectType? {
        storage.object(forKey: Key(key))
    }

    func set(_ obj: ObjectType, forKey key: KeyType) {
        storage.setObject(obj, forKey: Key(key))
    }

    func removeObject(forKey key: KeyType) {
        storage.removeObject(forKey: Key(key))
    }

    func removeAllObjects() {
        storage.removeAllObjects()
    }

    private final class Key: NSObject {
        let key: KeyType

        init(_ key: KeyType) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let obj = object as? Self else { return false }
            return obj.key == key
        }
    }
}

private final class ImageLoadTask {
    let url: URL
    var requestedTime: DispatchTime
    var onCompleted: ((URL, UIImage?) -> Void)
    var size = CGSize(width: 300, height: 300)
    private(set) var dataTask: URLSessionDataTask?
    private(set) var image: UIImage?

    init(_ url: URL, session: URLSession, onFinished: @escaping ((Error?) -> Void), onCompleted: @escaping ((URL, UIImage?) -> Void)) {
        self.url = url
        self.requestedTime = .now()
        self.onCompleted = onCompleted
        self.dataTask = session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            assert(!Thread.isMainThread)

            guard let self = self else { return }
            self.image = data
                .flatMap { UIImage(data: $0, scale: UIScreen.main.scale) }
                .map { $0.scaled(to: self.size)}
            onFinished(error)
        })
    }
}

private extension UIImage {
    func scaled(to newSize: CGSize) -> UIImage {
        let widthRatio = newSize.width / size.width
        let heightRatio = newSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        return renderer.image { _ in
            self.draw(in: .init(origin: .zero, size: scaledImageSize))
        }
    }
}
