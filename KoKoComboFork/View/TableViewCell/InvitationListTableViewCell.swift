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
        setupCellStyle()
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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

    }
    
    private func setupCellStyle() {
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
    }

}

extension UIView {
    
//    func roundCorners(view: UIView, corners: UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: view.bounds,
//                                byRoundingCorners: corners,
//                                cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        view.layer.mask = mask
//    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


