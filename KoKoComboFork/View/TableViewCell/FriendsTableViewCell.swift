//
//  FriendsTableViewCell.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/18.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    var onTransfer: (() -> Void)?
    var onDetail: (() -> Void)?
    
    private let icFriendsStar = UIImage(named: "icFriendsStar")
    private let imgFriendsList = UIImage(named: "imgFriendsList")
    
    @IBOutlet weak var isTopImgView: UIImageView!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var transferButton: CustomTransferButton!
    @IBOutlet weak var invitingButton: CustomInvitingButton!
    @IBOutlet weak var detailButton: UIButton!
    
    func configure(with viewModel: FriendCellViewModel) {
        isTopImgView.image = viewModel.isTop ? icFriendsStar : nil
        avatarImgView.image = imgFriendsList
        nameLabel.text = viewModel.name
        transferButton.isHidden = !viewModel.showsTransferButton
        invitingButton.isHidden = !viewModel.showsInvitingButton
        detailButton.isHidden = !viewModel.showsDetailButton
        accessibilityIdentifier = "friend.cell.\(viewModel.id)"
        nameLabel.accessibilityIdentifier = "friend.name.\(viewModel.id)"
        transferButton.accessibilityLabel = "轉帳給 \(viewModel.name)"
        invitingButton.accessibilityLabel = "\(viewModel.name)，邀請中"
        invitingButton.accessibilityTraits = .staticText
        detailButton.accessibilityLabel = "查看 \(viewModel.name) 的更多操作"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
        transferButton.titleLabel?.adjustsFontForContentSizeCategory = true
        invitingButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTransfer = nil
        onDetail = nil
    }
    
    @IBAction func transferButtonTapped(_ sender: CustomTransferButton) {
        onTransfer?()
    }
    
    @IBAction func invitingButtonTapped(_ sender: CustomInvitingButton) {
        // Status-only control in this portfolio demo.
    }
    
    @IBAction func detailButtonTapped(_ sender: UIButton) {
        onDetail?()
    }
    
    
    
}
