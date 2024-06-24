//
//  Guts.swift
//  qview
//
//  Created by bill donner on 6/9/24.
//

import SwiftUI

// MatrixView displays a grid of cells and corresponding labels
struct MatrixView: View {
  let rows: Int
  let cols: Int
  let matrix: [[Move?]]
  let topLabel: String?
  let bottomLabel: String?
  let correctColor: Color
  let incorrectColor: Color
  @Binding var  isPresented: Bool
  
  var body: some View {
    ZStack {
      WrappedDismissButton(isPresented: $isPresented)
      VStack {
        // Top label with reason
        if let topLabel = topLabel {
          Text("\(topLabel)")
            .font(.title)
            .padding(.horizontal)
        }
        
        // Grid of cells
        VStack(spacing: 0) {
          ForEach(0..<rows, id: \.self) { row in
            HStack(spacing: 0) {
              ForEach(0..<cols, id: \.self) { column in
                CellView(move: matrix[row][column], correctColor: correctColor, incorrectColor: incorrectColor)
              }
            }
          }
        }
        .padding()
        
        // Bottom label
        if let bottomLabel = bottomLabel {
          Text("\(bottomLabel)")
            .font(.body)
            .padding(.horizontal)
        }
      }
    }
  }
}

// Move now includes an optional text property and a useSymbol flag
struct Move {
  internal init(_ outcome: Outcome, text: String? = nil, useSymbol: Bool = true) {
    self.outcome = outcome
    self.text = text ?? ""
    self.useSymbol = useSymbol
  }
  let outcome: Outcome
  let text: String
  let useSymbol: Bool
}

// CellView represents each cell in the grid with new text or symbol display logic
struct CellView: View {
  var move: Move?
  let correctColor: Color
  let incorrectColor: Color
  var body: some View {
    Group {
      if let move = move {
        if move.useSymbol  {
          Image(systemName: move.text)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height:30)
        } else {
          Text(move.text)
        }
      } else {
        Text("")
      }
    }
    .frame(width: 64, height: 64)
    .background(Color.black)
    .foregroundColor(.white)
    .border(move?.outcome == .correct ? correctColor :
              (move?.outcome == .incorrect ? incorrectColor : .blue) ,
                   width: move != nil ? 3 : 1)
  }
}

// Enum to define outcomes
enum Outcome {
  case correct
  case incorrect
}

// Data structure to hold position and corresponding move
struct PDM {
  internal init(_ p: (Int, Int), move: Move) {
    self.position = p
    self.move = move
  }
  let position: (row: Int, col: Int)
  let move: Move
}

// Function to create matrix from predefined moves
func PDMatrix(rows: Int, cols: Int, pdms: [PDM], title: String? = "") -> [[Move?]] {
  // Initialize an empty matrix with nil values
  var matrix: [[Move?]] = Array(repeating: Array(repeating: nil, count: cols), count: rows)
  // Place each predefined move into the matrix
  for predefinedMove in pdms {
    let position = predefinedMove.position
    // Ensure position is within bounds
    if position.row < rows && position.col < cols {
      matrix[position.row][position.col] = predefinedMove.move
    }
  }
  return matrix
}
func mkID() -> String {
  return UUID().uuidString
}
struct DismissButton: View {
  @Environment(\.presentationMode) var presentationMode
  @Binding var  isPresented: Bool
    var body: some View {
        Button(action: {
            isPresented = false
        }) {
            Image(systemName: "x.circle")
                .font(.title)
                .foregroundColor(.primary)
        }
    }
}

struct WrappedDismissButton: View {
  @Binding var isPresented:Bool
  var body: some View {
    VStack {
      HStack { Spacer(); DismissButton(isPresented: $isPresented).padding(.horizontal)}
      Spacer()
    }
  }
}
