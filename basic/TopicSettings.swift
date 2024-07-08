//
//  TopicSettings.swift
//  tpicker3
//
//  Created by bill donner on 7/8/24.
//

import SwiftUI
import UniformTypeIdentifiers


/// The view for selecting and arranging topics.
struct TopicsChooserScreen: View {
    let allTopics: [String]
    let schemes: [ColorScheme]
    let boardSize: Int
    @Binding var selectedTopics: [String]
    @State private var selectedSchemeIndex = 1 // Initial scheme index set to Summer

    var body: some View {
        VStack(alignment: .leading) {
          VStack {
            Text("If you want to change the topics, that's okay but you will end your game. If you just want to change colors or ordering, you should use 'Arrange Topics'.")
              .font(.body)
              .padding(.bottom)
            
            Text("You can  add \(maxTopicsForBoardSize - selectedTopics.count)")
              .font(.subheadline)
            
            HStack {
              NavigationLink(destination: TopicSelectorView(allTopics: allTopics, selectedTopics: $selectedTopics, selectedSchemeIndex: $selectedSchemeIndex, maxTopics: maxTopicsForBoardSize, boardSize: boardSize)) {
                Text("Select Topics")
              }
              
              NavigationLink(destination: ArrangerView(topics: $selectedTopics, selectedSchemeIndex: $selectedSchemeIndex, schemes: schemes)) {
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
            TopicProvider.shared.saveTopics(newValue)
        }
        .onChange(of: selectedSchemeIndex) { oldValue, newValue in
            TopicProvider.shared.saveSchemeIndex(newValue)
        }
    }

    private var maxTopicsForBoardSize: Int {
        switch boardSize {
        case 3: return 7
        case 4: return 8
        case 5: return 9
        case 6: return 10
        default: return 7
        }
    }

    private func loadPersistentData() {
        selectedTopics = TopicProvider.shared.loadTopics()
        selectedSchemeIndex = TopicProvider.shared.loadSchemeIndex()
    }
}
#Preview ("TopicsChooserScreen") {

  TopicsChooserScreen(allTopics: mockTopics, schemes: allSchemes, boardSize: 3, selectedTopics: .constant([]))
}
/// A view for selecting topics from the full list.
private struct TopicSelectorView: View {
    let allTopics: [String]
    @Binding var selectedTopics: [String]
    @Binding var selectedSchemeIndex: Int
    let maxTopics: Int
    let boardSize: Int
    @State private var searchText = ""
    @State private var rerolledTopics: [String: String] = [:]  // Dictionary to keep track of rerolled topics

    var body: some View {
        VStack {
          Text("With a board size of \(boardSize) you can select \(maxTopics) topics.")
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
  TopicSelectorView(allTopics: mockTopics, selectedTopics: .constant([]), selectedSchemeIndex: .constant(0), maxTopics: 100, boardSize: 3)
}


/// A view for arranging selected topics with a selected color scheme.
private struct ArrangerView: View {
  @Environment(\.presentationMode) var presentationMode
  @Binding var topics: [String]
  @Binding var selectedSchemeIndex: Int // Binding to reflect changes back to TopicsChooserScreen
  let schemes: [ColorScheme]

  var body: some View {
      VStack {
          HStack {
              Text("Select a Color Scheme")
                  .font(.title2)
                  .padding(.top)

              Spacer()
          }
          .padding([.leading, .trailing, .top])

          Text("Drag and drop the topics to change their colors.")
              .padding(.bottom)

          Picker("Color Schemes", selection: $selectedSchemeIndex) {
              ForEach(0..<schemes.count, id: \.self) { index in
                  Text(schemes[index].name)
              }
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding()

          ScrollView {
              LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                  ForEach(0..<12, id: \.self) { index in
                      let colorInfo = schemes[selectedSchemeIndex].mappedColors()[index]
                      if index < topics.count {
                          let topic = topics[index]
                          Text(topic)
                              .padding()
                              .background(colorInfo.0)
                              .foregroundColor(colorInfo.1)
                              .cornerRadius(8)
                              .onDrag { NSItemProvider(object: NSString(string: topic)) }
                              .onDrop(of: [UTType.text], delegate: TopicDropDelegate(topic: (id: UUID(), name: topic, schemeIndex: selectedSchemeIndex), topics: $topics, fromIndex: index))
                      } else {
                          Text(" ")
                              .padding()
                              .background(colorInfo.0)
                              .foregroundColor(colorInfo.1)
                              .cornerRadius(8)
                              .onDrop(of: [UTType.text], delegate: TopicDropDelegate(topic: (id: UUID(), name: " ", schemeIndex: selectedSchemeIndex), topics: $topics, fromIndex: index))
                      }
                  }
              }
              .padding()
          }
      }
      .navigationBarTitle("", displayMode: .inline)
  }
}
#Preview("ArrangerView") {
  ArrangerView(topics: .constant(["Topic 1", "Topic 2", "Topic 3"]), selectedSchemeIndex: .constant(2), schemes: allSchemes )
}

/// Drop delegate for handling drag and drop of topics.
struct TopicDropDelegate: DropDelegate {
  let topic: (id: UUID, name: String, schemeIndex: Int)
  @Binding var topics: [String]
  let fromIndex: Int

  func performDrop(info: DropInfo) -> Bool {
      guard let item = info.itemProviders(for: [UTType.text]).first else {
          return false
      }

      item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
          DispatchQueue.main.async {
              if let data = data as? Data, let text = String(data: data, encoding: .utf8) {
                  guard let fromIndex = topics.firstIndex(of: text) else { return }
                  let fromTopic = topics.remove(at: fromIndex)
                  let toIndex = topics.firstIndex(of: topic.name) ?? topics.endIndex
                  topics.insert(fromTopic, at: toIndex)
              }
          }
      }
      return true
  }
}

