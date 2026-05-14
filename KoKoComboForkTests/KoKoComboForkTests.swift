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

    func testAcceptInvitationFlipsStatusAndRemovesFromInvitationList() {
        let viewModel = makeViewModelWithInvitations()

        XCTAssertEqual(viewModel.invitationItems.map(\.fid), ["001", "002"])

        viewModel.acceptInvitation(fid: "001")

        XCTAssertEqual(viewModel.invitationItems.map(\.fid), ["002"])
        let accepted = viewModel.cellItems.first { $0.fid == "001" }
        XCTAssertEqual(accepted?.status, 1)
        XCTAssertEqual(viewModel.cellItems.count, 3, "cellItems should keep the same size after accept")
    }

    func testRejectInvitationRemovesFromCellItems() {
        let viewModel = makeViewModelWithInvitations()

        viewModel.rejectInvitation(fid: "002")

        XCTAssertEqual(viewModel.cellItems.map(\.fid), ["001", "003"])
        XCTAssertEqual(viewModel.invitationItems.map(\.fid), ["001"])
    }

    func testFilteredItemsExcludesPendingInvitations() {
        let viewModel = makeViewModelWithInvitations()

        XCTAssertEqual(viewModel.filteredItems.map(\.name), ["Carol"],
                       "Status 0 entries should not appear in the main friends list")
    }

    func testAcceptInvitationKeepsActiveSearchAndPromotesFriend() {
        let viewModel = makeViewModelWithInvitations()
        viewModel.filterItems(with: "alice")

        XCTAssertTrue(viewModel.filteredItems.isEmpty,
                      "Alice is still an invitation, so the main list search yields nothing")

        viewModel.acceptInvitation(fid: "001")

        XCTAssertEqual(viewModel.filteredItems.map(\.name), ["Alice"],
                       "Once accepted, Alice should appear in the main list under the same search")
    }

    private func makeViewModelWithInvitations() -> FriendsViewModel {
        let service = MockUserService(
            friendsResponses: [
                3: GetFriendsResponse(response: [
                    Friend(name: "Alice", status: 0, isTop: "0", fid: "001", updateDate: "2024/01/01"),
                    Friend(name: "Bob",   status: 0, isTop: "0", fid: "002", updateDate: "2024/01/02"),
                    Friend(name: "Carol", status: 1, isTop: "0", fid: "003", updateDate: "2024/01/03")
                ])
            ]
        )
        let viewModel = FriendsViewModel(userService: service)
        let expectation = XCTestExpectation(description: "Initial fetch")
        viewModel.retrieveCellItems(completion: { expectation.fulfill() }, scenario: 3)
        wait(for: [expectation], timeout: 1.0)
        return viewModel
    }

}

final class UserViewModelTests: XCTestCase {
    
    func testDefaultStateWithoutInvitations() {
        let viewModel = UserViewModel(userService: MockUserService())

        XCTAssertEqual(viewModel.state.headerHeight, 120.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 0.0)
        XCTAssertFalse(viewModel.state.isSegmentedControlHidden)
    }

    func testInvitationScenarioStateTogglesInvitationList() {
        let viewModel = UserViewModel(userService: MockUserService())
        viewModel.setHasInvitations(true)

        XCTAssertEqual(viewModel.state.headerHeight, 260.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 140.0)

        viewModel.toggleInvitationList()

        XCTAssertEqual(viewModel.state.headerHeight, 190.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 70.0)
    }

    func testSearchStateCollapsesHeaderAndRestoresIdleState() {
        let viewModel = UserViewModel(userService: MockUserService())
        viewModel.setHasInvitations(true)

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
        let viewModel = UserViewModel(userService: service)
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
    
    func getUserData() async throws -> GetUserDataResponse {
        userResponse
    }

    func getFriendsData(scenario: Int) async throws -> GetFriendsResponse {
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

    func testCancelStopsFurtherNotifications() {
        let container = Container()
        var received: [Int] = []
        let token = container.$value.bind { received.append($0) }

        container.value = 1
        token.cancel()
        container.value = 2
        container.value = 3

        XCTAssertEqual(received, [0, 1])
    }

    func testCancelOnlyAffectsItsOwnListener() {
        let container = Container()
        var firstReceived: [Int] = []
        var secondReceived: [Int] = []
        let firstToken = container.$value.bind { firstReceived.append($0) }
        container.$value.bind { secondReceived.append($0) }

        firstToken.cancel()
        container.value = 99

        XCTAssertEqual(firstReceived, [0])
        XCTAssertEqual(secondReceived, [0, 99])
    }

    func testBackgroundWriteDeliversListenerOnMainThread() {
        let container = Container()
        let expectation = XCTestExpectation(description: "Listener fired")
        var listenerThreadWasMain = false

        container.$value.bind { value in
            guard value == 7 else { return }
            listenerThreadWasMain = Thread.isMainThread
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            container.value = 7
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(listenerThreadWasMain)
    }

}

// MARK: - KoKoAPI.Endpoint

final class KoKoAPIEndpointTests: XCTestCase {

    func testGetUserDataURL() {
        XCTAssertEqual(
            KoKoAPI.Endpoint.getUserData.urlString,
            "https://cowton-apis.github.io/koko/man.json"
        )
    }

    func testGetFriendsDataURLEmbedsScenarioNumber() {
        XCTAssertEqual(
            KoKoAPI.Endpoint.getFriendsData(scenario: 3).urlString,
            "https://cowton-apis.github.io/koko/friend3.json"
        )
    }

}
