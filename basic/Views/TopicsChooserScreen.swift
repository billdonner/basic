//
//  TopicSettings.swift
//  tpicker3
//
//  Created by bill donner on 7/8/24.
//

import SwiftUI
/// The view for selecting and arranging topics.
struct TopicsChooserScreen: View {
  let allTopics: [String]
  let schemes: [ColorScheme]
  // no access to gamestate in here so user can cancel out
  let boardsize: Int
  let topicsinplay:[String]
  let chmgr:ChaMan
  
 // let chmgr: ChaMan
  @Binding var currentScheme: Int
  @Binding var selectedTopics: [String]
  
  var body: some View {
    VStack(alignment: .leading) {
      VStack {
//        Text("If you want to change the topics, that's okay but you will end your game. If you just want to change colors or ordering, you should use 'Arrange Topics'.")
//          .font(.body)
//          .padding(.bottom)
//        
//        Text("At board size \( boardsize) you can add \(GameState.maxTopicsForBoardSize(boardsize) - selectedTopics.count) more topics")
//          .font(.subheadline)
        
        if !selectedTopics.isEmpty {
          TopicSelectorView(allTopics: allTopics, selectedTopics: $selectedTopics, selectedSchemeIndex: $currentScheme, chmgr: chmgr, boardSize:boardsize)
        }
       
      }
      
//      ScrollView {
//        let columns = [GridItem(), GridItem(), GridItem()]
//        LazyVGrid(columns: columns, spacing: 10) {
//          ForEach($selectedTopics, id: \.self) { topic in
//            //let topic = selectedTopics[index]
//            let idx = topicsinplay.firstIndex(of: topic.wrappedValue) ?? 0
//            let t = idx % schemes[currentScheme].colors.count
//            let colorInfo = schemes[currentScheme].mappedColors[t]
//            Text(topic.wrappedValue)
//              .padding()
//              .background(colorInfo.0)
//              .foregroundColor(colorInfo.1)
//              .cornerRadius(8)
//              .padding(2)
//              .opacity(0.8)
//          }
//        }
//        .padding(.top)
//      }
    } 
    .padding()
    .navigationTitle("Topics Chooser")
    .navigationBarTitleDisplayMode(.large)
  }
}
