//
//  WinLose.swift
//  qdemo
//
//  Created by bill donner on 5/20/24.
//

import Foundation

enum MatrixError: Error {
    case notSquareArray
}

// Shared toSquareArray Function
func toSquareArray(_ array: [ChallengeOutcomes]) -> [[ChallengeOutcomes]]? {
    let size = Int(sqrt(Double(array.count)))
    if size * size != array.count { return nil } // Ensure the array can be converted into a square matrix
    
    var result = [[ChallengeOutcomes]]()
    for i in 0..<size {
        var row = [ChallengeOutcomes]()
        for j in 0..<size {
            row.append(array[i * size + j]) // Convert to 2D array
        }
        result.append(row)
    }
    return result
}


func convertToSquareMatrix(_ array: [ChallengeOutcomes]) throws -> [[ChallengeOutcomes]] {
    // Calculate the square root of the array length
    let length = array.count
    let side = Int(sqrt(Double(length)))
    
    // Check if length is a perfect square
    if side * side != length {
        throw MatrixError.notSquareArray // Not a perfect square, cannot form a square matrix
    }
    
    // Initialize the square matrix
  var squareMatrix = Array(repeating: Array(repeating: ChallengeOutcomes.unplayed, count: side), count: side)
    
    // Fill the square matrix with the elements from the linear array
    for (index, element) in array.enumerated() {
        let row = index / side
        let col = index % side
        squareMatrix[row][col] = element
    }
    
    return squareMatrix
}
/// This function checks if two given cells in a square matrix are adjacent.
/// Adjacency is defined as horizontally, vertically, or diagonally neighboring cells.
///
/// - Parameters:
///   - cell1: A tuple representing the coordinates (row, column) of the first cell.
///   - cell2: A tuple representing the coordinates (row, column) of the second cell.
/// - Returns: A boolean value indicating whether the two cells are adjacent.
func areCellsAdjacent(_ cell1: (Int, Int), _ cell2: (Int, Int)) -> Bool {
   let rowDifference = abs(cell1.0 - cell2.0)
   let colDifference = abs(cell1.1 - cell2.1)
   
   return rowDifference <= 1 && colDifference <= 1 && !(rowDifference == 0 && colDifference == 0)
}


/// This function determines if there is a winning path in the current matrix.
/// A winning path is defined as a continuous sequence of cells marked as `correct`
/// that starts from any corner of the matrix and reaches the diagonally opposite corner.
///
/// - Parameter matrix: A square matrix of ChallengeOutcomes representing the current state of the game board.
/// - Returns: A boolean value indicating whether a winning path exists.



func isWinningPath(in matrix: [[ChallengeOutcomes]]) -> Bool {
   let n = matrix.count
   guard n > 0 else { return false }
   guard matrix[0][0] == .playedCorrectly else { return false }

   // Defines directions: right, down, left, up, and the four diagonals
   let directions = [(0, 1), (1, 0), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
   
   func dfs(_ row: Int, _ col: Int, _ visited: inout Set<String>) -> Bool {
       // Reached bottom-right corner
       if row == n - 1 && col == n - 1 {
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
               if dfs(newRow, newCol, &visited) {
                   return true
               }
           }
       }
       
       return false
   }
   
   var visited = Set<String>()
   return dfs(0, 0, &visited)
}
/// This function determines if there is any possible winning path in the future
/// in the given matrix. A possible winning path is defined as a path from the
/// top-left corner to the bottom-right corner that can potentially be turned
/// into a winning path by changing `unplayed` cells to `playedCorrectly`.
///
/// - Parameter matrix: A square matrix of ChallengeOutcomes representing the current state of the game board.
/// - Returns: A boolean value indicating whether a possible winning path exists.


func isPossibleWinningPath(in matrix: [[ChallengeOutcomes]]) -> Bool {
   let n = matrix.count
   guard n > 0 else { return false }
   guard matrix[0][0] != .playedIncorrectly else { return false }

   func dfs(_ row: Int, _ col: Int, _ visited: inout Set<String>) -> Bool {
       if row == n - 1 && col == n - 1 {
           return matrix[row][col] != .playedIncorrectly
       }
       
       let key = "\(row),\(col)"
       if visited.contains(key) || matrix[row][col] == .playedIncorrectly {
           return false
       }
       
       visited.insert(key)
       
       let directions = [(0, 1), (1, 0), (-1, 0), (0, -1)]
       for direction in directions {
           let newRow = row + direction.0
           let newCol = col + direction.1
           if newRow >= 0 && newRow < n && newCol >= 0 && newCol < n {
               if dfs(newRow, newCol, &visited) {
                   return true
               }
           }
       }
       
       return false
   }
   
   var visited = Set<String>()
   return dfs(0, 0, &visited)
}
//This function takes a set of possible states and checks if any of the adjacent cells in the matrix belong to the given set, returning `true` if such a cell is found, and `false` otherwise.
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
