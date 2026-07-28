//
//  FriendsViewModel.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/12.
//

import Foundation

enum LoadState {
    case idle
    case loading
    case loaded
    case failed(String)
}

struct FriendsScreenState {
    var loadState: LoadState = .idle
    var cellItems: [Friend] = []
    var filteredItems: [Friend] = []
    var invitationItems: [Friend] = []
}

struct FriendCellViewModel {
    let id: String
    let name: String
    let isTop: Bool
    let showsTransferButton: Bool
    let showsInvitingButton: Bool
    let showsDetailButton: Bool

    init(friend: Friend) {
        id = friend.fid
        name = friend.name
        isTop = friend.isPinned
        showsTransferButton = true
        showsInvitingButton = friend.status != .friend
        showsDetailButton = friend.status == .friend
    }
}

@MainActor
final class FriendsViewModel {

    private let userService: UserServicing
    private var currentSearchText = ""

    private var isFetching = false

    @Boxed private(set) var state = FriendsScreenState()

    var cellItems: [Friend] { state.cellItems }
    var filteredItems: [Friend] { state.filteredItems }
    var invitationItems: [Friend] { state.invitationItems }
    var loadState: LoadState { state.loadState }

    /// 已被使用者打叉隱藏的邀請 fid; 對方仍保留在主好友列, 只是不再出現於上方邀請列
    private var dismissedInvitationFids: Set<String> = []
    /// 本次 App session 已接受的邀請；重新 fetch 後仍套用好友狀態。
    private var acceptedInvitationFids: Set<String> = []

    init(userService: UserServicing = UserService.shared) {
        self.userService = userService
    }

    func retrieveCellItems(completion: @escaping () -> Void, scenario: Int) {
        guard !isFetching else {
            completion()
            return
        }
        isFetching = true
        updateState { $0.loadState = .loading }

        Task {
            defer {
                isFetching = false
                completion()
            }

            do {
                if scenario == 1 {
                    async let firstResponse = userService.getFriendsData(scenario: 1)
                    async let secondResponse = userService.getFriendsData(scenario: 2)
                    let (first, second) = try await (firstResponse, secondResponse)
                    applyItems(
                        mergeRedundant(
                            first.response ?? [],
                            second.response ?? []
                        )
                    )
                } else {
                    let resp = try await userService.getFriendsData(scenario: scenario)
                    applyItems(sortByTopAndFid(resp.response ?? []))
                }
                updateState { $0.loadState = .loaded }
            } catch {
                updateState { $0.loadState = .failed(error.localizedDescription) }
            }
        }
    }

    private func applyItems(_ items: [Friend]) {
        let reconciledItems = applySessionActions(to: items)
        updateState {
            $0.cellItems = reconciledItems
            $0.invitationItems = invitationItems(from: reconciledItems)
            $0.filteredItems = filteredItems(from: reconciledItems)
        }
    }

    private func applySessionActions(to items: [Friend]) -> [Friend] {
        items.map { friend in
            guard acceptedInvitationFids.contains(friend.fid),
                  friend.status == .incomingInvitation else {
                return friend
            }

            return Friend(
                name: friend.name,
                status: .friend,
                isPinned: friend.isPinned,
                fid: friend.fid,
                updatedAt: friend.updatedAt
            )
        }
    }

    private func refreshInvitationItems() {
        updateState {
            $0.invitationItems = invitationItems(from: $0.cellItems)
        }
    }

    private func invitationItems(from items: [Friend]) -> [Friend] {
        items.filter {
            $0.status == .incomingInvitation
                && !dismissedInvitationFids.contains($0.fid)
        }
    }

    private func filteredItems(from items: [Friend]) -> [Friend] {
        if currentSearchText.isEmpty {
            return items
        } else {
            return items.filter {
                $0.name.localizedCaseInsensitiveContains(currentSearchText)
            }
        }
    }

    func acceptInvitation(fid: String) {
        guard let idx = state.cellItems.firstIndex(where: { $0.fid == fid }) else { return }
        let old = state.cellItems[idx]
        var updated = state.cellItems
        updated[idx] = Friend(
            name: old.name,
            status: .friend,
            isPinned: old.isPinned,
            fid: old.fid,
            updatedAt: old.updatedAt
        )
        acceptedInvitationFids.insert(fid)
        dismissedInvitationFids.remove(fid)
        applyItems(updated)
    }

    /// 從邀請列移除這筆 (打叉), cellItems 不動, 主好友列仍會看到他.
    func rejectInvitation(fid: String) {
        dismissedInvitationFids.insert(fid)
        refreshInvitationItems()
    }

    private func sortByTopAndFid(_ items: [Friend]) -> [Friend] {
        items.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned
            }
            return $0.fid < $1.fid
        }
    }
    
    // 篩選方法
    func filterItems(with searchText: String) {
        currentSearchText = searchText
        updateState {
            $0.filteredItems = filteredItems(from: $0.cellItems)
        }
    }
    
    // fid 重複時的處理
    private func mergeRedundant(_ list1: [Friend],
                                _ list2: [Friend]) -> [Friend] {
        var friendMap = [String: Friend]() // 以 fid 為 key
        
        let combinedList = list1 + list2
        for friend in combinedList {
            if let existingFriend = friendMap[friend.fid] {
                // 比較 updateDate, 保留最新的資料
                if isDateNewer(friend.updatedAt, existingFriend.updatedAt) {
                    friendMap[friend.fid] = friend
                }
            } else {
                friendMap[friend.fid] = friend
            }
        }
        
        // 置頂優先, 其餘以 fid 排序
        return sortByTopAndFid(Array(friendMap.values))
    }
    
    private func isDateNewer(_ date1: Date?, _ date2: Date?) -> Bool {
        guard let date1, let date2 else { return false }
        return date1 > date2
    }
    
    func numberOfItems() -> Int {
        return filteredItems.count
    }

    func itemAt(_ index: Int) -> Friend {
        return filteredItems[index]
    }
    
    func cellViewModel(at index: Int) -> FriendCellViewModel {
        FriendCellViewModel(friend: itemAt(index))
    }

    private func updateState(_ update: (inout FriendsScreenState) -> Void) {
        var newState = state
        update(&newState)
        state = newState
    }
}
