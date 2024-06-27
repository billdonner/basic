//
//  WinLose.swift
//  qdemo
//
//  Created by bill donner on 5/20/24.
//

import Foundation

////enum ChallengeOutcomes : Codable, Equatable {
//    case unplayed
//    case playedCorrectly
//    case playedIncorrectly
//}

func areCellsAdjacent(_ cell1: (Int, Int), _ cell2: (Int, Int)) -> Bool {
    let rowDifference = abs(cell1.0 - cell2.0)
    let colDifference = abs(cell1.1 - cell2.1)
    
    return rowDifference <= 1 && colDifference <= 1 && !(rowDifference == 0 && colDifference == 0)
}

func isWinningPath(in matrix: [[ChallengeOutcomes]]) -> Bool {
    let n = matrix.count
    guard n > 0 else { return false }

    // Defines directions: right, down, left, up, and the four diagonals
    let directions = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
    
    // Starting points for four corners of the matrix
    let startPoints = [(0, 0), (0, n - 1), (n - 1, 0), (n - 1, n - 1)]
    
    func dfs(_ row: Int, _ col: Int, _ visited: inout Set<String>, _ endRow: Int, _ endCol: Int) -> Bool {
        // Reached opposite corner
        if row == endRow && col == endCol {
            return matrix[row][col] == .playedCorrectly
        }
        
        let key = "\(row),\(col)"
        if visited.contains(key) || matrix[row][col] != .playedCorrectly {
            return false
        }
        
        visited.insert(key)
        
        for direction in directions {
            let newRow = row + direction.0
            let newCol = col + direction.1
            if newRow >= 0, newRow < n, newCol >= 0, newCol < n {
                if dfs(newRow, newCol, &visited, endRow, endCol) {
                    return true
                }
            }
        }
        
        return false
    }
    
    for startPoint in startPoints {
        let endPoint = (n - 1 - startPoint.0, n - 1 - startPoint.1)
        var visited = Set<String>()
        if dfs(startPoint.0, startPoint.1, &visited, endPoint.0, endPoint.1) {
            return true
        }
    }
    
    return false
}
func isPossibleWinningPath(in matrix: [[ChallengeOutcomes]]) -> Bool {
  let n = matrix.count
  guard n > 0 else { return false }

  // Defines directions: right, down, left, up, and four diagonals
  let directions = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
  
  // Starting points: top-left, top-right, bottom-left, bottom-right
  let startPoints = [
      (0, 0, n - 1, n - 1),
      (0, n - 1, n - 1, 0),
      (n - 1, 0, 0, n - 1),
      (n - 1, n - 1, 0, 0)
  ]
  
  func dfs(_ row: Int, _ col: Int, _ endRow: Int, _ endCol: Int, _ visited: inout Set<String>) -> Bool {
      if row == endRow && col == endCol {
          return matrix[row][col] != .playedIncorrectly
      }

      let key = "\(row),\(col)"
      if visited.contains(key) || matrix[row][col] == .playedIncorrectly {
          return false
      }
      
      visited.insert(key)

      for direction in directions{ 
          let newRow = row + direction.0
          let newCol = col + direction.1
          if newRow >= 0, newRow < n, newCol >= 0, newCol < n {
              if dfs(newRow, newCol, endRow, endCol, &visited) {
                  return true
              }
          }
      }

      return false
  }

  for (startRow, startCol, endRow, endCol) in startPoints {
      var visited = Set<String>()
      if dfs(startRow, startCol, endRow, endCol, &visited) {
          return true
      }
  }
  
  return false
}
func hasAdjacentNeighbor(withStates states: Set<ChallengeOutcomes>, in matrix: [[ChallengeOutcomes]], for cell: (Int, Int)) -> Bool {
    let n = matrix.count
    let (row, col) = cell

    // Define directions for the neighboring cells (right, down, left, up, and the four diagonals)
    let directions = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]

    for direction in directions {
        let newRow = row + direction.0
        let newCol = col + direction.1
        if newRow >= 0 && newRow < n && newCol >= 0 && newCol < n {
            if states.contains(matrix[newRow][newCol]) {
                return true
            }
        }
    }
    return false
}
