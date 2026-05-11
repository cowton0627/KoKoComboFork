//
//  KoKoComboForkTests.swift
//  KoKoComboForkTests
//
//  Created by cowton0627 on 2024/11/22.
//

import XCTest
@testable import KoKoComboFork

final class FriendsViewModelTests: XCTestCase {
    
    func testRetrieveCellItemsUsesScenarioResponse() {
        let service = MockUserService(
            friendsResponses: [
                4: GetFriendsResponse(response: [])
            ]
        )
        let viewModel = FriendsViewModel(userService: service)
        let expectation = XCTestExpectation(description: "Retrieve empty friends list")
        
        viewModel.retrieveCellItems(completion: {
            expectation.fulfill()
        }, scenario: 4)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.cellItems.isEmpty)
        XCTAssertTrue(viewModel.filteredItems.isEmpty)
    }
    
    func testScenarioOneMergesFriendOneAndFriendTwoResponses() {
        let olderFriend = Friend(
            name: "Older Name",
            status: 1,
            isTop: "0",
            fid: "001",
            updateDate: "20240101"
        )
        let newerFriend = Friend(
            name: "Newer Name",
            status: 2,
            isTop: "1",
            fid: "001",
            updateDate: "2024/02/01"
        )
        let secondFriend = Friend(
            name: "Second Friend",
            status: 1,
            isTop: "0",
            fid: "002",
            updateDate: "20240105"
        )
        let service = MockUserService(
            friendsResponses: [
                1: GetFriendsResponse(response: [olderFriend]),
                2: GetFriendsResponse(response: [newerFriend, secondFriend])
            ]
        )
        let viewModel = FriendsViewModel(userService: service)
        let expectation = XCTestExpectation(description: "Retrieve merged friends list")
        
        viewModel.retrieveCellItems(completion: {
            expectation.fulfill()
        }, scenario: 1)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.cellItems.count, 2)
        XCTAssertEqual(viewModel.cellItems.map(\.fid), ["001", "002"])
        XCTAssertEqual(viewModel.cellItems.first?.name, "Newer Name")
        XCTAssertEqual(viewModel.filteredItems.count, 2)
    }
    
    func testFilterItemsFiltersByName() {
        let service = MockUserService(
            friendsResponses: [
                2: GetFriendsResponse(response: [
                    Friend(name: "Alice", status: 1, isTop: "0", fid: "001", updateDate: "2023/01/01"),
                    Friend(name: "Bob", status: 1, isTop: "0", fid: "002", updateDate: "2023/01/01")
                ])
            ]
        )
        let viewModel = FriendsViewModel(userService: service)
        let expectation = XCTestExpectation(description: "Retrieve friends list")
        
        viewModel.retrieveCellItems(completion: {
            expectation.fulfill()
        }, scenario: 2)
        
        wait(for: [expectation], timeout: 1.0)
        viewModel.filterItems(with: "Alice")
        
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Alice")
    }
    
}

private final class MockUserService: UserServicing {
    
    private let friendsResponses: [Int: GetFriendsResponse]
    
    init(friendsResponses: [Int: GetFriendsResponse]) {
        self.friendsResponses = friendsResponses
    }
    
    func getUserData(token: String?) async throws -> GetUserDataResponse {
        GetUserDataResponse(response: [
            UserData(name: "Mock User", kokoid: "mockid")
        ])
    }
    
    func getFriendsData(token: String?, scenario: Int) async throws -> GetFriendsResponse {
        friendsResponses[scenario] ?? GetFriendsResponse(response: [])
    }
    
}
