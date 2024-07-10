//
//  TopicColorizer.swift
//  basic
//
//  Created by bill donner on 7/9/24.
//

import SwiftUI
import UniformTypeIdentifiers

/// A view for arranging selected topics with a selected color scheme.
struct TopicColorizerView: View {
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
    @Previewable @State  var selectedSchemeIndex = 0
    TopicColorizerView(topics: .constant(["Topic 1", "Topic 2", "Topic 3"]), selectedSchemeIndex: $selectedSchemeIndex, schemes: AppColors.allSchemes )

  
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

