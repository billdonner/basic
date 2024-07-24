import SwiftUI

fileprivate struct GameSettingsView: View {
  
  let onExit: ([String])->()
  @Bindable var chmgr:ChaMan
  @Bindable var gs:GameState
  
  internal init(chmgr:ChaMan,gs:GameState,
                onExit:@escaping ([String])->()) {
    self.onExit = onExit
    self.gs = gs
    self.chmgr = chmgr
    self.ourTopics =    chmgr.playData.allTopics
    let randomTopics = ourTopics.shuffled()
    let chosenTopics = Array(randomTopics.prefix(gs.boardsize  - 1))
    let remainingTopics = Array(randomTopics.dropFirst(gs.boardsize - 2))
    _selectedTopics = State(initialValue: chosenTopics)
    _availableTopics = State(initialValue: remainingTopics)
    l_faceUpCards = gs.faceup
    l_boardSize = gs.boardsize
    l_doubleDiag = gs.doublediag
    l_currentScheme = gs.currentscheme
    l_difficultyLevel = gs.difficultylevel
    l_startInCorners = gs.startincorners
    l_selectedTopics = chosenTopics
  }
  let ourTopics: [String]
  @State private var  l_boardSize: Int
  @State private var  l_startInCorners: Bool
  @State private var  l_faceUpCards: Bool
  @State private var  l_doubleDiag: Bool
  @State private var  l_currentScheme: ColorSchemeName
  @State private var  l_difficultyLevel: Int
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
    case .winter:
      return LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case .spring:
      return LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case .summer:
      return LinearGradient(gradient: Gradient(colors: [Color.brown, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case .autumn:
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
            Text("\(AppColors.allSchemes[idx].name)")
              .tag(idx)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(colorPaletteBackground.clipShape(RoundedRectangle(cornerRadius: 10)))
      }
      //.onChange(of: l_colorPalette, initial: false)
      //{ _,_ in onParameterChange() }
      
      Section(header: Text("Topics")) {
        NavigationLink(destination: TopicsChooserScreen(allTopics: chmgr.everyTopicName, 
            schemes: AppColors.allSchemes,gs:gs,
      currentScheme: $l_currentScheme,
      selectedTopics: $l_selectedTopics))
        {
          Text("Choose Topics")
            .padding()
            .foregroundColor(.blue)
        }
      }
      .onAppear {
        if firstOnAppear {
          //selectedTopics = getRandomTopics(boardSize - 1, from: chmgr.allTopics)
          firstOnAppear = false
          chmgr.checkTopicConsistency("GameSettings onAppear")
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
      FreeportSettingsScreen(gs: gs, chmgr: chmgr)
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
        self.presentationMode.wrappedValue.dismiss()
      }
    )
    //}
  }
  private func onDonePressed() {
    // copy every change into gameState
    gs.doublediag = l_doubleDiag
    gs.difficultylevel = l_difficultyLevel
    gs.startincorners = l_startInCorners
    selectedTopics = l_selectedTopics //selectedTopics +
    gs.faceup = l_faceUpCards
    gs.boardsize = l_boardSize
    gs.topicsinplay = l_selectedTopics // //*****2
    gs.currentscheme = l_currentScheme
    chmgr.checkTopicConsistency("GameSettingScreen onDonePressed")
  }
}

struct GameSettingsScreen :
  View {
  @Bindable var chmgr: ChaMan
  @Bindable var gs: GameState
  let onExit: ([String])->()
  
  var body: some View {
    NavigationView  {
      GameSettingsView(
        chmgr: chmgr,
        gs:gs,
        onExit: onExit
      )
    }
  }
}
//#Preview("Tester") {
  //  let t  = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
  //  GameSettingsScreen(chmgr: ChaMan(playData: PlayData.mock),
  //                     gs: GameBoard(size: starting_size,
  //                                          topics: Array(MockTopics.mockTopics.prefix(starting_size)),  challenges:Challenge.mockChallenges)
  //                         ,
  //                                              ourTopics: t) {  strings in
  //    print("GameSettingsExited with \(t)")
  //  }
//}


//  private func replaceTopic(at index: Int) {
//    guard !tappedIndices.contains(index), !availableTopics.isEmpty else { return }
//    let newTopic = availableTopics.removeFirst()
//    replacedTopics[index] = l_selectedTopics[index]
//    l_selectedTopics[index] = newTopic
//    tappedIndices.insert(index)
//  }

//  private func selectAdditionalTopic(_ topic: String) {
//    if selectedAdditionalTopics.contains(topic) {
//      selectedAdditionalTopics.remove(topic)
//    } else if selectedAdditionalTopics.count < boardSize {
//      selectedAdditionalTopics.insert(topic)
//    }
//  }

//  private func refreshTopics() {
//    let randomTopics = ourTopics.shuffled()
//    l_selectedTopics = Array(randomTopics.prefix(gameBoard.boardsize - 2))
//    availableTopics = Array(randomTopics.dropFirst(gameBoard.boardsize - 2))
//    tappedIndices.removeAll()
//    replacedTopics.removeAll()
//    selectedAdditionalTopics.removeAll()
//  }
