//
//  UserViewModel.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/19.
//

import Foundation


class UserViewModel {

    // Output
    @Boxed var userName: String = ""
    @Boxed var kokoID: String = ""
    @Boxed var isInvitationViewHidden: Bool = true
    private var friendsList: [Friend] = []
    
    // Input
    private var selectedSegmentIndex: Int = 0
    
    init(scenario: Int?) {
        self.isInvitationViewHidden = scenario != 3
        retrieveUserData()
        fetchFriendsData()
    }
    
//    private func retrieveUserData() {
//        Task {
//            do {
//                let resp = try await UserService.shared.getUserData()
//                print(resp)
//                if let userResp = resp.response?.first {
//                    userNameLabel.text = userResp.name
//                    kokoIDLabel.text = "KOKO ID：\(userResp.kokoid) 〉"
//                    remindImgView.isHidden = true
//                }
//            } catch (let error) {
//                print(error)
//            }
//        }
//    }
    
    private func retrieveUserData() {
        Task {
            do {
                let resp = try await UserService.shared.getUserData()
                print(resp)

                if let userResp = resp.response?.first {
                    userName = userResp.name
                    kokoID = "KOKO ID：\(userResp.kokoid) 〉"
                }
                
            } catch (let error) {
                print(error)
            }
        }
    }
    
    private func fetchFriendsData() {
        // static data
        friendsList = [
            Friend(name: "彭安亭", status: 1, isTop: "0", 
                   fid: "001", updateDate: "1983/06/27"),
            Friend(name: "施君凌", status: 1, isTop: "0", 
                   fid: "002", updateDate: "1983/06/27")
        ]
    }

}
