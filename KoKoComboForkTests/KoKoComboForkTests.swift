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

    func testFilterItemsIsCaseInsensitive() {
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

        viewModel.filterItems(with: "alice")

        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Alice")
    }

}

final class UserViewModelTests: XCTestCase {
    
    func testDefaultStateWithoutInvitations() {
        let viewModel = UserViewModel(
            scenario: 4,
            userService: MockUserService()
        )
        
        XCTAssertEqual(viewModel.state.headerHeight, 120.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 0.0)
        XCTAssertFalse(viewModel.state.isSegmentedControlHidden)
    }
    
    func testInvitationScenarioStateTogglesInvitationList() {
        let viewModel = UserViewModel(
            scenario: 3,
            userService: MockUserService()
        )
        
        XCTAssertEqual(viewModel.state.headerHeight, 260.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 140.0)
        
        viewModel.toggleInvitationList()
        
        XCTAssertEqual(viewModel.state.headerHeight, 190.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 70.0)
    }
    
    func testSearchStateCollapsesHeaderAndRestoresIdleState() {
        let viewModel = UserViewModel(
            scenario: 3,
            userService: MockUserService()
        )
        
        viewModel.startSearching()
        
        XCTAssertEqual(viewModel.state.headerHeight, 0.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 0.0)
        XCTAssertTrue(viewModel.state.isSegmentedControlHidden)
        
        viewModel.endSearching()
        
        XCTAssertEqual(viewModel.state.headerHeight, 260.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 140.0)
        XCTAssertFalse(viewModel.state.isSegmentedControlHidden)
    }
    
    func testInjectedUserServiceUpdatesUserData() {
        let service = MockUserService(
            userResponse: GetUserDataResponse(response: [
                UserData(name: "Injected User", kokoid: "tester")
            ])
        )
        let viewModel = UserViewModel(
            scenario: 4,
            userService: service
        )
        let expectation = XCTestExpectation(description: "User data loaded")
        
        viewModel.$userData.bind { userData in
            if userData?.name == "Injected User" {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.userData?.kokoid, "KOKO ID：tester 〉")
    }
}

private final class MockUserService: UserServicing {
    
    private let userResponse: GetUserDataResponse
    private let friendsResponses: [Int: GetFriendsResponse]
    
    init(
        userResponse: GetUserDataResponse = GetUserDataResponse(response: [
            UserData(name: "Mock User", kokoid: "mockid")
        ]),
        friendsResponses: [Int: GetFriendsResponse] = [:]
    ) {
        self.userResponse = userResponse
        self.friendsResponses = friendsResponses
    }
    
    func getUserData(token: String?) async throws -> GetUserDataResponse {
        userResponse
    }
    
    func getFriendsData(token: String?, scenario: Int) async throws -> GetFriendsResponse {
        friendsResponses[scenario] ?? GetFriendsResponse(response: [])
    }

}

// MARK: - FriendCellViewModel

final class FriendCellViewModelTests: XCTestCase {

    func testStatusOneShowsInvitingButtonNotDetail() {
        let friend = Friend(name: "X", status: 1, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertTrue(cellViewModel.showsInvitingButton)
        XCTAssertFalse(cellViewModel.showsDetailButton)
    }

    func testStatusOtherShowsDetailButtonNotInviting() {
        let friend = Friend(name: "X", status: 2, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertFalse(cellViewModel.showsInvitingButton)
        XCTAssertTrue(cellViewModel.showsDetailButton)
    }

    func testIsTopStringOneMapsToTrue() {
        let friend = Friend(name: "X", status: 1, isTop: "1", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertTrue(cellViewModel.isTop)
    }

    func testIsTopStringZeroMapsToFalse() {
        let friend = Friend(name: "X", status: 1, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertFalse(cellViewModel.isTop)
    }

    func testNamePassesThrough() {
        let friend = Friend(name: "Alice", status: 1, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertEqual(cellViewModel.name, "Alice")
    }

}

// MARK: - Boxed<T>

final class BoxedTests: XCTestCase {

    private final class Container {
        @Boxed var value: Int = 0
    }

    func testBindReceivesCurrentValueImmediately() {
        let container = Container()
        container.value = 5
        var received: Int?

        container.$value.bind { received = $0 }

        XCTAssertEqual(received, 5)
    }

    func testDidSetNotifiesAllListeners() {
        let container = Container()
        var listenerA: Int?
        var listenerB: Int?
        container.$value.bind { listenerA = $0 }
        container.$value.bind { listenerB = $0 }

        container.value = 42

        XCTAssertEqual(listenerA, 42)
        XCTAssertEqual(listenerB, 42)
    }

    func testEveryUpdatePropagatesToListener() {
        let container = Container()
        var received: [Int] = []
        container.$value.bind { received.append($0) }

        container.value = 1
        container.value = 2
        container.value = 3

        // bind 訂閱時先收 0，再依序收 1、2、3
        XCTAssertEqual(received, [0, 1, 2, 3])
    }

}

// MARK: - KoKoAPI.Endpoint

final class KoKoAPIEndpointTests: XCTestCase {

    func testGetUserDataURL() {
        XCTAssertEqual(
            KoKoAPI.Endpoint.getUserData.urlString,
            "https://dimanyen.github.io/man.json"
        )
    }

    func testGetFriendsDataURLEmbedsScenarioNumber() {
        XCTAssertEqual(
            KoKoAPI.Endpoint.getFriendsData(scenario: 3).urlString,
            "https://dimanyen.github.io/friend3.json"
        )
    }

}
