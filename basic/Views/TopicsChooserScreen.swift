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
    let boardSize: Int
    @Binding var selectedTopics: [String]
    @State private var selectedSchemeIndex = 1 // Initial scheme index set to Summer
  @EnvironmentObject var gameBoard: GameBoard

    var body: some View {
        VStack(alignment: .leading) {
          VStack {
            Text("If you want to change the topics, that's okay but you will end your game. If you just want to change colors or ordering, you should use 'Arrange Topics'.")
              .font(.body)
              .padding(.bottom)
            Text("At board size \(boardSize) you can add \(GameBoard.maxTopicsForBoardSize(boardSize) - selectedTopics.count) more topics")
              .font(.subheadline)
            
            HStack {
              NavigationLink(destination: TopicSelectorView(allTopics: allTopics, selectedTopics: $selectedTopics, selectedSchemeIndex: $selectedSchemeIndex, boardSize: boardSize)) {
                Text("Select Topics")
              }
              
              NavigationLink(destination: TopicColorizerView(topics: $selectedTopics, selectedSchemeIndex: $selectedSchemeIndex, schemes: schemes)) {
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
                        let colorInfo = schemes[selectedSchemeIndex].mappedColors()[index % schemes[selectedSchemeIndex].colors.count]
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
        .onAppear {
            loadPersistentData()
        }
        .onChange(of: selectedTopics) { oldValue, newValue in
            MockTopics.shared.saveTopics(newValue)
        }
        .onChange(of: selectedSchemeIndex) { oldValue, newValue in
          MockTopics.shared.saveSchemeIndex(newValue)
        }
    }



    private func loadPersistentData() {
        selectedTopics = MockTopics.shared.loadTopics()
        selectedSchemeIndex = MockTopics.shared.loadSchemeIndex()
    }
}
#Preview ("TopicsChooserScreen") {
  @Previewable @State var selectedTopics: [String] = []
  TopicsChooserScreen(allTopics: MockTopics.mockTopics, schemes: AppColors.allSchemes, boardSize: 3, selectedTopics: $selectedTopics)
}

