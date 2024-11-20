//
//  InvitationListView.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/19.
//

import UIKit

class InvitationListView: UIView {
    
    private let hintText = "邀請你成為好友 : )"
    private let shadowOffset: CGSize = CGSize(width: 0, height: 2)
    private let invitationStackView = UIStackView()
    
//    private let avatarImageView = UIImageView()
//    private let nameLabel = UILabel()
//    private let hintLabel = UILabel()
//    private let acceptButton = UIButton()
//    private let rejectButton = UIButton()

    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?

    init(friends: [Friend],
         avatar: UIImage?,
         acceptImage: UIImage?, 
         rejectImage: UIImage?) {
        super.init(frame: .zero)
        
        setupSubviews(friends: friends,
                      avatar: avatar,
                      acceptImage: acceptImage,
                      rejectImage: rejectImage)
//        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews(friends: [Friend],
                               avatar: UIImage?,
                               acceptImage: UIImage?,
                               rejectImage: UIImage?) {
        
        invitationStackView.axis = .vertical
        invitationStackView.spacing = 10
//        stackView.distribution = .fill
//        invitationStackView.alignment = .fill
        invitationStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(invitationStackView)
        
        setupConstraints()
        
        for friend in friends {
            let cell = createInvitationCell(friend: friend,
                                            avatar: avatar,
                                            acceptImage: acceptImage,
                                            rejectImage: rejectImage)
            invitationStackView.addArrangedSubview(cell)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            invitationStackView.topAnchor.constraint(
                equalTo: topAnchor, constant: 10),
            invitationStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 10),
            invitationStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -10),
            invitationStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    private func createInvitationCell(friend: Friend,
                                      avatar: UIImage?,
                                      acceptImage: UIImage?,
                                      rejectImage: UIImage?) -> UIView {
        let cell = UIView()
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 8
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = shadowOffset
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let avatarImageView = UIImageView(image: avatar)
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint =
        avatarImageView.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true

        let nameLabel = UILabel()
        nameLabel.text = friend.name
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let hintLabel = UILabel()
        hintLabel.text = hintText
        hintLabel.font = .systemFont(ofSize: 14)
        hintLabel.textColor = .gray
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let acceptButton = UIButton(type: .system)
        acceptButton.setImage(acceptImage, for: .normal)
        acceptButton.backgroundColor = .white
        acceptButton.tintColor = UIColor.mainPeach
        acceptButton.layer.cornerRadius = 20
        acceptButton.tag = Int(friend.fid) ?? 0
        acceptButton.addTarget(self, action: #selector(acceptTapped),
                               for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false

        let rejectButton = UIButton(type: .system)
        rejectButton.setImage(rejectImage, for: .normal)
        rejectButton.backgroundColor = .white
        rejectButton.tintColor = UIColor.systemGray5
        rejectButton.layer.cornerRadius = 20
        rejectButton.tag = Int(friend.fid) ?? 0
        rejectButton.addTarget(self, action: #selector(rejectTapped),
                               for: .touchUpInside)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false

        let vStack = UIStackView(arrangedSubviews: [nameLabel, hintLabel])
        vStack.axis = .vertical
        vStack.spacing = 5
//        vStack.alignment = .leading
        vStack.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView(arrangedSubviews: [avatarImageView, vStack, acceptButton, rejectButton])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(hStack)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            heightConstraint,

            acceptButton.widthAnchor.constraint(equalToConstant: 40),
            acceptButton.heightAnchor.constraint(equalToConstant: 40),

            rejectButton.widthAnchor.constraint(equalToConstant: 40),
            rejectButton.heightAnchor.constraint(equalToConstant: 40),
            
            hStack.topAnchor.constraint(
                equalTo: cell.topAnchor, constant: 10),
            hStack.leadingAnchor.constraint(
                equalTo: cell.leadingAnchor, constant: 10),
            hStack.trailingAnchor.constraint(
                equalTo: cell.trailingAnchor, constant: -10),
            hStack.bottomAnchor.constraint(
                equalTo: cell.bottomAnchor, constant: -10),
        ])
        
        cell.backgroundColor = .systemGray6

        return cell
        
    }
    
    @objc private func acceptTapped() {
        onAccept?()
        print("acceptTapped")
    }

    @objc private func rejectTapped() {
        onReject?()
        print("rejectTapped")
    }
}
