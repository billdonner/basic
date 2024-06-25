//
//  WinLoseTests.swift
//  qdemoTests
//

import XCTest
@testable import basic 

class WinLoseTests: XCTestCase {
    
    // 2x2 Test Cases for isWinningPath
    
    func testWinningPathCase1() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedCorrectly, .playedCorrectly],
            [.playedCorrectly, .playedCorrectly]
        ]
        XCTAssertTrue(isWinningPath(in: matrix))
    }
    
    func testWinningPathCase2() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedCorrectly, .playedIncorrectly],
            [.playedCorrectly, .playedCorrectly]
        ]
        XCTAssertTrue(isWinningPath(in: matrix))
    }

    func testWinningPathCase3() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedCorrectly, .playedCorrectly],
            [.playedIncorrectly, .playedCorrectly]
        ]
        XCTAssertTrue(isWinningPath(in: matrix))
    }

    func testWinningPathCase4() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .playedCorrectly],
            [.playedCorrectly, .playedCorrectly]
        ]
        XCTAssertTrue(isWinningPath(in: matrix))
    }

    func testWinningPathCase5() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedCorrectly, .playedIncorrectly],
            [.playedIncorrectly, .playedCorrectly]
        ]
        XCTAssertTrue(isWinningPath(in: matrix))
    }
    
    func testNoWinningPathCase1() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .playedIncorrectly],
            [.playedIncorrectly, .playedIncorrectly]
        ]
        XCTAssertFalse(isWinningPath(in: matrix))
    }
    
    func testNoWinningPathCase2() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .playedCorrectly],
            [.playedIncorrectly, .playedIncorrectly]
        ]
        XCTAssertFalse(isWinningPath(in: matrix))
    }
    
    func testNoWinningPathCase3() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .playedIncorrectly],
            [.playedCorrectly, .playedIncorrectly]
        ]
        XCTAssertFalse(isWinningPath(in: matrix))
    }
    
    func testNoWinningPathCase4() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedCorrectly, .playedIncorrectly],
            [.playedCorrectly, .playedIncorrectly]
        ]
        XCTAssertFalse(isWinningPath(in: matrix))
    }
    
    // 2x2 Test Cases for isPossibleWinningPath

    func testPossibleWinningPathCase1() {
        let matrix: [[ChallengeOutcomes]] = [
            [.unplayed, .unplayed],
            [.unplayed, .unplayed]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }
    
    func testPossibleWinningPathCase2() {
        let matrix: [[ChallengeOutcomes]] = [
            [.unplayed, .playedCorrectly],
            [.unplayed, .unplayed]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }
    
    func testPossibleWinningPathCase3() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedCorrectly, .unplayed],
            [.unplayed, .unplayed]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }
    
    func testPossibleWinningPathCase4() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .unplayed],
            [.unplayed, .unplayed]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }
    
    func testPossibleWinningPathCase5() {
        let matrix: [[ChallengeOutcomes]] = [
            [.unplayed, .playedIncorrectly],
            [.unplayed, .unplayed]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }

    func testPossibleWinningPathCase6() {
        let matrix: [[ChallengeOutcomes]] = [
            [.unplayed, .unplayed],
            [.unplayed, .playedIncorrectly]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }

    func testPossibleWinningPathCase7() {
        let matrix: [[ChallengeOutcomes]] = [
            [.unplayed, .unplayed],
            [.playedIncorrectly, .unplayed]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }
    
    func testPossibleWinningPathCase8() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .playedIncorrectly],
            [.playedIncorrectly, .unplayed]
        ]
        XCTAssertFalse(isPossibleWinningPath(in: matrix))
    }

    func testPossibleWinningPathCase9() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .unplayed],
            [.unplayed, .playedIncorrectly]
        ]
        XCTAssertTrue(isPossibleWinningPath(in: matrix))
    }
    
    func testPossibleWinningPathCase10() {
        let matrix: [[ChallengeOutcomes]] = [
            [.playedIncorrectly, .playedIncorrectly],
            [.unplayed, .unplayed]
        ]
        XCTAssertFalse(isPossibleWinningPath(in: matrix))
    }
}
