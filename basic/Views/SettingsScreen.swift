import SwiftUI
func removeElements<T: Equatable>(from array: [T], elementsToRemove: [T]) -> [T] {
    return array.filter { !elementsToRemove.contains($0) }
}
fileprivate struct SettingsView: View {
  
 // let onExit: ([String])->()
  @Bindable var chmgr:ChaMan
  @Bindable var gs:GameState
  
  internal init(chmgr:ChaMan,gs:GameState)//,
                //onExit:@escaping ([String])->())
  {
   // self.onExit = onExit
    self.gs = gs
    self.chmgr = chmgr
    self.ourTopics =    chmgr.playData.allTopics
//    let randomTopics = ourTopics.shuffled()
//    let chosenTopics = Array(randomTopics.prefix(gs.boardsize  - 2))
//    let remainingTopics = Array(randomTopics.dropFirst(gs.boardsize - 2))
    let chosenTopics = gs.topicsinplay
    let remainingTopics = removeElements(from:chmgr.playData.allTopics,elementsToRemove:chosenTopics)
    _l_topicsinplay = State(initialValue: chosenTopics)
    _availableTopics = State(initialValue: remainingTopics)
    l_faceUpCards = gs.faceup
    l_boardsize = gs.boardsize
    l_doubleDiag = gs.doublediag
    l_currentScheme = gs.currentscheme.rawValue
    l_difficultyLevel = gs.difficultylevel
    l_startInCorners = gs.startincorners
  }
  let ourTopics: [String]
  @State private var  l_boardsize: Int
  @State private var  l_startInCorners: Bool
  @State private var  l_faceUpCards: Bool
  @State private var  l_doubleDiag: Bool
  @State private var  l_currentScheme: Int//ColorSchemeName
  @State private var  l_difficultyLevel: Int
  @State private var  l_topicsinplay: [String]
  
 // @State var selectedTopics: [String]
  @State var availableTopics: [String]
  @State var tappedIndices: Set<Int> = []
  @State var replacedTopics: [Int: String] = [:]
  @State var selectedAdditionalTopics: Set<String> = []
  @State var firstOnAppear = true
  
  @State private var showSettings = false
  @Environment(\.presentationMode) var presentationMode
  
  var colorPaletteBackground: LinearGradient {
    switch l_currentScheme {
    case 1://.winter:
      return LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case 2://.spring:
      return LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case 3://.summer:
      return LinearGradient(gradient: Gradient(colors: [Color.green, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
    case 4://.autumn:
      return LinearGradient(gradient: Gradient(colors: [Color.brown, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
        Picker("Board Size", selection: $l_boardsize) {
          Text("3x3").tag(3)
          Text("4x4").tag(4)
          Text("5x5").tag(5)
          Text("6x6").tag(6)
          Text("7x7").tag(7)
          Text("8x8").tag(8)
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
//      Section(header: Text("Double Diag")) {
//        HStack {
//          Text("One Diag")
//          Spacer()
//          Toggle("", isOn: $l_doubleDiag)
//            .labelsHidden()
//          Spacer()
//          Text("Both Diags")
//        }
//        .frame(maxWidth: .infinity)
//      }
      //.onChange(of: l_doubleDiag, initial: false)
      // { _,_ in onParameterChange() }
      Section(header: Text("Color Palette")) {
        Picker("Color Palette", selection: $l_currentScheme) {
          ForEach(AppColors.allSchemes.indices.sorted(),id:\.self) { idx in
            Text("\(AppColors.allSchemes[idx].name)")
              .tag(idx)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(colorPaletteBackground.clipShape(RoundedRectangle(cornerRadius: 10)))
      }
//      .onChange(of: l_currentScheme, initial: false)      {
//        print("Scheme changed to \(l_currentScheme)")
//      }
      
      Section(header: Text("Topics")) {
        NavigationLink(destination: TopicsChooserScreen(
              allTopics:chmgr.everyTopicName,
              schemes: AppColors.allSchemes,
              boardsize: gs.boardsize,
              topicsinplay: gs.topicsinplay, 
              chmgr: chmgr,
              currentScheme: $l_currentScheme,
              selectedTopics: $l_topicsinplay))
        {
          Text("Choose Topics")
            .padding()
            .foregroundColor(.blue)
        }
      }
      .onAppear {
        if firstOnAppear {
          firstOnAppear = false
          chmgr.checkAllTopicConsistency("GameSettings onAppear")
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
          .onChange(of:l_topicsinplay,initial:true ) { old,newer in
            print("Game With Topics:",l_topicsinplay.joined(separator: ","))
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
//    .onDisappear {
//      onExit(l_topicsinplay) // do whatever
//    }
    .navigationBarTitle("Game Settings", displayMode: .inline)
    .navigationBarItems(
      leading: Button("Cancel") {
        // dont touch anything
        print("//GameSettingsScreen Cancel Pressed topics were: \(l_topicsinplay)")
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
    gs.faceup = l_faceUpCards
    gs.boardsize = l_boardsize
    gs.board = Array(repeating: Array(repeating: Challenge(question: "", topic: "", hint: "", answers: [], correct: "", id: "", date: Date(), aisource: ""), count: l_boardsize), count: l_boardsize)
    gs.cellstate = Array(repeating: Array(repeating: .unplayed, count: l_boardsize), count: l_boardsize)
    gs.challengeindices = Array(repeating: Array(repeating: -1, count: l_boardsize), count: l_boardsize)
    gs.topicsinplay = l_topicsinplay // //*****2
    gs.currentscheme = ColorSchemeName(rawValue:l_currentScheme) ?? .bleak
    chmgr.checkAllTopicConsistency("GameSettingScreen onDonePressed")
    gs.saveGameState()
  }
}

struct SettingsScreen :
  View {
  @Bindable var chmgr: ChaMan
  @Bindable var gs: GameState
 // let onExit: ([String])->()
  
  var body: some View {
    NavigationView  {
      SettingsView(
        chmgr: chmgr,
        gs:gs//,
       // onExit: onExit
      )
    }
  }
}
