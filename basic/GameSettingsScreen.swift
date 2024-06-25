import SwiftUI

fileprivate struct TopicsView: View {
  @State private var selectedTopics: [String] = []
  @State private var currentTopics: [String]
  @State private var remainingTopics: [String]
  @State private var changedIndices: Set<Int> = []
  @Binding var boardSize: Int

  init(topics: [String], allTopics: [String], boardSize: Binding<Int>) {
    _currentTopics = State(initialValue: topics.dropLast(5))
    _remainingTopics = State(initialValue: allTopics.filter { !topics.contains($0) })
    _boardSize = boardSize
  }

  var body: some View {
    let ctopics = currentTopics.dropLast(1)
    VStack(alignment: .leading) {
      Text("current: \(ctopics.count)")
      List(ctopics.indices, id: \.self) { index in
        Text("\(index + 1). \(ctopics[index])")
          .onTapGesture {
            if !changedIndices.contains(index) {
              changeTopic(at: index)
            }
          }
          .foregroundColor(changedIndices.contains(index) ? .gray : .primary)
          .disabled(changedIndices.contains(index)) // Indicate non-tappable state
      }
      
      Text("Tap to change each topic once \(boardSize)")
        .font(.footnote)
        .padding(.horizontal)
    }
    .padding(.horizontal)
  }

  private func changeTopic(at index: Int) {
    guard !remainingTopics.isEmpty else {
      print("No more unused topics available.")
      return
    }

    if let newTopic = remainingTopics.randomElement(),
       let newTopicIndex = remainingTopics.firstIndex(of: newTopic) {
      currentTopics[index] = newTopic
      remainingTopics.remove(at: newTopicIndex)
      changedIndices.insert(index)
    }
  }
}

func chooseTopics(from topics: [String], count N: Int) -> [String] {
  guard N > 0 else {
    return []
  }

  if N >= topics.count {
    return topics
  }

  var chosenTopics: Set<String> = []
  while chosenTopics.count < N {
    if let topic = topics.randomElement() {
      chosenTopics.insert(topic)
    }
  }

  return Array(chosenTopics)
}

