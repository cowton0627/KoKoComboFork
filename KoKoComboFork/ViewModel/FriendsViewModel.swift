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

struct FriendCellViewModel {
    let name: String
    let isTop: Bool
    let showsInvitingButton: Bool
    let showsDetailButton: Bool
    
    init(friend: Friend) {
        name = friend.name
        isTop = friend.isTop == "1"
        showsInvitingButton = friend.status == 1
        showsDetailButton = friend.status != 1
    }
}

class FriendsViewModel {

    private let userService: UserServicing
    private var currentSearchText = ""

    @Boxed var cellItems: [Friend] = []
    @Boxed var filteredItems: [Friend] = [] // 篩選後資料
    @Boxed var invitationItems: [Friend] = [] // 邀請者 (status == 0)
    @Boxed var loadState: LoadState = .idle

    init(userService: UserServicing = UserService.shared) {
        self.userService = userService
    }

    func retrieveCellItems(completion: @escaping () -> Void, scenario: Int) {
        loadState = .loading
        if scenario == 1 {
            Task {
                do {
                    let resp1 = try await userService.getFriendsData(scenario: 1)
                    let resp2 = try await userService.getFriendsData(scenario: 2)

                    let mergedItems =
                    self.mergeRedundant(resp1.response ?? [], resp2.response ?? [])

                    applyItems(mergedItems)
                    loadState = .loaded
                    completion()

                } catch (let error) {
                    loadState = .failed(error.localizedDescription)
                    completion()
                }
            }
        } else {
            Task {
                do {
                    let resp = try await userService.getFriendsData(scenario: scenario)

                    applyItems(sortByTopAndFid(resp.response ?? []))
                    loadState = .loaded
                    completion()

                } catch (let error) {
                    loadState = .failed(error.localizedDescription)
                    completion()
                }
            }
        }

    }

    private func applyItems(_ items: [Friend]) {
        cellItems = items
        invitationItems = items.filter { $0.status == 0 }
        applyCurrentFilter()
    }

    private func applyCurrentFilter() {
        let confirmedOrPending = cellItems.filter { $0.status != 0 }
        if currentSearchText.isEmpty {
            filteredItems = confirmedOrPending
        } else {
            filteredItems = confirmedOrPending.filter {
                $0.name.localizedCaseInsensitiveContains(currentSearchText)
            }
        }
    }

    func acceptInvitation(fid: String) {
        guard let idx = cellItems.firstIndex(where: { $0.fid == fid }) else { return }
        let old = cellItems[idx]
        var updated = cellItems
        updated[idx] = Friend(
            name: old.name,
            status: 1,
            isTop: old.isTop,
            fid: old.fid,
            updateDate: old.updateDate
        )
        applyItems(updated)
    }

    func rejectInvitation(fid: String) {
        applyItems(cellItems.filter { $0.fid != fid })
    }

    private func sortByTopAndFid(_ items: [Friend]) -> [Friend] {
        items.sorted {
            if ($0.isTop == "1") != ($1.isTop == "1") {
                return $0.isTop == "1"
            }
            return $0.fid < $1.fid
        }
    }
    
    // 篩選方法
    func filterItems(with searchText: String) {
        currentSearchText = searchText
        applyCurrentFilter()
    }
    
    // fid 重複時的處理
    private func mergeRedundant(_ list1: [Friend],
                                _ list2: [Friend]) -> [Friend] {
        var friendMap = [String: Friend]() // 以 fid 為 key
        
        let combinedList = list1 + list2
        for friend in combinedList {
            if let existingFriend = friendMap[friend.fid] {
                // 比較 updateDate, 保留最新的資料
                if isDateNewer(friend.updateDate, existingFriend.updateDate) {
                    friendMap[friend.fid] = friend
                }
            } else {
                friendMap[friend.fid] = friend
            }
        }
        
        // 置頂優先, 其餘以 fid 排序
        return sortByTopAndFid(Array(friendMap.values))
    }
    
    // 比較不同格式的日期
    private func isDateNewer(_ date1: String, _ date2: String) -> Bool {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyyMMdd"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy/MM/dd"
        
        if let d1 = dateFormatter1.date(from: date1) ?? dateFormatter2.date(from: date1),
           let d2 = dateFormatter1.date(from: date2) ?? dateFormatter2.date(from: date2) {
            return d1 > d2
        }
        return false
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
}
