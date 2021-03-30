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
        addPulsingAnimation()

        ImageFetcher.shared.fetchImage(url: url) { [weak self] imageResponse in
            assert(Thread.isMainThread)
            guard let self = self, self.url == imageResponse.url else { return }
            
            self.removePulsingAnimation()

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

    private func addPulsingAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = 0.3
        animation.toValue = 1
        animation.autoreverses = true
        animation.repeatCount = .infinity

        layer.add(animation, forKey: "pulseAnimation")
    }

    private func removePulsingAnimation() {
        layer.removeAnimation(forKey: "pulseAnimation")
    }
}
