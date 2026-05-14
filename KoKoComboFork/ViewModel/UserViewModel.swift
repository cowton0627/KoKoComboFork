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
    private var hasInvitations: Bool = false
    private var isInvitationListExpanded = true

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

    init(userService: UserServicing = UserService.shared) {
        self.userService = userService
        updateStateForIdleMode()
        retrieveUserData()
    }

    private func retrieveUserData() {
        Task {
            do {
                let resp = try await userService.getUserData()
                print(resp)

                if let userResp = resp.response?.first {
                    userData = UserData(name: userResp.name, kokoid: "KOKO ID：\(userResp.kokoid) 〉")
                }

            } catch (let error) {
                print(error)
            }
        }
    }

    func setHasInvitations(_ value: Bool) {
        guard hasInvitations != value else { return }
        hasInvitations = value
        if !value {
            isInvitationListExpanded = true // 重置, 下次有邀請時恢復展開
        }
        updateStateForIdleMode()
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
            ? (isInvitationListExpanded ? expandedInvitationListHeight : collapsedInvitationListHeight)
            : 0.0

        state = FriendsOverviewState(
            headerHeight: baseHeaderHeight + invitationHeight,
            invitationListHeight: invitationHeight,
            isSegmentedControlHidden: false
        )
    }

}
