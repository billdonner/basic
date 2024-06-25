//
//  playg.swift
//  qdemo
//
//  Created by bill donner on 5/21/24.
//


import XCTest
@testable import basic


class WinningPathTests: XCTestCase {
   
   func testEmptyMatrix() {
       let matrix: [[ChallengeOutcomes]] = []
       XCTAssertFalse(isWinningPath(in: matrix))
   }
   
   func testSingleCellPlayedCorrectly() {
       let matrix: [[ChallengeOutcomes]] = [[.playedCorrectly]]
       XCTAssertTrue(isWinningPath(in: matrix))
   }

   func testSingleCellPlayedIncorrectly() {
       let matrix: [[ChallengeOutcomes]] = [[.playedIncorrectly]]
       XCTAssertFalse(isWinningPath(in: matrix))
   }
   
   func test2x2MatrixWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedCorrectly],
           [.playedCorrectly, .playedCorrectly],
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
  func test2x2MatrixNotLosingPath() {
    // first move in upper corner fails
      let matrix: [[ChallengeOutcomes]] = [
        [.playedIncorrectly, .unplayed],
          [.unplayed, .unplayed],
      ]
    XCTAssertFalse(isWinningPath(in: matrix))
    XCTAssertTrue(isPossibleWinningPath(in: matrix))
  }
  func test2x2MatrixAlsoNotLosingPath() {
    // first move in upper corner fails
      let matrix: [[ChallengeOutcomes]] = [
        [.unplayed, .unplayed],
          [.unplayed, .playedIncorrectly],
      ]
    XCTAssertFalse(isWinningPath(in: matrix))
    XCTAssertTrue(isPossibleWinningPath(in: matrix))
  }
   func test2x2MatrixMainDiagonalWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly],
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
   
   func test2x2MatrixNoWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedIncorrectly],
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }
   
   func test3x3MatrixWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.unplayed, .playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
   
   func test3x3MatrixNoWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .playedIncorrectly],
           [.unplayed, .playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .playedIncorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }
   
   func testComplexMatrixWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed],
           [.playedIncorrectly, .playedCorrectly, .unplayed],
           [.playedIncorrectly, .playedCorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
   
   func testComplexMatrixNoWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed],
           [.playedIncorrectly, .playedIncorrectly, .unplayed],
           [.playedIncorrectly, .unplayed, .playedCorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }
  func test3x3ReverseDiagonal() {
      let matrix: [[ChallengeOutcomes]] = [
          [.unplayed, .unplayed, .playedCorrectly],
          [.unplayed, .playedCorrectly, .unplayed],
          [.playedCorrectly, .unplayed, .unplayed]
      ]
      XCTAssertTrue(isWinningPath(in: matrix))
  }
   // --- New 4x4 Test Cases ---

   func test4x4MatrixWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedIncorrectly, .playedCorrectly, .playedCorrectly],
           [.playedCorrectly, .playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .playedCorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
   
   func test4x4MatrixNoWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .playedCorrectly, .unplayed],
           [.unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed],
           [.unplayed, .unplayed, .playedIncorrectly, .playedIncorrectly],
           [.playedIncorrectly, .unplayed, .unplayed, .playedIncorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }

   func test4x4MatrixComplexWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedCorrectly, .unplayed, .unplayed],
           [.unplayed, .unplayed, .playedCorrectly, .unplayed],
           [.unplayed, .unplayed, .unplayed, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
   
   func test4x4MatrixWinningPathDirty() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .playedIncorrectly, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }

   // --- New 5x5 Test Cases ---

   func test5x5MatrixLongWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
           [.playedCorrectly, .playedCorrectly, .unplayed, .playedIncorrectly, .unplayed],
           [.unplayed, .playedIncorrectly, .playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly],
           [.playedCorrectly, .playedCorrectly, .playedCorrectly, .playedCorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }

   func test5x5MatrixComplexWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .unplayed, .playedIncorrectly, .unplayed, .unplayed],
           [.unplayed, .playedCorrectly, .unplayed, .playedIncorrectly, .unplayed],
           [.unplayed, .unplayed, .playedCorrectly, .unplayed, .playedIncorrectly],
           [.playedIncorrectly, .unplayed, .playedIncorrectly, .playedCorrectly, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .unplayed, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }

   func test5x5MatrixNoWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .unplayed, .playedIncorrectly, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .unplayed, .playedIncorrectly, .unplayed],
           [.unplayed, .unplayed, .playedIncorrectly, .unplayed, .playedIncorrectly],
           [.playedIncorrectly, .unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .unplayed, .playedIncorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }

   func test5x5MatrixLongPathButNoWinning() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .playedIncorrectly, .unplayed],
           [.playedIncorrectly, .playedCorrectly, .playedIncorrectly, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .playedCorrectly, .unplayed, .unplayed],
           [.unplayed, .unplayed, .unplayed, .unplayed, .playedIncorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }
   
   // --- New 8x8 Test Cases ---

 func test8x8MatrixLongWinningPath1() {
     let matrix: [[ChallengeOutcomes]] = [
         [.playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
         [.playedCorrectly, .playedCorrectly, .playedIncorrectly, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly]
     ]
     XCTAssertTrue(isWinningPath(in: matrix))
 }
 func test8x8MatrixLongWinningPath2() {
     let matrix: [[ChallengeOutcomes]] = [
         [.playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
         [.playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly]
     ]
     XCTAssertTrue(isWinningPath(in: matrix))
 }

   func test8x8MatrixNoWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedCorrectly, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
           [.unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
           [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedIncorrectly],
           [.unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed, .playedIncorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }

   func test8x8MatrixLongPathButNoWinning() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .playedCorrectly, .unplayed],
           [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed],
           [.unplayed, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.playedIncorrectly, .playedIncorrectly, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .playedIncorrectly]
       ]
       XCTAssertFalse(isWinningPath(in: matrix))
   }

   func test8x8MatrixComplexWinningPath() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedCorrectly, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
           [.playedIncorrectly, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .unplayed],
           [.unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed],
           [.unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed, .playedCorrectly, .unplayed],
           [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly]
       ]
       XCTAssertTrue(isWinningPath(in: matrix))
   }
 
 func test8x8MatrixSnakingWinningPath() {
     let matrix: [[ChallengeOutcomes]] = [
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed],
         [.unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed, .playedCorrectly, .unplayed],
         [.unplayed, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
         [.playedCorrectly, .playedCorrectly, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed]
     ]
     XCTAssertTrue(isWinningPath(in: matrix))
 }
 func test8x8MatrixReverseDiagonalWinningPath() {
     let matrix: [[ChallengeOutcomes]] = [
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly],
         [.unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed],
         [.unplayed, .playedCorrectly, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed],
         [.playedCorrectly, .unplayed, .playedCorrectly, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed],
         [.unplayed, .playedCorrectly, .unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed],
         [.playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly]
     ]
     XCTAssertTrue(isWinningPath(in: matrix))
 }
}

 
class CellAdjacencyTests: XCTestCase {
   
