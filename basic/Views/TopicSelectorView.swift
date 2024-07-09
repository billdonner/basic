//
//  TopicSelectorView.swift
//  basic
//
//  Created by bill donner on 7/9/24.
//
import SwiftUI
/// A view for selecting topics from the full list.
 struct TopicSelectorView: View {
    let allTopics: [String]
    @Binding var selectedTopics: [String]
    @Binding var selectedSchemeIndex: Int

    let boardSize: Int
    @State private var searchText = ""
    @State private var rerolledTopics: [String: String] = [:]  // Dictionary to keep track of rerolled topics

    var body: some View {
      let maxTopics =  GameBoard.maxTopicsForBoardSize(boardSize)
        VStack {
          Text("board size:\(boardSize) you can select \(maxTopics) topics.")
            Text("You can select \(maxTopics - selectedTopics.count) more topics.")
                .font(.subheadline)
                .padding(.bottom)

            List {
                Section(header: Text("Pre-selected Topics")) {
                    ForEach(selectedTopics.prefix(boardSize - 1), id: \.self) { topic in
                        HStack {
                            Text(topic)
                            Spacer()
                            if let previousTopic = rerolledTopics[topic] {
                                Text(previousTopic)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            } else {
                                Button(action: {
                                    if let newTopic = allTopics.filter({ !selectedTopics.contains($0) }).randomElement() {
                                        if let index = selectedTopics.firstIndex(of: topic) {
                                            selectedTopics[index] = newTopic
                                            rerolledTopics[newTopic] = topic
                                        }
                                    }
                                }) {
                                    Text("reroll?")
                                        .font(.footnote)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Selected Topics")) {
                    ForEach(selectedTopics.dropFirst(boardSize - 1), id: \.self) { topic in
                        Button(action: {
                            if selectedTopics.contains(topic) {
                                selectedTopics.removeAll { $0 == topic }
                            }
                        }) {
                            HStack {
                                Text(topic)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                Section(header: Text("All Topics")) {
                    ForEach(filteredTopics, id: \.self) { topic in
                        Button(action: {
                            if !selectedTopics.contains(topic) && selectedTopics.count < maxTopics {
                                selectedTopics.append(topic)
                            }
                        }) {
                            HStack {
                                Text(topic)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Topics")
            .searchable(text: $searchText, prompt: "Search Topics")
        }
    }

    var filteredTopics: [String] {
        if searchText.isEmpty {
            return allTopics.filter { !selectedTopics.contains($0) }
        } else {
            return allTopics.filter { $0.localizedCaseInsensitiveContains(searchText) && !selectedTopics.contains($0) }
        }
    }
}
#Preview ("TopicSelectorView"){
  @Previewable @State var selectedTopics:[String] = ["Science","History"]
  @Previewable @State var selectedSchemeIndex: Int = 0
  TopicSelectorView(allTopics: MockTopics.mockTopics, selectedTopics: $selectedTopics , selectedSchemeIndex: $selectedSchemeIndex,boardSize: 3)
}