fileprivate struct GameSettingsView: View {
  internal init(boardSize: Binding<Int>, startInCorners: Binding<Bool>, faceUpCards: Binding<Bool>, doubleDiag: Binding<Bool>, colorPalette: Binding<Int>, difficultyLevel: Binding<Int>,
             //   topTopics: String,bottomTopics:String,
                ourTopics: [String], returningTopics:Binding<[String]>,
                onExit:@escaping ()->()) {
    self.onExit = onExit
    _boardSize = boardSize
    _startInCorners = startInCorners
    _faceUpCards = faceUpCards
    _doubleDiag = doubleDiag
    _colorPalette = colorPalette
    _difficultyLevel = difficultyLevel
    _returningTopics = returningTopics
    
    self.ourTopics = ourTopics
    let randomTopics = ourTopics.shuffled()
    let chosenTopics = Array(randomTopics.prefix(boardSize.wrappedValue - 2))
    let remainingTopics = Array(randomTopics.dropFirst(boardSize.wrappedValue - 2))
    _selectedTopics = State(initialValue: chosenTopics)
    _availableTopics = State(initialValue: remainingTopics)
    
    l_boardSize = boardSize.wrappedValue
    l_doubleDiag = doubleDiag.wrappedValue
    l_colorPalette = colorPalette.wrappedValue
    l_difficultyLevel = difficultyLevel.wrappedValue
    l_faceUpCards = faceUpCards.wrappedValue
    l_startInCorners = startInCorners.wrappedValue
    
    
  }
  var onExit: ()->()

  
  @Binding var boardSize: Int
  @Binding var startInCorners: Bool
  @Binding var faceUpCards: Bool
  @Binding var doubleDiag: Bool
  @Binding var colorPalette: Int
  @Binding var difficultyLevel: Int
  
  
  
 
  @Binding var returningTopics: [String]
  
  @State private var  l_boardSize: Int
  @State private var  l_startInCorners: Bool
  @State private var  l_faceUpCards: Bool
  @State private var  l_doubleDiag: Bool
  @State private var  l_colorPalette: Int
  @State private var  l_difficultyLevel: Int
  
  @State var selectedTopics: [String]
  @State var availableTopics: [String]
  @State var tappedIndices: Set<Int> = []
  @State var replacedTopics: [Int: String] = [:]
  @State var selectedAdditionalTopics: Set<String> = []
 
  var ourTopics: [String]
  @State private var showSettings = false

  @Environment(\.presentationMode) var presentationMode
  
  

  var colorPaletteBackground: LinearGradient {
    switch l_colorPalette {
    case 1:
      return LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case 2:
      return LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case 3:
      return LinearGradient(gradient: Gradient(colors: [Color.brown, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case 4:
      return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
    default:
      return LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
  }

  fileprivate func paintBoard() {
    refreshTopics()
//    startNewGame
//    let x=try?  prepareNewGame(aiPlayData!, reloadTopics:false)
//    if x != nil
//    {
//      print(" painting new Board")
//    }
  }
  
  var body: some View {
      
      Form {
        Section(header: Text("Board Size")) {
          Picker("Board Size", selection: $l_boardSize) {
            Text("3x3").tag(3)
            Text("4x4").tag(4)
            Text("5x5").tag(5)
            Text("6x6").tag(6)
          }
          .pickerStyle(SegmentedPickerStyle())
      

        }
        .onChange(of: l_boardSize, initial: false)
         { _,_ in
           paintBoard()
        }
        Section(header: Text("Difficulty Level")) {
          Picker("Difficulty Level", selection: $l_difficultyLevel) {
            Text("Easy").tag(1)
            Text("Normal").tag(2)
            Text("Hard").tag(3)
          }
          .pickerStyle(SegmentedPickerStyle())
          .background(Color(.systemBackground).clipShape(RoundedRectangle(cornerRadius: 10)))
        }
        .onChange(of: l_difficultyLevel, initial: false)
         { _,_ in
           paintBoard()
        }
        Section(header: Text("Starting Position")) {
          HStack {
            Text("Anywhere")
            Spacer()
            Toggle("", isOn: $l_startInCorners)
              .labelsHidden()
            Spacer()
            Text("Corners")
          }
          .frame(maxWidth: .infinity)
        }
        .onChange(of: l_startInCorners, initial: false)
        { _,_ in
          paintBoard()
       }
        
        Section(header: Text("Cards Face")) {
          HStack {
            Text("Face Down")
            Spacer()
            Toggle("", isOn: $l_faceUpCards)
              .labelsHidden()
            Spacer()
            Text("Face UP")
          }
          .frame(maxWidth: .infinity)
        }
        .onChange(of: l_faceUpCards, initial: false)
        { _,_ in
          paintBoard()
       }
        
        
        Section(header: Text("Double Diag")) {
          HStack {
            Text("One Diag")
            Spacer()
            Toggle("", isOn: $l_doubleDiag)
              .labelsHidden()
            Spacer()
            Text("Both Diags")
          }
          .frame(maxWidth: .infinity)
        }
        .onChange(of: l_doubleDiag, initial: false)
        { _,_ in
          paintBoard()
       }
        Section(header: Text("Color Palette")) {
          Picker("Color Palette", selection: $l_colorPalette) {
            Text("Spring").tag(1)
            Text("Summer").tag(2)
            Text("Autumn").tag(3)
            Text("Winter").tag(4)
          }
          .pickerStyle(SegmentedPickerStyle())
          .background(colorPaletteBackground.clipShape(RoundedRectangle(cornerRadius: 10)))
        }         .
        onChange(of: l_colorPalette, initial: false)
        { _,_ in
          paintBoard()
       }
        
        Section(header: Text("We Pre-Selected \($l_boardSize.wrappedValue - 2) Topics"), footer: Text("Click to change any of the pre-selected topics, but only once!")) {
          ForEach(selectedTopics.indices, id: \.self) { index in
            HStack {
              Text(selectedTopics[index])
              if let oldTopic = replacedTopics[index] {
                Text(" (\(oldTopic))")
                  .opacity(0.5)
              }
            }
            .onTapGesture {
              replaceTopic(at: index)
            }
          }
        }
        
        Section(header: Text("Choose Up To \($l_boardSize.wrappedValue) Additional Topics"), footer: Text("Pick at least \($l_boardSize.wrappedValue - 2) ")) {
          ForEach(availableTopics, id: \.self) { topic in
            HStack {
              Text(topic)
              Spacer()
              if selectedAdditionalTopics.contains(topic) {
                Image(systemName: "checkmark")
              }
            }
            .onTapGesture {
              selectAdditionalTopic(topic)
            }
          }
        }
        
        Section(header:Text("About QANDA")) {
          VStack{
            HStack { Spacer()
              AppVersionInformationView(
                name:AppNameProvider.appName(),
                versionString: AppVersionProvider.appVersion(),
                appIcon: AppIconProvider.appIcon()
              )
              Spacer()
            }
            //Text(PRIMARY_REMOTE).font(.caption)
              .onChange(of:returningTopics,initial:true ) { old,newer in
              print("Game With Topics:",returningTopics.joined())
              }
            
            Button(action: { showSettings.toggle() }) {
              Text("Freeport Settings")
            }
          }
        }
      }
      .sheet(isPresented:$showSettings){
        FreeportSettingsScreen()
      }
      .onDisappear {
        onExit() // do whatever
      }
      .navigationBarTitle("Game Settings", displayMode: .inline)
      .navigationBarItems(
        leading: Button("Cancel") {
          // dont touch anything
          self.presentationMode.wrappedValue.dismiss()
        },
        trailing: Button("New Game") {
          // copy every change into appsettings , except topics
          doubleDiag = l_doubleDiag
          faceUpCards = l_faceUpCards
          boardSize = l_boardSize
          colorPalette = l_colorPalette
          difficultyLevel = l_difficultyLevel
          startInCorners = l_startInCorners
          returningTopics = selectedTopics + selectedAdditionalTopics
          //exx(0)
         // startNewGame(size: l_boardSize
                     //  , topics: returningTopics)
          self.presentationMode.wrappedValue.dismiss()
        }
      )
    //}
  }
  
  private func replaceTopic(at index: Int) {
    guard !tappedIndices.contains(index), !availableTopics.isEmpty else { return }
    let newTopic = availableTopics.removeFirst()
    replacedTopics[index] = selectedTopics[index]
    selectedTopics[index] = newTopic
    tappedIndices.insert(index)
  }

  private func selectAdditionalTopic(_ topic: String) {
    if selectedAdditionalTopics.contains(topic) {
      selectedAdditionalTopics.remove(topic)
    } else if selectedAdditionalTopics.count < boardSize {
      selectedAdditionalTopics.insert(topic)
    }
  }
  
  private func refreshTopics() {
    let randomTopics = ourTopics.shuffled()
    selectedTopics = Array(randomTopics.prefix(boardSize - 2))
    availableTopics = Array(randomTopics.dropFirst(boardSize - 2))
    tappedIndices.removeAll()
    replacedTopics.removeAll()
    selectedAdditionalTopics.removeAll()
  }
}

struct GameSettingsScreen :
  View {
  let ourTopics:[String]
  let onExit: ()->()
  @AppStorage("moveNumber") var moveNumber = 0
  @AppStorage("boardSize") private var boardSize = 6
  @AppStorage("startInCorners") private var startInCorners = false
  @AppStorage("faceUpCards") private var faceUpCards = false
  @AppStorage("doubleDiag") private var doubleDiag = false
  @AppStorage("colorPalette") private var colorPalette = 1
  @AppStorage("difficultyLevel") private var difficultyLevel = 1

  @State var returningTopics: [String] = []
  
  var body: some View {
    NavigationView  {
      GameSettingsView(
        boardSize: $boardSize,
        startInCorners: $startInCorners,
        faceUpCards: $faceUpCards,
        doubleDiag: $doubleDiag,
        colorPalette: $colorPalette,
        difficultyLevel: $difficultyLevel,
        ourTopics:  ourTopics,
        returningTopics: $returningTopics){
          onExit()
          
        }
      .onChange(of: returningTopics,initial:true ) {_,_ in
        //set only the returning topics to isLive
        func qq(_ x:[String],contains y:String)->Bool {
          for z in x {
            if y==z {return true}
          }
          return false
        }
//        for t in 0..<gameState.topics.count {
//          gameState.topics[t].isLive = qq(returningTopics,contains:gameState.topics[t].topic)
//        }
      }
    }
  }
}
#Preview("Tester") {
  let t  = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
  GameSettingsScreen(ourTopics: t) {
    print("GameSettingsExited with")
  }
}