   func testCellsAreHorizontallyAdjacent() {
       XCTAssertTrue(areCellsAdjacent((0, 0), (0, 1)))
       XCTAssertTrue(areCellsAdjacent((1, 1), (1, 2)))
       XCTAssertTrue(areCellsAdjacent((2, 3), (2, 2)))
   }
   
   func testCellsAreVerticallyAdjacent() {
       XCTAssertTrue(areCellsAdjacent((0, 0), (1, 0)))
       XCTAssertTrue(areCellsAdjacent((2, 1), (3, 1)))
       XCTAssertTrue(areCellsAdjacent((1, 1), (0, 1)))
   }
   
   func testCellsAreDiagonallyAdjacent() {
       XCTAssertTrue(areCellsAdjacent((0, 0), (1, 1)))
       XCTAssertTrue(areCellsAdjacent((2, 2), (1, 1)))
       XCTAssertTrue(areCellsAdjacent((1, 1), (2, 2)))
   }
   
   func testCellsAreNotAdjacent() {
       XCTAssertFalse(areCellsAdjacent((0, 0), (2, 2)))
       XCTAssertFalse(areCellsAdjacent((1, 1), (3, 1)))
       XCTAssertFalse(areCellsAdjacent((0, 0), (2, 1)))
   }
   
   func testSameCellIsNotAdjacent() {
       XCTAssertFalse(areCellsAdjacent((0, 0), (0, 0)))
       XCTAssertFalse(areCellsAdjacent((1, 1), (1, 1)))
   }

   func testOtherBoardSizes() {
       XCTAssertTrue(areCellsAdjacent((10, 10), (10, 11)))
       XCTAssertTrue(areCellsAdjacent((10, 10), (11, 10)))
       XCTAssertTrue(areCellsAdjacent((10, 10), (9, 9)))
       XCTAssertFalse(areCellsAdjacent((10, 10), (12, 12)))
   }
}
class PossibleWinningPathTests: XCTestCase {
   
   func testEmptyMatrix() {
       let matrix: [[ChallengeOutcomes]] = []
       XCTAssertFalse(isPossibleWinningPath(in: matrix))
   }
   
   func testSingleCellPlayedCorrectly() {
       let matrix: [[ChallengeOutcomes]] = [[.playedCorrectly]]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }

   func testSingleCellPlayedIncorrectly() {
       let matrix: [[ChallengeOutcomes]] = [[.playedIncorrectly]]
       XCTAssertFalse(isPossibleWinningPath(in: matrix))
   }
   
