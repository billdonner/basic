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

    return  ZStack {
      // part 1:
      // if faceup show the question else blank
      VStack(alignment:.center, spacing:0) {
        Text(!gs.faceup ? " " : challenge.question)
          .font(.caption)
          .padding(10)
          .frame(width: cellSize, height: cellSize)
          .background(colormix.0)
          .foregroundColor(.secondary)
        //part 2:
        //color border according to correctness
          .border(status.borderColor , width: gs.cellBorderSize()) //3=8,8=3
          .cornerRadius(8)
          .opacity(gs.gamestate == .playingNow ? 1.0:0.4)
      }
      // part 3:
      // mark corner of last move with orange circle
      if thisCellIsLastMove == true {
        Circle()
          .fill(Color.orange)
          .frame(width: cellSize/5, height: cellSize/5)
          .offset(x:-cellSize/2 + 10,y:-cellSize/2 + 10) 
      }// might have row or col out of whack here
      // mark upper right as well if its been replaced
      
  if row<gs.boardsize && col<gs.boardsize {
      if gs.replaced[row][col] != [] {
        Circle()
          .fill(Color.neonRed)
          .frame(width: cellSize/5, height: cellSize/5)
          .offset(x:-cellSize/2 + 10,y:cellSize/2 - 10)
      }
          
        
        // part 4:
        // nice sfsymbols only until 50
        if gs.moveindex[row][col] == -1 {
          Text("???").font(.footnote).opacity(gs.moveindex[row][col] != -1 ? 1.0:0.0)
        } else
        if gs.moveindex[row][col] > 50 {     Text("\(gs.moveindex[row][col])").font(.footnote).opacity(gs.moveindex[row][col] != -1 ? 1.0:0.0)
        }
        else {
          //use the sfsymbol
          Image(systemName:"\(gs.moveindex[row][col]).circle")
            .font(.title)
            .opacity(gs.moveindex[row][col] != -1 ? 0.7:0.0)
            .foregroundColor(foregroundColorFrom( backgroundColor:gs.colorForTopic (   challenge.topic ).0)
            )
        }
        // part 5:
        // highlight the winning path with a green checkmark overlays
        if gs.onwinpath[row][col] {
          Image(systemName:"checkmark")
            .font(.largeTitle)
            .foregroundColor(.green)
        }
      }// row in bounds
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
        
        gs.lastmove =    GameMove(row:row,col:col,movenumber: gs.movenumber)
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
