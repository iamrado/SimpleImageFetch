//
//  UIImageView+ImageFetcher.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

extension UIImageView {
    private struct AssociatedKeys {
        static var url: UInt8 = 0
    }

    private var url: URL? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.url) as? URL }
        set { objc_setAssociatedObject(self, &AssociatedKeys.url, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setImage(withURL url: URL) {
        assert(Thread.isMainThread)

        guard self.url != url else { return }

        if let currentUrl = self.url, currentUrl != url {
            ImageFetcher.shared.cancel(url: currentUrl)
        }

        self.url = url
        self.image = nil

        ImageFetcher.shared.fetchImage(url: url) { [weak self] imageResponse in
            assert(Thread.isMainThread)
            guard let self = self, self.url == imageResponse.url else { return }
            
            if !imageResponse.isFromCache {
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = 0.2
                animation.fromValue = 0
                animation.toValue = 1
                self.layer.add(animation, forKey: "imageTransition")
            }
            self.image = imageResponse.image
        }
    }
}