   func test2x2MatrixWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly],
           [.unplayed, .playedCorrectly],
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
   
   func test2x2MatrixNoWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly],
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
   
   func test3x3MatrixWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.unplayed, .playedCorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .unplayed]
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
   
   func test3x3MatrixNoWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .playedIncorrectly],
           [.unplayed, .playedIncorrectly, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .playedIncorrectly]
       ]
       XCTAssertFalse(isPossibleWinningPath(in: matrix))
   }
   
   func testComplexMatrixWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed],
           [.unplayed, .playedCorrectly, .unplayed],
           [.playedIncorrectly, .unplayed, .playedCorrectly]
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
   
   func testComplexMatrixNoWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed],
           [.playedIncorrectly, .playedIncorrectly, .unplayed],
           [.playedIncorrectly, .unplayed, .playedCorrectly]
       ]
       XCTAssertFalse(isPossibleWinningPath(in: matrix))
   }
   
   // --- New 4x4 Test Cases ---

   func test4x4MatrixWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed],
           [.unplayed, .playedCorrectly, .playedIncorrectly, .unplayed],
           [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly],
           [.playedIncorrectly, .unplayed, .unplayed, .playedCorrectly]
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
   
   func test4x4MatrixWinningPathPossibleComplex() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .playedIncorrectly, .unplayed],
           [.playedCorrectly, .unplayed, .unplayed, .playedIncorrectly],
           [.playedIncorrectly, .playedCorrectly, .playedCorrectly, .playedIncorrectly],
           [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
   
   func test4x4MatrixNoWinningPathPossible() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed],
           [.unplayed, .unplayed, .playedIncorrectly, .playedIncorrectly],
           [.playedIncorrectly, .unplayed, .unplayed, .playedIncorrectly]
       ]
       XCTAssertFalse(isPossibleWinningPath(in: matrix))
   }
   
   func test4x4MatrixWinningPathPossibleDirty() {
       let matrix: [[ChallengeOutcomes]] = [
           [.playedCorrectly, .unplayed, .unplayed, .unplayed],
           [.unplayed, .playedIncorrectly, .playedCorrectly, .playedIncorrectly],
           [.unplayed, .unplayed, .playedCorrectly, .unplayed],
           [.playedIncorrectly, .playedCorrectly, .playedIncorrectly, .playedCorrectly]
       ]
       XCTAssertTrue(isPossibleWinningPath(in: matrix))
   }
 
 
 // --- New 6x6 Test Cases ---

 func test6x6MatrixWinningPathPossible() {
     let matrix: [[ChallengeOutcomes]] = [
         [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .playedIncorrectly, .playedCorrectly, .unplayed, .playedIncorrectly, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .playedIncorrectly, .unplayed],
         [.playedIncorrectly, .unplayed, .unplayed, .unplayed, .playedCorrectly, .unplayed],
         [.unplayed, .playedIncorrectly, .playedIncorrectly, .playedCorrectly, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .playedIncorrectly, .playedCorrectly, .playedCorrectly]
     ]
     XCTAssertTrue(isPossibleWinningPath(in: matrix))
 }

 func test6x6MatrixNoWinningPathPossible() {
     let matrix: [[ChallengeOutcomes]] = [
         [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed, .playedIncorrectly, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .playedIncorrectly, .playedIncorrectly, .unplayed],
         [.playedIncorrectly, .unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed],
         [.unplayed, .playedIncorrectly, .playedIncorrectly, .playedIncorrectly, .unplayed, .unplayed],
         [.unplayed, .unplayed, .unplayed, .playedIncorrectly, .playedIncorrectly, .playedIncorrectly]
     ]
     XCTAssertTrue(isPossibleWinningPath(in: matrix))
 }

 func test6x6MatrixComplexWinningPathPossible() {
     let matrix: [[ChallengeOutcomes]] = [
         [.playedCorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .playedCorrectly, .unplayed, .playedIncorrectly, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .playedCorrectly, .unplayed, .unplayed],
         [.playedIncorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .playedCorrectly],
         [.unplayed, .playedIncorrectly, .playedIncorrectly, .unplayed, .unplayed, .unplayed],
         [.playedIncorrectly, .unplayed, .playedIncorrectly, .playedCorrectly, .playedCorrectly, .playedCorrectly]
     ]
     XCTAssertTrue(isPossibleWinningPath(in: matrix))
 }

 func test6x6MatrixWinningPathPossibleDirty() {
     let matrix: [[ChallengeOutcomes]] = [
         [.playedCorrectly, .unplayed, .unplayed, .unplayed, .unplayed, .unplayed],
         [.unplayed, .playedIncorrectly, .unplayed, .playedCorrectly, .unplayed, .unplayed],
         [.unplayed, .unplayed, .playedCorrectly, .playedIncorrectly, .unplayed, .unplayed],
         [.playedIncorrectly, .playedCorrectly, .unplayed, .unplayed, .unplayed, .playedCorrectly],
         [.unplayed, .unplayed, .unplayed, .playedIncorrectly, .unplayed, .unplayed],
         [.playedIncorrectly, .playedCorrectly, .playedIncorrectly, .playedCorrectly, .playedIncorrectly, .playedCorrectly]
     ]
     XCTAssertTrue(isPossibleWinningPath(in: matrix))
 }
}

func runtests() {
 print("Running tests")
 CellAdjacencyTests.defaultTestSuite.run()
 
 
 PossibleWinningPathTests.defaultTestSuite.run()
 
 
 WinningPathTests.defaultTestSuite.run()
 
}
//run()
