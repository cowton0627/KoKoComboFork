//
//  InvitationCellView.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/19.
//

//import UIKit
//
//class InvitationCellView: UIView {
//    
//    private let hintText = "邀請你成為好友 : )"
//    
//    private let avatarImageView = UIImageView()
//    private let nameLabel = UILabel()
//    private let hintLabel = UILabel()
//    private let acceptButton = UIButton()
//    private let rejectButton = UIButton()
//
//    var onAccept: (() -> Void)?
//    var onReject: (() -> Void)?
//
//    init(friend: Friend, 
//         avatar: UIImage?,
//         acceptImage: UIImage?, 
//         rejectImage: UIImage?) {
//        super.init(frame: .zero)
//        
//        setupSubviews(friend: friend, 
//                      avatar: avatar,
//                      acceptImage: acceptImage,
//                      rejectImage: rejectImage)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupSubviews(friend: Friend, 
//                               avatar: UIImage?,
//                               acceptImage: UIImage?,
//                               rejectImage: UIImage?) {
//        // Configure avatar
//        avatarImageView.image = avatar
//        avatarImageView.contentMode = .scaleAspectFit
//        avatarImageView.layer.cornerRadius = 30
//        avatarImageView.clipsToBounds = true
//
//        // Configure name label
//        nameLabel.text = friend.name
//        nameLabel.font = .boldSystemFont(ofSize: 16)
//
//        // Configure hint label
//        hintLabel.text = hintText
//        hintLabel.font = .systemFont(ofSize: 14)
//        hintLabel.textColor = .gray
//
//        // Configure buttons
//        acceptButton.setImage(acceptImage, for: .normal)
//        rejectButton.setImage(rejectImage, for: .normal)
//
//        let vStack = UIStackView(arrangedSubviews: [nameLabel, hintLabel])
//        vStack.axis = .vertical
//        vStack.spacing = 5
//
//        let hStack = UIStackView(
//            arrangedSubviews: [avatarImageView, 
//                               vStack,
//                               acceptButton,
//                               rejectButton]
//        )
//        hStack.axis = .horizontal
//        hStack.alignment = .center
//        hStack.spacing = 10
//
//        addSubview(hStack)
//
//        hStack.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            hStack.topAnchor.constraint(equalTo: self.topAnchor, 
//                                        constant: 10),
//            hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor,
//                                            constant: 10),
//            hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor,
//                                             constant: -10),
//            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor,
//                                           constant: -10),
//            
//            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
//            avatarImageView.heightAnchor.constraint(equalToConstant: 60)
//        ])
//    }
//    
//    @objc private func acceptTapped() {
//        onAccept?()
//    }
//
//    @objc private func rejectTapped() {
//        onReject?()
//    }
//}
