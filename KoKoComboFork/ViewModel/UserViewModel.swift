//
//  UserViewModel.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/19.
//

import Foundation

struct FriendsOverviewState {
    let headerHeight: Double
    let invitationListHeight: Double
    let isSegmentedControlHidden: Bool
}

class UserViewModel {
    
    private let userService: UserServicing
    private let hasInvitations: Bool
    private var isInvitationListExpanded = false
    
    private let expandedInvitationListHeight = 140.0
    private let collapsedInvitationListHeight = 70.0
    private let baseHeaderHeight = 120.0

    // Output
    @Boxed var userData: UserData?
    @Boxed var state = FriendsOverviewState(
        headerHeight: 120.0,
        invitationListHeight: 0.0,
        isSegmentedControlHidden: false
    )
//    @Boxed var userName: String = ""
//    @Boxed var kokoID: String = ""
//    @Boxed var isInvitationViewHidden: Bool = true
    var friendsList: [Friend] = []
    
    // Input
    private var selectedSegmentIndex: Int = 0
    
    init(scenario: Int?,
         userService: UserServicing = UserService.shared) {
        self.userService = userService
        self.hasInvitations = scenario == 3
//        self.isInvitationViewHidden = scenario != 3
        updateStateForIdleMode()
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
                let resp = try await userService.getUserData()
                print(resp)

                if let userResp = resp.response?.first {
//                    userName = userResp.name
//                    kokoID = "KOKO ID：\(userResp.kokoid) 〉"
                    
                    userData = UserData(name: userResp.name, kokoid: "KOKO ID：\(userResp.kokoid) 〉")
                }
                
            } catch (let error) {
                print(error)
            }
        }
    }
    
    private func fetchFriendsData() {
        // static data
        friendsList = [
            Friend(name: "彭安亭", status: 1, isTop: "0", fid: "001", updateDate: "1983/06/27"),
            Friend(name: "施君凌", status: 1, isTop: "0", fid: "002", updateDate: "1983/06/27")
        ]
    }
    
    func numberOfItems() -> Int {
        return friendsList.count
    }
    
    func itemAt(_ index: Int) -> Friend {
        return friendsList[index]
    }
    
    func toggleInvitationList() {
        guard hasInvitations else { return }
        isInvitationListExpanded.toggle()
        updateStateForIdleMode()
    }
    
    func startSearching() {
        state = FriendsOverviewState(
            headerHeight: 0.0,
            invitationListHeight: 0.0,
            isSegmentedControlHidden: true
        )
    }
    
    func endSearching() {
        updateStateForIdleMode()
    }
    
    private func updateStateForIdleMode() {
        let invitationHeight = hasInvitations
            ? (isInvitationListExpanded ? collapsedInvitationListHeight : expandedInvitationListHeight)
            : 0.0
        
        state = FriendsOverviewState(
            headerHeight: baseHeaderHeight + invitationHeight,
            invitationListHeight: invitationHeight,
            isSegmentedControlHidden: false
        )
    }

}
