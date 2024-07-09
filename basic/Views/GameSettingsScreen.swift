import SwiftUI


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
  
  fileprivate func onParameterChange() {
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
      { _,newSize in
        selectedTopics = MockTopics.shared.getRandomTopics(newSize - 1, from: MockTopics.mockTopics)
        onParameterChange()
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
      { _,_ in onParameterChange() }
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
      { _,_ in onParameterChange() }
      Section(header: Text("Cards Face")) {
        HStack {
          Text("Face Down")
          Spacer()
          Toggle("", isOn: $l_faceUpCards)
            .labelsHidden()
          Spacer()
          Text("Face Up")
        }
        .frame(maxWidth: .infinity)
      }
      .onChange(of: l_faceUpCards, initial: false)
      { _,_ in onParameterChange() }
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
      { _,_ in onParameterChange() }
      Section(header: Text("Color Palette")) {
        Picker("Color Palette", selection: $l_colorPalette) {
//          Text("Spring").tag(1)
//          Text("Summer").tag(2)
//          Text("Autumn").tag(3)
//          Text("Winter").tag(4)
//          Text("Bleak").tag(5)
          ForEach(AppColors.allSchemes.indices,id:\.self) { idx in
            Text(AppColors.allSchemes[idx].name)
              .tag(idx + 1)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(colorPaletteBackground.clipShape(RoundedRectangle(cornerRadius: 10)))
      }.onChange(of: l_colorPalette, initial: false)
      { _,_ in onParameterChange() }
      Section(header: Text("Topics")) {
        NavigationLink(destination: TopicsChooserScreen(allTopics: MockTopics.mockTopics, schemes: AppColors.allSchemes, boardSize: boardSize, selectedTopics: $selectedTopics)) {
          Text("Choose Topics")
            .padding()
          //                    .background(Color.blue)
            .foregroundColor(.blue)
          //                    .cornerRadius(10)
        }
      }
      .onAppear {  // fix
        selectedTopics = MockTopics.shared.getRandomTopics(boardSize - 1, from: MockTopics.mockTopics)
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
        onNewGamePressed()
      }
    )
    //}
  }
  private func onNewGamePressed() {
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
    //, topics: returningTopics)
    self.presentationMode.wrappedValue.dismiss()
    print("-----> NEW GAME \(boardSize)x\(boardSize) topics:\(returningTopics.joined(separator: ",")) ")
  }
  private func replaceTopic(at index: Int) {
    guard !tappedIndices.contains(index), !availableTopics.isEmpty else { return }
    let newTopic = availableTopics.removeFirst()
    replacedTopics[index] = selectedTopics[index]
    selectedTopics[index] = newTopic
    tappedIndices.insert(index)
  }
  
  //  private func selectAdditionalTopic(_ topic: String) {
  //    if selectedAdditionalTopics.contains(topic) {
  //      selectedAdditionalTopics.remove(topic)
  //    } else if selectedAdditionalTopics.count < boardSize {
  //      selectedAdditionalTopics.insert(topic)
  //    }
  //  }
  
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
  @EnvironmentObject var gameBoard: GameBoard
  
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
          onChangeOfReturningTopics()
        }
    }
  }
  
  private func onChangeOfReturningTopics() {
    //set only the returning topics to isLive
    func qq(_ x:[String],contains y:String)->Bool {
      for z in x {
        if y==z {return true}
      }
      return false
    }
    // this is questionable
    //               for t in 0..<gameState.topics.count {
    //                    gameState.topics[t].isLive = qq(returningTopics,contains:gameState.topics[t].topic)
    //                  }
  }
  
}
#Preview("Tester") {
  let t  = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
  GameSettingsScreen(ourTopics: t) {
    print("GameSettingsExited with")
  }
}
