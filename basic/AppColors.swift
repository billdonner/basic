//
//  AppColors.swift
//  basic
//
//  Created by bill donner on 6/23/24.
//

import SwiftUI
//Must be Observable , not a static struct else
//Generic struct 'EnvironmentObject' requires that 'AppColors' conform to 'ObservableObject'
@Observable class
 AppColors   : ObservableObject{
  
  struct ColorForTopic: Codable {
      let topic: String
      let foregroundColor: Color
      let backgroundColor: Color
      
      init(topic: String, foregroundColor: Color, backgroundColor: Color) {
          self.topic = topic
          self.foregroundColor = foregroundColor
          self.backgroundColor = backgroundColor
      }
    
    static let zero =
      ColorForTopic(topic:".default",foregroundColor: .black,backgroundColor: .white)
  }
  static let  pallettes: [String: [ColorForTopic]] = [
    "Pastel": [
      ColorForTopic(topic: "Actors", foregroundColor: .white, backgroundColor: .blue),
      ColorForTopic(topic: "Animals", foregroundColor: .black, backgroundColor: .purple),
      ColorForTopic(topic: "Cars", foregroundColor: .yellow, backgroundColor: .indigo),
      ColorForTopic(topic: ".default", foregroundColor: .white, backgroundColor: .blue),
    ],
    "Bold": [
      ColorForTopic(topic: "Actors", foregroundColor: .white, backgroundColor: .orange),
      ColorForTopic(topic: "Animals", foregroundColor: .black, backgroundColor: .cyan),
      ColorForTopic(topic: "Cars", foregroundColor: .yellow, backgroundColor: .blue),
    ],
    "Fun": [
      ColorForTopic(topic: "Actors", foregroundColor: .white, backgroundColor: .gray),
      ColorForTopic(topic: "Animals", foregroundColor: .black, backgroundColor: .yellow),
      ColorForTopic(topic: "Cars", foregroundColor: .yellow, backgroundColor: .white),
    ],
    ".default":[
      ColorForTopic(topic: ".default1", foregroundColor: .white, backgroundColor: .blue),
      ColorForTopic(topic: ".default2", foregroundColor: .white, backgroundColor: .orange),
      ColorForTopic(topic: ".default3", foregroundColor: .white, backgroundColor: .cyan),
      ColorForTopic(topic: ".default4", foregroundColor: .white, backgroundColor: .black),
    ]
  ]
  
  
  
  static func colorFor(topic: String) -> ColorForTopic? {
    @AppStorage("currentPallette") var currentPallette = "Bold"
    guard let tp = pallettes[currentPallette] else { return nil }
    //look for topic
    return tp.first(where:{$0.topic == topic})
  }
}
