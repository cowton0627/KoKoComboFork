//
//  FriendsTableViewCell.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/18.
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
    
    func configure(with viewModel: FriendsViewModel, at index: Int) {
        let item = viewModel.itemAt(index)
        
        
        switch item.isTop {
        case "0":
            isTopImgView.image = UIImage()
        case "1":
            isTopImgView.image = icFriendsStar
        default:
            isTopImgView.image = UIImage()
        }
        
        avatarImgView.image = imgFriendsList
        nameLabel.text = item.name
        
        let doneBool: Bool?
        switch item.status {
        case 0:
            doneBool = false
        case 1:
            doneBool = true
        case 2:
            doneBool = false
        default:
            doneBool = false
        }
        
        if let doneBool = doneBool {
            invitingButton.isHidden = !doneBool
            detailButton.isHidden = doneBool
        }

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
