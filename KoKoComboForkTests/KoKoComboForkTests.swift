//
//  KoKoComboForkTests.swift
//  KoKoComboForkTests
//
//  Created by cowton0627 on 2024/11/22.
//

import XCTest
@testable import KoKoComboFork

private func makeFriend(
    name: String,
    status: Int,
    isTop: String,
    fid: String,
    updateDate: String
) -> Friend {
    Friend(
        name: name,
        status: FriendStatus(apiValue: status),
        isPinned: isTop == "1",
        fid: fid,
        updatedAt: FriendDateParser.parse(updateDate)
    )
}

@MainActor
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
        let olderFriend = makeFriend(
            name: "Older Name",
            status: 1,
            isTop: "0",
            fid: "001",
            updateDate: "20240101"
        )
        let newerFriend = makeFriend(
            name: "Newer Name",
            status: 2,
            isTop: "1",
            fid: "001",
            updateDate: "2024/02/01"
        )
        let secondFriend = makeFriend(
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
                    makeFriend(name: "Alice", status: 1, isTop: "0", fid: "001", updateDate: "2023/01/01"),
                    makeFriend(name: "Bob", status: 1, isTop: "0", fid: "002", updateDate: "2023/01/01")
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
                    makeFriend(name: "Alice", status: 1, isTop: "0", fid: "001", updateDate: "2023/01/01"),
                    makeFriend(name: "Bob", status: 1, isTop: "0", fid: "002", updateDate: "2023/01/01")
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
        XCTAssertEqual(accepted?.status, .friend)
        XCTAssertEqual(viewModel.cellItems.count, 3, "cellItems should keep the same size after accept")
    }

    func testRejectInvitationOnlyHidesFromInvitationListNotMainList() {
        let viewModel = makeViewModelWithInvitations()

        viewModel.rejectInvitation(fid: "002")

        XCTAssertEqual(viewModel.invitationItems.map(\.fid), ["001"],
                       "Bob (002) should no longer appear in the invitation widget")
        XCTAssertEqual(viewModel.cellItems.map(\.fid), ["001", "002", "003"],
                       "Bob should still exist in cellItems (main list keeps him)")
        XCTAssertEqual(viewModel.filteredItems.map(\.fid), ["001", "002", "003"],
                       "Main list should still render Bob with 邀請中 status")
    }

    func testPendingInvitationsAppearInMainList() {
        let viewModel = makeViewModelWithInvitations()

        XCTAssertEqual(viewModel.filteredItems.map(\.name), ["Alice", "Bob", "Carol"],
                       "Status 0 entries should appear in the main list alongside confirmed friends")
    }

    func testAcceptInvitationKeepsActiveSearchAndChangesStatus() {
        let viewModel = makeViewModelWithInvitations()
        viewModel.filterItems(with: "alice")

        XCTAssertEqual(viewModel.filteredItems.map(\.name), ["Alice"],
                       "Search should find Alice even while she's status 0")

        viewModel.acceptInvitation(fid: "001")

        XCTAssertEqual(viewModel.filteredItems.map(\.name), ["Alice"],
                       "Active search filter should survive an accept action")
        XCTAssertEqual(viewModel.cellItems.first { $0.fid == "001" }?.status, .friend)
    }

    func testAcceptInvitationPublishesOneConsistentScreenState() {
        let viewModel = makeViewModelWithInvitations()
        var observedStates: [FriendsScreenState] = []
        let token = viewModel.$state.bind { observedStates.append($0) }

        viewModel.acceptInvitation(fid: "001")

        XCTAssertEqual(observedStates.count, 2, "bind emits current state, then accept emits one update")
        XCTAssertEqual(observedStates.last?.cellItems.count, 3)
        XCTAssertEqual(observedStates.last?.filteredItems.count, 3)
        XCTAssertEqual(observedStates.last?.invitationItems.map(\.fid), ["002"])
        token.cancel()
    }

    func testAcceptedInvitationDoesNotReturnAfterRefresh() {
        let viewModel = makeViewModelWithInvitations()
        viewModel.acceptInvitation(fid: "001")
        let refreshCompleted = expectation(description: "Refresh completed")

        viewModel.retrieveCellItems(
            completion: { refreshCompleted.fulfill() },
            scenario: 3
        )
        wait(for: [refreshCompleted], timeout: 1)

        XCTAssertEqual(viewModel.invitationItems.map(\.fid), ["002"])
        XCTAssertEqual(
            viewModel.cellItems.first { $0.fid == "001" }?.status,
            .friend
        )
    }

    func testRejectedInvitationStaysDismissedAfterRefresh() {
        let viewModel = makeViewModelWithInvitations()
        viewModel.rejectInvitation(fid: "002")
        let refreshCompleted = expectation(description: "Refresh completed")

        viewModel.retrieveCellItems(
            completion: { refreshCompleted.fulfill() },
            scenario: 3
        )
        wait(for: [refreshCompleted], timeout: 1)

        XCTAssertEqual(viewModel.invitationItems.map(\.fid), ["001"])
        XCTAssertEqual(
            viewModel.cellItems.first { $0.fid == "002" }?.status,
            .incomingInvitation
        )
    }

    private func makeViewModelWithInvitations() -> FriendsViewModel {
        let service = MockUserService(
            friendsResponses: [
                3: GetFriendsResponse(response: [
                    makeFriend(name: "Alice", status: 0, isTop: "0", fid: "001", updateDate: "2024/01/01"),
                    makeFriend(name: "Bob",   status: 0, isTop: "0", fid: "002", updateDate: "2024/01/02"),
                    makeFriend(name: "Carol", status: 1, isTop: "0", fid: "003", updateDate: "2024/01/03")
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

@MainActor
final class UserViewModelTests: XCTestCase {
    
    func testDefaultStateWithoutInvitations() {
        let viewModel = UserViewModel(userService: MockUserService())

        XCTAssertEqual(viewModel.state.headerHeight, 120.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 0.0)
        XCTAssertFalse(viewModel.state.isSegmentedControlHidden)
    }

    func testInvitationScenarioStateTogglesInvitationList() {
        let viewModel = UserViewModel(userService: MockUserService())
        viewModel.updateInvitationCount(2)

        XCTAssertEqual(viewModel.state.headerHeight, 292.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 140.0)
        XCTAssertEqual(viewModel.state.invitationCount, 2)
        XCTAssertEqual(viewModel.state.remainingInvitationCount, 0)

        viewModel.toggleInvitationList()

        XCTAssertEqual(viewModel.state.headerHeight, 242.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 70.0)
        XCTAssertEqual(viewModel.state.remainingInvitationCount, 1)
        XCTAssertFalse(viewModel.state.isInvitationListExpanded)
    }

    func testSearchStateCollapsesHeaderAndRestoresIdleState() {
        let viewModel = UserViewModel(userService: MockUserService())
        viewModel.updateInvitationCount(2)

        viewModel.startSearching()

        XCTAssertEqual(viewModel.state.headerHeight, 0.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 0.0)
        XCTAssertTrue(viewModel.state.isSegmentedControlHidden)

        viewModel.endSearching()

        XCTAssertEqual(viewModel.state.headerHeight, 292.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 140.0)
        XCTAssertFalse(viewModel.state.isSegmentedControlHidden)
    }

    func testSingleInvitationUsesOneRowHeight() {
        let viewModel = UserViewModel(userService: MockUserService())

        viewModel.updateInvitationCount(1)

        XCTAssertEqual(viewModel.state.headerHeight, 222.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 70.0)
        XCTAssertTrue(viewModel.state.isInvitationToggleHidden)
    }

    func testThreeInvitationsCapExpandedHeightAtTwoRows() {
        let viewModel = UserViewModel(userService: MockUserService())

        viewModel.updateInvitationCount(3)

        XCTAssertEqual(viewModel.state.headerHeight, 312.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 140.0)
        XCTAssertEqual(viewModel.state.remainingInvitationCount, 1)

        viewModel.toggleInvitationList()

        XCTAssertEqual(viewModel.state.headerHeight, 242.0)
        XCTAssertEqual(viewModel.state.invitationListHeight, 70.0)
        XCTAssertEqual(viewModel.state.remainingInvitationCount, 2)
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

    func testIncomingInvitationShowsTransferAndInvitingButtons() {
        let friend = makeFriend(name: "X", status: 0, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertTrue(cellViewModel.showsTransferButton)
        XCTAssertTrue(cellViewModel.showsInvitingButton)
        XCTAssertFalse(cellViewModel.showsDetailButton)
    }

    func testFriendShowsTransferAndDetailButtons() {
        let friend = makeFriend(name: "X", status: 1, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertTrue(cellViewModel.showsTransferButton)
        XCTAssertTrue(cellViewModel.showsDetailButton)
        XCTAssertFalse(cellViewModel.showsInvitingButton)
    }

    func testOutgoingInvitationShowsTransferAndInvitingButtons() {
        let friend = makeFriend(name: "X", status: 2, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertTrue(cellViewModel.showsTransferButton)
        XCTAssertTrue(cellViewModel.showsInvitingButton)
        XCTAssertFalse(cellViewModel.showsDetailButton)
    }

    func testPinnedFriendMapsToTopPresentation() {
        let friend = makeFriend(name: "X", status: 1, isTop: "1", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertTrue(cellViewModel.isTop)
    }

    func testUnpinnedFriendMapsToRegularPresentation() {
        let friend = makeFriend(name: "X", status: 1, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertFalse(cellViewModel.isTop)
    }

    func testNamePassesThrough() {
        let friend = makeFriend(name: "Alice", status: 1, isTop: "0", fid: "1", updateDate: "")
        let cellViewModel = FriendCellViewModel(friend: friend)

        XCTAssertEqual(cellViewModel.name, "Alice")
    }

}

// MARK: - API DTO mapping

final class FriendDTOMappingTests: XCTestCase {

    func testDTOMapsRawAPIFieldsToDomainTypes() {
        let dto = FriendDTO(
            name: "Alice",
            status: 0,
            isTop: "1",
            fid: "001",
            updateDate: "20240102"
        )

        let friend = dto.toDomain()

        XCTAssertEqual(friend.name, "Alice")
        XCTAssertEqual(friend.status, .incomingInvitation)
        XCTAssertTrue(friend.isPinned)
        XCTAssertEqual(friend.fid, "001")
        XCTAssertNotNil(friend.updatedAt)
    }

    func testDateParserSupportsBothAPIFormats() {
        let compactDate = FriendDateParser.parse("20240102")
        let slashedDate = FriendDateParser.parse("2024/01/02")

        XCTAssertEqual(compactDate, slashedDate)
    }

    func testUnknownStatusIsPreservedForDiagnostics() {
        let friend = FriendDTO(
            name: "Unknown",
            status: 99,
            isTop: "0",
            fid: "999",
            updateDate: "invalid"
        ).toDomain()

        XCTAssertEqual(friend.status, .unknown(99))
        XCTAssertNil(friend.updatedAt)
    }
}

// MARK: - Accessibility

@MainActor
final class AccessibilityTests: XCTestCase {

    func testInvitationCellNamesActionsForTheTargetFriend() throws {
        let objects = UINib(
            nibName: String(describing: InvitationListTableViewCell.self),
            bundle: Bundle(for: InvitationListTableViewCell.self)
        ).instantiate(withOwner: nil)
        let cell = try XCTUnwrap(objects.first as? InvitationListTableViewCell)
        let friend = makeFriend(
            name: "黃靖僑",
            status: 0,
            isTop: "0",
            fid: "001",
            updateDate: "20240101"
        )

        cell.configue(with: friend)

        XCTAssertEqual(cell.nameLabel.accessibilityLabel, "黃靖僑，邀請你成為好友")
        XCTAssertEqual(cell.acceptButton.accessibilityLabel, "接受 黃靖僑 的好友邀請")
        XCTAssertEqual(cell.rejectButton.accessibilityLabel, "拒絕 黃靖僑 的好友邀請")
        XCTAssertEqual(cell.acceptButton.accessibilityIdentifier, "invitation.accept.001")
        XCTAssertEqual(cell.rejectButton.accessibilityIdentifier, "invitation.reject.001")
        XCTAssertTrue(cell.nameLabel.adjustsFontForContentSizeCategory)
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

// MARK: - APIService

final class APIServiceTests: XCTestCase {

    override func tearDown() {
        URLProtocolStub.handler = nil
        super.tearDown()
    }

    func testSendDecodesSuccessfulResponse() async throws {
        URLProtocolStub.handler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")

            return (
                Self.response(for: request, statusCode: 200),
                Data(#"{"response":[{"name":"Alice","status":1,"isTop":"0","fid":"001","updateDate":"20240101"}]}"#.utf8)
            )
        }
        let service = makeService()

        let response: GetFriendsResponseDTO = try await service.send(
            request: APIRequest(url: testURL, method: .get)
        )

        XCTAssertEqual(response.response?.first?.name, "Alice")
        XCTAssertEqual(response.response?.first?.status, 1)
    }

    func testSendThrowsServerErrorForNonSuccessStatus() async {
        URLProtocolStub.handler = { request in
            (
                Self.response(for: request, statusCode: 500),
                Data()
            )
        }
        let service = makeService()

        do {
            let _: GetFriendsResponseDTO = try await service.send(
                request: APIRequest(url: testURL, method: .get)
            )
            XCTFail("Expected serverError")
        } catch APIError.serverError(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSendThrowsDecodingErrorForInvalidJSON() async {
        URLProtocolStub.handler = { request in
            (
                Self.response(for: request, statusCode: 200),
                Data("not-json".utf8)
            )
        }
        let service = makeService()

        do {
            let _: GetFriendsResponseDTO = try await service.send(
                request: APIRequest(url: testURL, method: .get)
            )
            XCTFail("Expected decodingError")
        } catch APIError.decodingError {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSendWrapsTransportFailureAsNetworkError() async {
        URLProtocolStub.handler = { _ in
            throw URLError(.notConnectedToInternet)
        }
        let service = makeService()

        do {
            let _: GetFriendsResponseDTO = try await service.send(
                request: APIRequest(url: testURL, method: .get)
            )
            XCTFail("Expected networkError")
        } catch APIError.networkError {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private var testURL: URL {
        URL(string: "https://example.com/friends.json")!
    }

    private func makeService() -> APIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return APIService(session: URLSession(configuration: configuration))
    }

    private static func response(
        for request: URLRequest,
        statusCode: Int
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
    }
}

private final class URLProtocolStub: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
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
