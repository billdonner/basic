import XCTest
@testable import basic 

class ChaManTests: XCTestCase {

    var chaMan: ChaMan!
    var playData: PlayData!

    override func setUp() {
        super.setUp()
        // Set up your test data
        playData = generateTestPlayData()
        chaMan = ChaMan(playData: playData)
    }

    override func tearDown() {
        chaMan = nil
        playData = nil
        super.tearDown()
    }

    func generateTestPlayData() -> PlayData {
      return PlayData.mock 
    }

    func testAllocateChallenges() {
        let allocatedChallenges = chaMan.allocateChallenges(forTopics: ["Math", "Science"], count: 2)
        XCTAssertNotNil(allocatedChallenges, "Allocation failed, returned nil.")
        XCTAssertEqual(allocatedChallenges?.count, 2, "Allocated challenge count mismatch.")
        
        var allocatedIds = Set<String>()
        for challenge in allocatedChallenges! {
            XCTAssertTrue(challenge.topic == "Math" || challenge.topic == "Science", "Challenge allocated from wrong topic.")
            XCTAssertFalse(allocatedIds.contains(challenge.id), "Duplicate challenge allocated.")
            allocatedIds.insert(challenge.id)
        }
    }

    func testDeallocateChallenges() {
        let allocatedChallenges = chaMan.allocateChallenges(forTopics: ["Math", "Science"], count: 2)
        XCTAssertNotNil(allocatedChallenges, "Allocation failed, returned nil.")
        
        let challengeIds = allocatedChallenges!.map { $0.id }
        let challengeIndices = challengeIds.compactMap { id in
            chaMan.everyChallenge.firstIndex { $0.id == id }
        }
        chaMan.resetChallengeStatuses(at: challengeIndices)
        
      for (idx,challenge) in allocatedChallenges!.enumerated() {
        XCTAssertEqual(chaMan.stati[idx],.inReserve, "Challenge not properly deallocated.")
        }
    }

    func testAllocateAllChallenges() {
        let allocatedChallenges = chaMan.allocateChallenges(forTopics: ["Math", "Science"], count: 4)
        XCTAssertNotNil(allocatedChallenges, "Allocation failed, returned nil.")
        XCTAssertEqual(allocatedChallenges?.count, 4, "Allocated challenge count mismatch.")
        
        var allocatedIds = Set<String>()
        for challenge in allocatedChallenges! {
            XCTAssertTrue(challenge.topic == "Math" || challenge.topic == "Science", "Challenge allocated from wrong topic.")
            XCTAssertFalse(allocatedIds.contains(challenge.id), "Duplicate challenge allocated.")
            allocatedIds.insert(challenge.id)
        }
    }

    func testPartialAllocation() {
        let allocatedChallenges = chaMan.allocateChallenges(forTopics: ["Math"], count: 2)
        XCTAssertNotNil(allocatedChallenges, "Allocation failed, returned nil.")
        XCTAssertEqual(allocatedChallenges?.count, 2, "Allocated challenge count mismatch.")
        
        var allocatedIds = Set<String>()
        for challenge in allocatedChallenges! {
            XCTAssertEqual(challenge.topic, "Math", "Challenge allocated from wrong topic.")
            XCTAssertFalse(allocatedIds.contains(challenge.id), "Duplicate challenge allocated.")
            allocatedIds.insert(challenge.id)
        }
    }
}

extension ChaManTests {
    static var allTests = [
        ("testAllocateChallenges", testAllocateChallenges),
        ("testDeallocateChallenges", testDeallocateChallenges),
        ("testAllocateAllChallenges", testAllocateAllChallenges),
        ("testPartialAllocation", testPartialAllocation)
    ]
}
