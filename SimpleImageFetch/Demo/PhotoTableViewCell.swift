//
//  PhotoTableViewCell.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import UIKit

final class PhotoTableViewCell: UITableViewCell {
    static let identifier = "PhotoTableViewCellId"
    
    let photoView = UIImageView()
    let authorLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true

        authorLabel.font = UIFont.boldSystemFont(ofSize: 14)
        authorLabel.textAlignment = .center

        photoView.backgroundColor = .secondarySystemBackground
        authorLabel.backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        let inset = contentView.frame.width / 4
        separatorInset = .init(top: 0, left: inset, bottom: 0, right: inset)
        selectionStyle = .none

        let arrangedSubviews = [photoView, authorLabel]
        arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        let constraints = [stack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                           stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                           stack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                           stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

                           photoView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                           photoView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5)]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
