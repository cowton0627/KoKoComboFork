//
//  InvitationListTableViewCell.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/21.
//

import UIKit

class InvitationListTableViewCell: UITableViewCell {
    
//    private let hintText = "邀請你成為好友 : )"
//    private let shadowOffset: CGSize = CGSize(width: 0, height: 2)
//    private let invitationStackView = UIStackView()
    
//    var onAccept: ((Int) -> Void)?
//    var onReject: ((Int) -> Void)?
    
    @IBOutlet weak var avatatImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
//    override init(style: UITableViewCell.CellStyle, 
//                  reuseIdentifier: String?) {
//        super.init(style: style, 
//                   reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        print("acceptButtonTapped")
    }
    
    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        print("rejectButtonTapped")
    }
    
    func configue(with viewModel: UserViewModel, at index: Int) {
        let friend = viewModel.itemAt(index)
        nameLabel.text = friend.name
        
//        textLabel?.text = friend.name
//        detailTextLabel?.text = friend.status == 0 ? "邀請送出" : (friend.status == 1 ? "已完成" : "邀請中")
    }
    

//    private func setupCell() {
//        contentView.addSubview(invitationStackView)
//        invitationStackView.axis = .vertical
//        invitationStackView.spacing = 10
//        invitationStackView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            invitationStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            invitationStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            invitationStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            invitationStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
//        ])
//    }

//    func configure(with friends: [Friend],
//                   avatar: UIImage?,
//                   acceptImage: UIImage?,
//                   rejectImage: UIImage?) {
//        
//        invitationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        for friend in friends {
//            let cell = createInvitationCell(friend: friend,
//                                            avatar: avatar,
//                                            acceptImage: acceptImage,
//                                            rejectImage: rejectImage)
//            invitationStackView.addArrangedSubview(cell)
//        }
//    }
    
//    private func createInvitationCell(friend: Friend,
//                                      avatar: UIImage?,
//                                      acceptImage: UIImage?,
//                                      rejectImage: UIImage?) -> UIView {
//        let cell = UIView()
//        cell.backgroundColor = .white
//        cell.layer.cornerRadius = 8
//        cell.layer.shadowColor = UIColor.gray.cgColor
//        cell.layer.shadowOpacity = 0.2
//        cell.layer.shadowRadius = 4
//        cell.layer.shadowOffset = shadowOffset
//        cell.translatesAutoresizingMaskIntoConstraints = false
//        cell.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        
//        let avatarImageView = UIImageView(image: avatar)
//        avatarImageView.contentMode = .scaleAspectFit
//        avatarImageView.layer.cornerRadius = 30
//        avatarImageView.clipsToBounds = true
//        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
//
//        let nameLabel = UILabel()
//        nameLabel.text = friend.name
//        nameLabel.font = .boldSystemFont(ofSize: 16)
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        let hintLabel = UILabel()
//        hintLabel.text = hintText
//        hintLabel.font = .systemFont(ofSize: 14)
//        hintLabel.textColor = .gray
//        hintLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        let acceptButton = UIButton(type: .system)
//        acceptButton.setImage(acceptImage, for: .normal)
//        acceptButton.backgroundColor = .white
//        acceptButton.tintColor = UIColor.systemGreen
//        acceptButton.layer.cornerRadius = 20
//        acceptButton.tag = Int(friend.fid) ?? 0
//        acceptButton.addTarget(self,
//                               action: #selector(acceptTapped),
//                               for: .touchUpInside)
//        acceptButton.translatesAutoresizingMaskIntoConstraints = false
//
//        let rejectButton = UIButton(type: .system)
//        rejectButton.setImage(rejectImage, for: .normal)
//        rejectButton.backgroundColor = .white
//        rejectButton.tintColor = UIColor.systemRed
//        rejectButton.layer.cornerRadius = 20
//        rejectButton.tag = Int(friend.fid) ?? 0
//        rejectButton.addTarget(self,
//                               action: #selector(rejectTapped),
//                               for: .touchUpInside)
//        rejectButton.translatesAutoresizingMaskIntoConstraints = false
//
//        let vStack = UIStackView(arrangedSubviews: [nameLabel, hintLabel])
//        vStack.axis = .vertical
//        vStack.spacing = 5
//        vStack.translatesAutoresizingMaskIntoConstraints = false
//
//        let hStack = UIStackView(arrangedSubviews: [avatarImageView, vStack, acceptButton, rejectButton])
//        hStack.axis = .horizontal
//        hStack.alignment = .center
//        hStack.spacing = 10
//        hStack.translatesAutoresizingMaskIntoConstraints = false
//
//        cell.addSubview(hStack)
//
//        NSLayoutConstraint.activate([
//            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
//            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
//
//            acceptButton.widthAnchor.constraint(equalToConstant: 40),
//            acceptButton.heightAnchor.constraint(equalToConstant: 40),
//
//            rejectButton.widthAnchor.constraint(equalToConstant: 40),
//            rejectButton.heightAnchor.constraint(equalToConstant: 40),
//
//            hStack.topAnchor.constraint(
//                equalTo: cell.topAnchor, constant: 10),
//            hStack.leadingAnchor.constraint(
//                equalTo: cell.leadingAnchor, constant: 10),
//            hStack.trailingAnchor.constraint(
//                equalTo: cell.trailingAnchor, constant: -10),
//            hStack.bottomAnchor.constraint(
//                equalTo: cell.bottomAnchor, constant: -10),
//        ])
//
//        return cell
//    }

//    @objc private func acceptTapped(_ sender: UIButton) {
//        onAccept?(sender.tag)
//        print("Accepted invitation for friend id: \(sender.tag)")
//    }

//    @objc private func rejectTapped(_ sender: UIButton) {
//        onReject?(sender.tag)
//        print("Rejected invitation for friend id: \(sender.tag)")
//    }
}
