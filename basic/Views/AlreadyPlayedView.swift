//
//  AlreadyTappedVIew.swift
//  basic
//
//  Created by bill donner on 8/1/24.
//
import SwiftUI

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
                  .foregroundColor(.primary)
              }.padding()
            }
          }
          Spacer()
          VStack (spacing:30){
            Text (ch.question).font(.title)
            VStack (alignment: .leading){
              Text ("You answered this question on \(ansinfo.timestamp)").font(.footnote)
              HStack{Text ("The correct answer is:").font(.caption);Text(" \(ch.correct)").font(.headline).lineLimit(2);Spacer()}
              HStack{Text ("Your answer was: ").font(.caption); Text("\(ansinfo.answer)").font(.headline).lineLimit(2);Spacer()}
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
              if let exp = ch.explanation,exp.count>1 {
                  Text("The explanation given was: \(exp)")
                } else {
                  Text ("no explanation was given")
                }
                Spacer()
                Text("Played in game \(ansinfo.gamenumber) move \(ansinfo.movenumber) at  (\(ansinfo.row),\(ansinfo.col)) ").font(.footnote)
                Text ("You took \(Int(ansinfo.timetoanswer)) seconds to answer").font(.footnote)
              HStack {
                Text("id: ");
                TextField("id", text:.constant("\(ch.id)")).font(.caption)
                Spacer()
              }
              Spacer()
            }.background(Color.gray.opacity(0.2))
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
