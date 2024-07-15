import SwiftUI


fileprivate struct GameSettingsView: View {
 
let onExit: ([String])->()
@Bindable var chmgr:ChaMan
@Bindable var gameBoard:GameBoard
let ourTopics: [String]

@Binding var boardSize: Int
@Binding var startInCorners: Bool
@Binding var faceUpCards: Bool
@Binding var doubleDiag: Bool
@Binding var currentScheme: Int
@Binding var difficultyLevel: Int
@Binding var returningTopics:  [String]
  
  
  internal init(chmgr:ChaMan,gameBoard:GameBoard, boardSize: Binding<Int>, startInCorners: Binding<Bool>, faceUpCards: Binding<Bool>, doubleDiag: Binding<Bool>, currentScheme: Binding<Int>, difficultyLevel: Binding<Int>,
                ourTopics: [String],
                returningTopics:Binding<[String]>,
                onExit:@escaping ([String])->()) {
    self.onExit = onExit
    self.gameBoard = gameBoard
    _boardSize = boardSize
    _startInCorners = startInCorners
    _faceUpCards = faceUpCards
    _doubleDiag = doubleDiag
    _currentScheme = currentScheme
    _difficultyLevel = difficultyLevel
    _returningTopics = returningTopics
    self.chmgr = chmgr
    self.ourTopics = ourTopics
    let randomTopics = ourTopics.shuffled()
    let chosenTopics = Array(randomTopics.prefix(boardSize.wrappedValue - 2))
    let remainingTopics = Array(randomTopics.dropFirst(boardSize.wrappedValue - 2))
    _selectedTopics = State(initialValue: chosenTopics)
    _availableTopics = State(initialValue: remainingTopics)
    
    l_boardSize = boardSize.wrappedValue
    l_doubleDiag = doubleDiag.wrappedValue
    l_currentScheme = currentScheme.wrappedValue
    l_difficultyLevel = difficultyLevel.wrappedValue
    l_faceUpCards = faceUpCards.wrappedValue
    l_startInCorners = startInCorners.wrappedValue
    l_returningTopics = returningTopics.wrappedValue
    l_selectedTopics = chosenTopics
  }
  
  @State private var  l_boardSize: Int
  @State private var  l_startInCorners: Bool
  @State private var  l_faceUpCards: Bool
  @State private var  l_doubleDiag: Bool
  @State private var  l_currentScheme: Int
  @State private var  l_difficultyLevel: Int
  @State private var  l_returningTopics: [String]
  @State private var  l_selectedTopics: [String]
  
  @State var selectedTopics: [String]
  @State var availableTopics: [String]
  @State var tappedIndices: Set<Int> = []
  @State var replacedTopics: [Int: String] = [:]
  @State var selectedAdditionalTopics: Set<String> = []
  @State var firstOnAppear = true
  
  @State private var showSettings = false
  @Environment(\.presentationMode) var presentationMode
  
  var colorPaletteBackground: LinearGradient {
    switch l_currentScheme {
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
    //// wrong refreshTopics()
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
     // .onChange(of: l_boardSize, initial: false)
     // { _,newSize in
    //    onParameterChange()
    //  }
      Section(header: Text("Difficulty Level")) {
        Picker("Difficulty Level", selection: $l_difficultyLevel) {
          Text("Easy").tag(1)
          Text("Normal").tag(2)
          Text("Hard").tag(3)
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(Color(.systemBackground).clipShape(RoundedRectangle(cornerRadius: 10)))
      }
     // .onChange(of: l_difficultyLevel, initial: false)
     // { _,_ in onParameterChange() }
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
     // .onChange(of: l_startInCorners, initial: false)
     // { _,_ in onParameterChange() }
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
     // .onChange(of: l_faceUpCards, initial: false )
     // { _,_ in onParameterChange() }
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
      //.onChange(of: l_doubleDiag, initial: false)
     // { _,_ in onParameterChange() }
      Section(header: Text("Color Palette")) {
        Picker("Color Palette", selection: $l_currentScheme) {
          ForEach(AppColors.allSchemes.indices,id:\.self) { idx in
            Text(AppColors.allSchemes[idx].name)
              .tag(idx + 1)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(colorPaletteBackground.clipShape(RoundedRectangle(cornerRadius: 10)))
      }
      //.onChange(of: l_colorPalette, initial: false)
      //{ _,_ in onParameterChange() }
      
      Section(header: Text("Topics")) {
        NavigationLink(destination: TopicsChooserScreen(allTopics: chmgr.allTopics, schemes: AppColors.allSchemes, boardSize: boardSize, selectedTopics: $l_selectedTopics)) {
          Text("Choose Topics")
            .padding()
            .foregroundColor(.blue)
        }
      }
      .onAppear {
        if firstOnAppear {
          //selectedTopics = getRandomTopics(boardSize - 1, from: chmgr.allTopics)
          firstOnAppear = false
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
          .onChange(of:selectedTopics,initial:true ) { old,newer in
            print("Game With Topics:",selectedTopics.joined(separator: ","))
          }
          
          Button(action: { showSettings.toggle() }) {
            Text("Freeport Settings")
          }
        }
      }
    }
    .sheet(isPresented:$showSettings){
      FreeportSettingsScreen(gameBoard: gameBoard, chmgr: chmgr)
    }
    .onDisappear {
      onExit(selectedTopics) // do whatever
    }
    .navigationBarTitle("Game Settings", displayMode: .inline)
    .navigationBarItems(
      leading: Button("Cancel") {
        // dont touch anything
          print("//GameSettingsScreen Cancel Pressed topics: \(selectedTopics)")
        self.presentationMode.wrappedValue.dismiss()
      },
      trailing: Button("Done") {
        print("//GameSettingsScreen Done Pressed ")
        
        onDonePressed()
        dumpAppStorage()
        gameBoard.dumpGameBoard()
        
        self.presentationMode.wrappedValue.dismiss()
      }
    )
    //}
  }
  private func onDonePressed() {
    // copy every change into appsettings , except topics
    doubleDiag = l_doubleDiag
    faceUpCards = l_faceUpCards
    boardSize = l_boardSize
    currentScheme = l_currentScheme
    difficultyLevel = l_difficultyLevel
    startInCorners = l_startInCorners
    selectedTopics = l_selectedTopics //selectedTopics +
    gameBoard.size = l_boardSize
    gameBoard.topicsinplay = l_selectedTopics // //*****2
    print( "//*****2")
  }
  private func replaceTopic(at index: Int) {
    guard !tappedIndices.contains(index), !availableTopics.isEmpty else { return }
    let newTopic = availableTopics.removeFirst()
    replacedTopics[index] = l_selectedTopics[index]
    l_selectedTopics[index] = newTopic
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
    l_selectedTopics = Array(randomTopics.prefix(boardSize - 2))
    availableTopics = Array(randomTopics.dropFirst(boardSize - 2))
    tappedIndices.removeAll()
    replacedTopics.removeAll()
    selectedAdditionalTopics.removeAll()
  }
}

struct GameSettingsScreen :
  View {
  @Bindable var chmgr: ChaMan
  @Bindable var gameBoard: GameBoard
  let ourTopics:[String]
  let onExit: ([String])->()
  @AppStorage("gameNumber") var gameNumber = 1
  @AppStorage("moveNumber") var moveNumber = 0
  @AppStorage("boardSize") private var boardSize = 6
  @AppStorage("startInCorners") private var startInCorners = false
  @AppStorage("faceUpCards") private var faceUpCards = true
  @AppStorage("doubleDiag") private var doubleDiag = false
  @AppStorage("currentScheme") var currentScheme = 1
  @AppStorage("difficultyLevel") private var difficultyLevel = 1
  @AppStorage("selectedTopicsPiped") var selectedTopicsPiped:String  = ""
  
  
  @State private var returningTopics:[String] = []
  var body: some View {
    NavigationView  {
      GameSettingsView(
        chmgr: chmgr,
        gameBoard:gameBoard,
        boardSize: $boardSize,
        startInCorners: $startInCorners,
        faceUpCards: $faceUpCards,
        doubleDiag: $doubleDiag,
        currentScheme:$currentScheme,
        difficultyLevel: $difficultyLevel,
        ourTopics:  ourTopics,
        returningTopics: $returningTopics, 
        onExit: onExit
      )
      .onChange(of: returningTopics ,initial:true ) {_,_ in
        print("//GameSettingsScreen OnChange  topics: \(returningTopics)")
        onChangeOfReturningTopics()
      }
    }
  }
  
  private func onChangeOfReturningTopics() {
    selectedTopicsPiped = returningTopics.map({$0}).joined(separator: "|")
    gameBoard.topicsinplay = returningTopics //*****3
    print("//*****3")
  }
}
#Preview("Tester") {
  let t  = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
  GameSettingsScreen(chmgr: ChaMan(playData: PlayData.mock), gameBoard: GameBoard(size: starting_size, topics: Array(MockTopics.mockTopics.prefix(starting_size)),  challenges:Challenge.mockChallenges), ourTopics: t) {  strings in     
    print("GameSettingsExited with \(t)")
  }
}
