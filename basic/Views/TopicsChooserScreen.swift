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
  let gs: GameState
  @Binding var currentScheme: Int
  @Binding var selectedTopics: [String]
  var body: some View {
    VStack(alignment: .leading) {
      VStack {
        Text("If you want to change the topics, that's okay but you will end your game. If you just want to change colors or ordering, you should use 'Arrange Topics'.")
          .font(.body)
          .padding(.bottom)
        Text("At board size \(gs.boardsize) you can add \(GameState.maxTopicsForBoardSize(gs.boardsize) - selectedTopics.count) more topics")
          .font(.subheadline)
        
        HStack {
          NavigationLink(destination: TopicSelectorView(allTopics: allTopics, selectedTopics: $selectedTopics, selectedSchemeIndex:$currentScheme, boardSize: gs.boardsize)) {
            Text("Select Topics")
          }
          
          NavigationLink(destination: TopicColorizerView(topics: $selectedTopics, selectedSchemeIndex: $currentScheme, schemes: schemes)) {
            Text("Arrange Topics")
          }
          .disabled(selectedTopics.isEmpty)
        }
        .padding()
      }
      
      ScrollView {
        let columns = [GridItem(), GridItem(), GridItem()]
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(selectedTopics.indices, id: \.self) { index in
            let topic = selectedTopics[index]
            let colorInfo = schemes[currentScheme].mappedColors[index % schemes[currentScheme].colors.count]
            Text(topic)
              .padding()
              .background(colorInfo.0)
              .foregroundColor(colorInfo.1)
              .cornerRadius(8)
              .padding(2)
              .opacity(0.8)
          }
        }
        .padding(.top)
      }
    }
    .padding()
    .navigationTitle("Topics Chooser")
    .navigationBarTitleDisplayMode(.large)
  }
}
//        .onAppear {
//           // loadPersistentData()
//          print("//TopicsChooserScreen onAppear Topics: \(selectedTopics)")
//        }
//        .onDisappear{
//          print("//TopicsChooserScreen onDisappear Topics: \(selectedTopics)")
//        }
//        .onChange(of: selectedTopics) { _, newValue in
//            print("//TopicsChooserScreen onChange Topics: \(newValue)")
//        }
//        .onChange(of: colorPalette) { oldValue, newValue in
//          MockTopics.shared.saveSchemeIndex(newValue)
//        }




//    private func loadPersistentData() {
//        selectedTopics = MockTopics.shared.loadTopics()
//        selectedSchemeIndex = MockTopics.shared.loadSchemeIndex()
//    }

//#Preview ("TopicsChooserScreen") {
//  @Previewable @State var selectedTopics: [String] = []
//  TopicsChooserScreen(allTopics: MockTopics.mockTopics, schemes: AppColors.allSchemes, boardSize: 3, selectedTopics: $selectedTopics)
//}

