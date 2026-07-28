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
    let invitationCount: Int
    let remainingInvitationCount: Int
    let isInvitationListExpanded: Bool
    let isInvitationToggleHidden: Bool
}

@MainActor
final class UserViewModel {

    private let userService: UserServicing
    private var invitationCount = 0
    private var isInvitationListExpanded = true

    private let invitationRowHeight = 70.0
    private let maximumVisibleInvitationCount = 2
    private let baseHeaderHeight = 120.0
    private let invitationTitleHeight = 32.0
    private let invitationRemainderHeight = 20.0

    // Output
    @Boxed var userData: UserData?
    @Boxed var state = FriendsOverviewState(
        headerHeight: 120.0,
        invitationListHeight: 0.0,
        isSegmentedControlHidden: false,
        invitationCount: 0,
        remainingInvitationCount: 0,
        isInvitationListExpanded: true,
        isInvitationToggleHidden: true
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
                if let userResp = resp.response?.first {
                    userData = UserData(name: userResp.name, kokoid: "KOKO ID：\(userResp.kokoid) 〉")
                }

            } catch {
                // The friends screen remains usable when profile data is unavailable.
            }
        }
    }

    func updateInvitationCount(_ count: Int) {
        let normalizedCount = max(0, count)
        guard invitationCount != normalizedCount else { return }
        invitationCount = normalizedCount
        if normalizedCount == 0 {
            isInvitationListExpanded = true // 重置, 下次有邀請時恢復展開
        }
        updateStateForIdleMode()
    }

    func toggleInvitationList() {
        guard invitationCount > 1 else { return }
        isInvitationListExpanded.toggle()
        updateStateForIdleMode()
    }

    func startSearching() {
        state = FriendsOverviewState(
            headerHeight: 0.0,
            invitationListHeight: 0.0,
            isSegmentedControlHidden: true,
            invitationCount: invitationCount,
            remainingInvitationCount: 0,
            isInvitationListExpanded: isInvitationListExpanded,
            isInvitationToggleHidden: invitationCount <= 1
        )
    }

    func endSearching() {
        updateStateForIdleMode()
    }

    private func updateStateForIdleMode() {
        let visibleInvitationCount: Int
        if invitationCount == 0 {
            visibleInvitationCount = 0
        } else if isInvitationListExpanded {
            visibleInvitationCount = min(invitationCount, maximumVisibleInvitationCount)
        } else {
            visibleInvitationCount = 1
        }
        let invitationHeight = Double(visibleInvitationCount) * invitationRowHeight
        let remainingInvitationCount = max(0, invitationCount - visibleInvitationCount)
        let invitationChromeHeight = invitationCount > 0 ? invitationTitleHeight : 0
        let remainderHeight = remainingInvitationCount > 0
            ? invitationRemainderHeight
            : 0

        state = FriendsOverviewState(
            headerHeight: baseHeaderHeight
                + invitationHeight
                + invitationChromeHeight
                + remainderHeight,
            invitationListHeight: invitationHeight,
            isSegmentedControlHidden: false,
            invitationCount: invitationCount,
            remainingInvitationCount: remainingInvitationCount,
            isInvitationListExpanded: isInvitationListExpanded,
            isInvitationToggleHidden: invitationCount <= 1
        )
    }

}
