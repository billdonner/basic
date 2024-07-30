//
//  SingleCellView.swift
//  basic
//
//  Created by bill donner on 7/30/24.
//


import SwiftUI

struct SingleCellView: View {
  let gs:GameState
  let row:Int
  let col:Int
  let challenge:Challenge
  let status:ChallengeOutcomes
  let cellSize: CGFloat
  let onSingleTap: (_ row:Int, _ col:Int ) -> Bool
  @Binding var firstMove:Bool
  var body: some View {
    let colormix = gs.colorForTopic(challenge.topic)
    return VStack(alignment:.center, spacing:0) {
      Text(//hideCellContent ||hideCellContent ||
        ( !gs.faceup) ? " " : challenge.question )
      .font(.caption)
      .padding(10)
      .frame(width: cellSize, height: cellSize)
      .background(colormix.0)
      .foregroundColor(colormix.1)
      .border(status.borderColor , width: gs.cellBorderSize()) //3=8,8=3
      .cornerRadius(8)
      .opacity(gs.gamestate == .playingNow ? 1.0:0.3)
    }
    // for some unknown reason, the tap surface area is bigger if placed outside the VStack
    .onTapGesture {
      var  tap = false
      /* if already played do nothing for now
       if unplayed*/
      if  gs.gamestate == .playingNow { // is the game on
        if    gs.isAlreadyPlayed(row:row,col:col)  {
          print("debug (((((((((((((()))))))))))))")
          // coming
        } else
        if  gs.cellstate[row][col] == .unplayed {
          // if we've got to start in corner on firstMove
          if gs.startincorners&&firstMove{
            tap =  gs.isCornerCell(row: row,col: col)
          }
          else {
            tap = true
          }
        }
      } // actually playing the game
      
      if tap {
        firstMove =    onSingleTap(row,col)
      }
    }
  }// make one cell
}
