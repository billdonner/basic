//
//  AlreadyTappedVIew.swift
//  basic
//
//  Created by bill donner on 8/1/24.
//
import SwiftUI
func removeString(from array: [String], stringToRemove: String) -> [String] {
  var newArray = array
  if let index = newArray.firstIndex(of: stringToRemove) {
    newArray.remove(at: index)
  }
  return newArray
}
func removeStrings(from array: [String], stringsToRemove: [String]) -> [String] {
  var newArray = array
  for string in stringsToRemove {
    while let index = newArray.firstIndex(of: string) {
      newArray.remove(at: index)
    }
  }
  return newArray
}

func joinWithCommasAnd(_ array: [String]) -> String {
    guard !array.isEmpty else { return "" }
    
    if array.count == 1 {
        return array[0]
    } else if array.count == 2 {
        return "\(array[0]) and \(array[1])"
    } else {
        let allButLastTwo = array.dropLast(2).joined(separator: ", ")
        let lastTwo = "\(array[array.count - 2]) and \(array.last!)"
        return "\(allButLastTwo), \(lastTwo)"
    }
}
struct AlreadyPlayedView : View {
//  let row:Int
//  let col:Int
  let ch:Challenge
  let gs:GameState
  let chmgr: ChaMan
  @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
  var body: some View {

    if let ansinfo = chmgr.ansinfo[ch.id] {
      ZStack {
        Color.clear
        VStack {
          VStack {
            Button(action:{
              dismiss()
            })
            {
              HStack  {
                Spacer()
                Image(systemName: "x.circle")
                  .font(.title)
                  .foregroundStyle(.black)
              }.padding()
            }
          }
          Spacer()
          VStack (spacing:30){
            Text (ch.question).font(.title)
            VStack (alignment: .leading){
              Text ("You answered this question on \(ansinfo.timestamp)").font(.footnote)
              HStack{Text ("The correct answer is:");Text(" \(ch.correct)").font(.headline);Spacer()}
              HStack{Text ("Your answer was: "); Text("\(ansinfo.answer)").font(.headline);Spacer()}
            }
            VStack {
              if ansinfo.answer == ch.correct {
                Text("You got it right!").font(.title)
              } else {
                Text("Sorry, you got it wrong.").font(.title)
              }
            }
            ScrollView {
            VStack (alignment: .leading){ 
                Text("The other possible answers were: \(joinWithCommasAnd( removeStrings(from: ch.answers, stringsToRemove: [ch.correct,ansinfo.answer])) )").font(.body)
                if ch.hint.count<=1 {
                  Text("There was no hint")
                } else {
                  Text ("The hint was: \(ch.hint)")
                }
                if let exp = ch.explanation  {
                  Text("The explanation given was: \(exp)")
                } else {
                  Text ("no explanation")
                }
                Spacer()
                Text("Played in game \(ansinfo.gamenumber) move \(ansinfo.movenumber) at  (\(ansinfo.row),\(ansinfo.col)) ").font(.footnote)
                Text ("You took \(Int(ansinfo.timetoanswer)) seconds to answer").font(.footnote)
              }
            }
          }.padding(.horizontal)
          Spacer()
        }
      }
      
    } else {
      Color.red
    }
  }
}
//#Preview {
//  AlreadyPlayedView(row: 0, col: 0, gs: GameState.mock() , chmgr: ChaMan(playData: PlayData.mock))
//}
