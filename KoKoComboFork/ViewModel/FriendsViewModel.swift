//
//  FriendsViewModel.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
//

import Foundation

//enum APIRequestType {
//    case noFriends
//    case friendsList
//    case friendsWithInvites
//}

class FriendsViewModel {
    
    
    @Boxed var cellItems: [Friend] = []
    @Boxed var filteredItems: [Friend] = [] // 篩選後資料

    
    func retrieveCellItems(completion: @escaping () -> Void, scenario: Int) {
        if scenario == 1 {
            Task {
                do {
                    let resp1 = try await UserService.shared.getFriendsData(scenario: 1)
                    let resp2 = try await UserService.shared.getFriendsData(scenario: 2)
                    
                    print(resp1)
                    print(resp2)
                    
                    let mergedItems =
                    self.mergeRedundant(resp1.response ?? [], resp1.response ?? [])

                    cellItems = mergedItems
                    filteredItems = mergedItems // 初始化為完整數據
                    
                    completion()
                    
                } catch (let error) { print(error.localizedDescription) }
            }
        } else {
            Task {
                do {
                    let resp = try await UserService.shared.getFriendsData(scenario: scenario)
                    
                    print(resp)

                    cellItems = resp.response ?? []
                    filteredItems = self.cellItems // 初始化為完整數據

                    completion()

                } catch (let error) {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    // 篩選方法
    func filterItems(with searchText: String) {
        if searchText.isEmpty {
            filteredItems = cellItems   // 顯示所有數據
        } else {
            filteredItems = cellItems.filter { $0.name.contains(searchText) }
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
                if isDateNewer(friend.updateDate, existingFriend.updateDate) {
                    friendMap[friend.fid] = friend
                }
            } else {
                friendMap[friend.fid] = friend
            }
        }
        
        // 以 fid 重新排序
        return Array(friendMap.values).sorted { $0.fid < $1.fid }
//        return Array(friendMap.values)
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
//        return cellItems.count
        return filteredItems.count
    }
    
    func itemAt(_ index: Int) -> Friend {
//        return cellItems[index]
        return filteredItems[index]
    }
}

