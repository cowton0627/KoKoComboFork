//
//  FriendsTableViewCell.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/18.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
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
        invitingButton.isHidden = !viewModel.showsInvitingButton
        detailButton.isHidden = !viewModel.showsDetailButton
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    
    @IBAction func transferButtonTapped(_ sender: CustomTransferButton) {
        print("transferButtonTapped")
    }
    
    @IBAction func invitingButtonTapped(_ sender: CustomInvitingButton) {
        print("invitingButtonTapped")
    }
    
    @IBAction func detailButtonTapped(_ sender: UIButton) {
        print("detailButtonTapped")
    }
    
    
    
}
