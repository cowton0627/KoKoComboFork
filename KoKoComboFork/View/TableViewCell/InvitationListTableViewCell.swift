//
//  InvitationListTableViewCell.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/21.
//

import UIKit

class InvitationListTableViewCell: UITableViewCell {

    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?

    @IBOutlet weak var avatatImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCellStyle()
    }

    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        onAccept?()
    }

    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        onReject?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onAccept = nil
        onReject = nil
    }

    func configue(with friend: Friend) {
        nameLabel.text = friend.name
        nameLabel.accessibilityLabel = "\(friend.name)，邀請你成為好友"
        acceptButton.accessibilityLabel = "接受 \(friend.name) 的好友邀請"
        rejectButton.accessibilityLabel = "拒絕 \(friend.name) 的好友邀請"
        acceptButton.accessibilityIdentifier = "invitation.accept.\(friend.fid)"
        rejectButton.accessibilityIdentifier = "invitation.reject.\(friend.fid)"
        accessibilityIdentifier = "invitation.cell.\(friend.fid)"
    }
    
    private func setupCellStyle() {
        isAccessibilityElement = false
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false

    }

}
