//
//  SingleCellView.swift
//  basic
//
//  Created by bill donner on 7/30/24.
//


import SwiftUI
@ViewBuilder
func markView(at position: CornerPosition, size: CGFloat) -> some View {
  
   let markSize: CGFloat = CGFloat(size)/10.0
    let offset: CGFloat = 100.0
    let xpos = position == .topLeft || position == .bottomLeft ? offset : size - offset
    let ypos =  position == .topLeft || position == .topRight ? offset : size - offset
  
    Circle()
        .fill(Color.orange)
        .frame(width: markSize, height: markSize)
        .position(x: xpos, y: ypos)
}
struct Sdi: Identifiable
{
  let row:Int
  let col:Int
  let id=UUID()
}
enum ChallengeOutcomes: Codable {
  
  case playedCorrectly
  case playedIncorrectly
  case unplayed
  
  var borderColor: Color {
    switch self {
    case .playedCorrectly: return Color.neonGreen
    case .playedIncorrectly: return Color.neonRed
    case .unplayed: return .gray
    }
  }
}
enum CornerPosition: CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}
struct SingleCellView: View {
  let gs:GameState
  let chmgr:ChaMan
  let row:Int
  let col:Int
  let chidx:Int
  let status:ChallengeOutcomes
  let cellSize: CGFloat
  let onSingleTap: (_ row:Int, _ col:Int ) -> Bool
  @Binding var firstMove:Bool
  @State var alreadyPlayed:Sdi?
  var body: some View {
    let thisCellIsLastMove:Bool  = gs.lastmove?.row == row &&  gs.lastmove?.col == col
    let challenge = chidx < 0 ? Challenge.amock : chmgr.everyChallenge[chidx]
    let colormix = gs.colorForTopic(challenge.topic)
    return ZStack {
      VStack(alignment:.center, spacing:0) {
        Text(!gs.faceup ? " " : challenge.question)
          .font(.caption)
          .padding(10)
          .frame(width: cellSize, height: cellSize)
          .background(colormix.0)
          .foregroundColor(.secondary)
          .border(status.borderColor , width: gs.cellBorderSize()) //3=8,8=3
          .cornerRadius(8)
          .opacity(gs.gamestate == .playingNow ? 1.0:0.4)
      }
      if thisCellIsLastMove == true {
        Circle()
          .fill(Color.orange)
          .frame(width: cellSize/5, height: cellSize/5)
          .offset(x:-cellSize/2 + 10,y:-cellSize/2 + 10) 
      }
      if gs.moveindex[row][col] > 50 {     Text("\(gs.moveindex[row][col])").font(.footnote).opacity(gs.moveindex[row][col] != -1 ? 1.0:0.0)
      }
      else {
        Image(systemName:"\(gs.moveindex[row][col]).circle")
          .font(.title)
          .opacity(gs.moveindex[row][col] != -1 ? 0.7:0.0)
          .foregroundColor(
            .black
        )
      }
    }
    .sheet(item: $alreadyPlayed) { goo in
      AlreadyPlayedView(ch: challenge,gs:gs,chmgr:chmgr)
    }
    // for some unknown reason, the tap surface area is bigger if placed outside the VStack
    .onTapGesture {
      var  tap = false
      /* if already played  present a dffirent view */
        if gs.isAlreadyPlayed(row:row,col:col)  {
          alreadyPlayed = Sdi(row:row,col:col)
        } else
     if  gs.gamestate == .playingNow { // is the game on
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
        
        gs.lastmove =    GameMove(row:row,col:col)
        firstMove =    onSingleTap(row,col)
      }
    }
  }// make one cell
}

struct SingleCellView_Previews: PreviewProvider {
    static var previews: some View {
        SingleCellView(
          gs: GameState.mock,
            chmgr: ChaMan(playData:PlayData.mock),
            row: 0,
            col: 0,
            chidx: 0,
            status: .unplayed,
            cellSize: 50,
            onSingleTap: { _, _ in true },
            firstMove: .constant(true)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
