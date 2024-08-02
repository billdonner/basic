import SwiftUI


struct QandAScreen: View {
  let row: Int
  let col: Int
  let st: ChaMan.ChallengeStatus?
  @Binding var isPresentingDetailView: Bool
  @Bindable  var chmgr:ChaMan //
  @Bindable var gs: GameState  //
  @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
  @State private var showInfo = false
  @State private var gimmeeAlert = false
  @State private var gimmeeAllAlert = false
  @State private var selectedAnswer: String? = nil  // State to track selected answer
  @State private var answerCorrect: Bool = false   // State to track if the selected answer is correct
  @State private var showCorrectAnswer: Bool = false  // State to show correct answer temporarily
  @State private var showBorders: Bool = false  // State to show borders after animation
  @State private var showHint: Bool = false  // State to show/hide hint
  @State private var animateBackToBlue: Bool = false  // State to animate answers back to blue
  @State private var dismissToRootFlag = false // take all the way to GameScreen if set
  @State private var answerGiven: Bool = false  // prevent further interactions after an answer is given
  @State private var killTimer:Bool = false // set true to get the timer to stop
  @State private var elapsedTime: TimeInterval = 0
  @State private var questionedWasAnswered: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      let ch = gs.board[row][col]
      ZStack {
        VStack {
          QandATopBarView(
            gs: gs, topic: ch.topic, hint: ch.hint,
            handlePass:handlePass,
            toggleHint:  toggleHint,
            elapsedTime: $elapsedTime,
            killTimer: $killTimer)
          
          questionAndAnswersSectionVue(geometry: geometry)
          Spacer()
          bottomButtons
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
        
        .hintAlert(isPresented: $showHint, title: "Here's Your Hint", message: ch.hint,
                   buttonTitle: "Dismiss", onButtonTapped: {
          handleDismissal(toRoot:false)
        }, animation: .spring())
        
        .answeredAlert(isPresented: $answerGiven, title: ch.correct, message: ch.explanation ?? "xxx", buttonTitle: "OK", onButtonTapped: {
          handleDismissal(toRoot:true)
          questionedWasAnswered = false // to guard against tapping toomany times
        })
        .sheet(isPresented: $showInfo){
          ChallengeInfoScreen(challenge: ch)
        }
        .gimmeeAlert(isPresented: $gimmeeAlert, title: "I will replace this Question \nwith another from the same topic, \nif possible", message: "I will charge you one gimmee", button1Title: "OK", button2Title: "Cancel",onButton1Tapped: {
          handleGimmee(row:row,col:col)
          // let color = colorForTopic(ch.topic, gs: gs)
          gs.replacedcount += 1
          //dismiss()
          //handleDismissal(toRoot:false)
        }, onButton2Tapped: {
          print("Gimmee cancelled")
        },
                     animation: .spring())
        
        .gimmeeAllAlert(isPresented: $gimmeeAllAlert, title: "I will replace this Question \nwith another from any topic", message: "I will charge you one gimmee", buttonTitle: "OK", onButtonTapped: {
          handleGimmee(row:row,col:col)
          handleDismissal(toRoot:false)
        }, animation: .spring())
      }
    }
  }
  
  var bottomButtons: some View {
    HStack(spacing: 10) {
      passButton
      markCorrectButton
      markIncorrectButton
      gimmeeButton
      infoButton
    }
    .padding(.bottom)
    .frame(height: 60)
  }
  var passButton: some View {
    Button(action: {
      handlePass()
    }) {
      Image(systemName: "multiply.circle")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.gray)
        .cornerRadius(10)
    }
  }
  var markCorrectButton: some View {
    Button(action: {
      answeredCorrectly(gs.board[row][col],row:row,col:col)
    }) {
      Image(systemName: "checkmark.circle")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.green)
        .cornerRadius(10)
    }
  }
  var markIncorrectButton: some View {
    Button(action: {
      answeredIncorrectly(gs.board[row][col],row:row,col:col)
    }) {
      Image(systemName: "xmark.circle")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.red)
        .cornerRadius(10)
    }
  }
  var gimmeeButton: some View {
    Button(action: {
      gimmeeAlert = true
    }) {
      Image(systemName: "arcade.stick.and.arrow.down")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.purple)
        .cornerRadius(10)
    }
    .disabled(gs.gimmees<1)
    .opacity(gs.gimmees<1 ? 0.5:1)
    
  }
  var infoButton: some View {
    Button(action: {
      showInfo = true
    }) {
      Image(systemName: "info.circle")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.blue)
        .cornerRadius(10)
    }
  }
  var gimmeeAllButton: some View {
    Button(action: {
      gimmeeAllAlert = true
    }) {
      Image(systemName: "arcade.stick.and.arrow.up")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 50, height: 50)
        .background(Color.purple)
        .cornerRadius(10)
    }
    .disabled(gs.gimmees<1)
    .opacity(gs.gimmees<1 ? 0.5:1)
  }
}
extension QandAScreen {
  func questionAndAnswersSectionVue(geometry: GeometryProxy) -> some View {
    VStack(spacing: 15) {
      questionSectionVue(geometry: geometry)
      answerButtonsVue(geometry: geometry)
    }
    .padding(.horizontal)
    .padding(.bottom)
    .frame(maxWidth: max(0, geometry.size.width), maxHeight: max(0, geometry.size.height * 0.8))
  }
  
  func questionSectionVue(geometry: GeometryProxy) -> some View {
    let paddingWidth = geometry.size.width * 0.1
    let contentWidth = geometry.size.width - paddingWidth
    let topicColor =   gs.colorForTopic(gs.board[row][col].topic).0
    
    return Text(gs.board[row][col].question)
      .font(.headline)
      .padding(.horizontal)
      .background(RoundedRectangle(cornerRadius: 10).fill(topicColor.opacity(0.2))) // Use topic color for background
      .frame(width: max(0,contentWidth), height:max(0,  geometry.size.height * 0.2))
      .lineLimit(8)
      .fixedSize(horizontal: false, vertical: true) // Ensure the text box grows vertically
  }
  
  func answerButtonsVue(geometry: GeometryProxy) -> some View {
    let answers = gs.board[row][col].answers.shuffled() // mix it up
    let paddingWidth = geometry.size.width * 0.1
    let contentWidth = geometry.size.width - paddingWidth
    
    if answers.count >= 5 {
      let buttonWidth = (contentWidth / 2.5) - 10 // Adjust width to fit 2.5 buttons
      let buttonHeight = buttonWidth * 1.57 // 57% higher than the four-answer case
      return AnyView(
        VStack {
          ScrollView(.horizontal) {
            HStack(spacing: 15) {
              ForEach(answers, id: \.self) { answer in
                answerButtonVue(answer: answer, row:row,col:col, buttonWidth: buttonWidth, buttonHeight: buttonHeight, taller: true)
              }
            }
            .padding(.horizontal)
            .disabled(questionedWasAnswered)  // Disable all answer buttons after an answer is given
          }
          Image(systemName: "arrow.right")
            .foregroundColor(.gray)
            .padding(.top, 10)
        }
          .frame(width: contentWidth) // Set width of the scrolling area
         
      )
    } else if answers.count == 3 {
      return AnyView(
        VStack(spacing: 15) {
          answerButtonVue(answer: answers[0],row:row,col:col, buttonWidth: contentWidth / 2)
          HStack {
            answerButtonVue(answer: answers[1],row:row,col:col, buttonWidth: contentWidth / 2.5)
            answerButtonVue(answer: answers[2],row:row,col:col, buttonWidth: contentWidth / 2.5)
          }
        }
          .padding(.horizontal)
          .disabled(questionedWasAnswered)  // Disable all answer buttons after an answer is given
      )
    } else {
      let buttonWidth = min(geometry.size.width / 3 - 20, 100) * 1.5
      let buttonHeight = buttonWidth * 0.8 // Adjust height to fit more lines
      return AnyView(
        VStack(spacing: 15) {
          HStack {
            answerButtonVue(answer: answers[0],row:row,col:col, buttonWidth: buttonWidth , buttonHeight:buttonHeight)
            answerButtonVue(answer: answers[1],row:row,col:col, buttonWidth: buttonWidth , buttonHeight:buttonHeight)
          }
          HStack {
            answerButtonVue(answer: answers[2],row:row,col:col, buttonWidth: buttonWidth , buttonHeight:buttonHeight)
            answerButtonVue(answer: answers[3],row:row,col:col, buttonWidth: buttonWidth , buttonHeight:buttonHeight)
          }
//          ForEach(answers.chunked(into: 2), id: \.self) { row in
//            HStack {
//              ForEach(row, id: \.self) { answer in
//                answerButtonVue(answer: answer,row:row,col:col,buttonWidth:buttonWidth,buttonHeight:buttonHeight)
//              }
//            }
//          }
        }
          .padding(.horizontal)
          .disabled(questionedWasAnswered)  // Disable all answer buttons after an answer is given
      )
    }
  }
  
  func answerButtonVue(answer: String,row:Int,col:Int, buttonWidth: CGFloat, buttonHeight: CGFloat? = nil, taller: Bool = false) -> some View {
    Button(action: {
      handleAnswerSelection(answer: answer,row:row,col:col)
    })
    {
      Text(answer)
        .font(.body)
        .foregroundColor(.white)
        .padding()
        .frame(width: buttonWidth, height: buttonHeight)
        .background(
          Group {
            if answerGiven {
              if answer == selectedAnswer {
                answerCorrect == true ? Color.green : Color.red
              } else if answerCorrect == true {
                Color.red
              } else if showCorrectAnswer && answer == gs.board[row][col].correct {
                Color.green
              }  else {
                Color.blue
              }
            } else {
              Color.blue
            }
          }
        )
        .cornerRadius(5)  // Make the buttons rounded rectangles
        .minimumScaleFactor(0.5)  // Adjust font size to fit
        .lineLimit(8)
        .rotationEffect(showCorrectAnswer && answer == gs.board[row][col].correct ? .degrees(360) : .degrees(0))
        .overlay(
          RoundedRectangle(cornerRadius: 5)  // Match the corner radius
            .stroke(showBorders && answer == selectedAnswer && !answerCorrect ? Color.red : showBorders && answer == gs.board[row][col].correct && answerCorrect == false ? Color.green : Color.clear, lineWidth: 5)
        )
        .animation(.easeInOut(duration: showCorrectAnswer ? 1.0 : 0.5), value: showCorrectAnswer)
        .animation(.easeInOut(duration: answerGiven ? 1.0 : 0.5), value: animateBackToBlue)
        .animation(.easeInOut(duration: 0.5), value: showBorders)
    }
  }
  
}
extension QandAScreen {
  
  private func handleDismissal(toRoot:Bool) {
    if toRoot {
      withAnimation(.easeInOut(duration: 0.75)) { // Slower dismissal
        isPresentingDetailView = false
        dismiss()
      }
    } else {
      answerGiven = false //showAnsweredAlert = false
      showHint=false //  showHintAlert = false
    }
  }
  
  func toggleHint() {
    if gs.board[row][col].hint.count > 1  { // guard against short hints
      showHint.toggle()
    }
  }
  
  func handleGimmee(row:Int,col:Int) {
    let idx = row*gs.boardsize + col
    let result = chmgr.replaceChallenge(at:idx)
    switch result {
    case .success(let index):
      gs.gimmees -= 1
      let challenge = chmgr.everyChallenge[index[0]]
      gs.board[row][col] = challenge
      print("Gimmee realloation successful")
      
    case .error(let error):
      print("Couldn't handle gimmee reallocation \(error)")
    }
    killTimer = true
    dismiss()
  }

}
  extension QandAScreen { /* actions */

    func answeredCorrectly(_ ch:Challenge,row:Int,col:Int) {
    chmgr.checkAllTopicConsistency("mark correct before")
    assert(gs.checkVsChaMan(chmgr: chmgr))
    answerCorrect = true
    answerGiven = true
    showBorders = true
    
    
    gs.cellstate[row][col] = .playedCorrectly
    gs.rightcount += 1
    chmgr.bumpRightcount(topic: ch.topic)
    chmgr.stati[gs.challengeindices[row][col]] = .playedCorrectly  // ****
   killTimer=true
    chmgr.save()
    chmgr.checkAllTopicConsistency("mark correct after")
  }
  func answeredIncorrectly(_ ch:Challenge,row:Int,col:Int) {
    chmgr.checkAllTopicConsistency("mark incorrect before")
    assert(gs.checkVsChaMan(chmgr: chmgr))
    answerCorrect = false
    answerGiven = true
    showCorrectAnswer = false
    showBorders = true
    
    gs.cellstate[row][col] = .playedIncorrectly
    gs.wrongcount += 1
    chmgr.bumpWrongcount(topic: ch.topic)
    chmgr.stati[gs.challengeindices[row][col]] = .playedIncorrectly  // ****
    killTimer=true
    chmgr.save()
    chmgr.checkAllTopicConsistency("mark incorrect after")
  }
  func handleAnswerSelection(answer: String,row:Int,col:Int) {
    if !questionedWasAnswered { // only allow one answer
      let ch = gs.board[row][col]
      selectedAnswer = answer
      answerCorrect = (answer == ch.correct)
      answerGiven = true
      
      switch answerCorrect {
      case true: answeredCorrectly(ch,row:row,col:col)
      case false: answeredIncorrectly(ch,row:row,col:col)
      }
      questionedWasAnswered = true
    } else {
      print("dubl tap \(answer)")
    }
  }
  func handlePass() {
   killTimer=true
    dismiss()
  }
}
#Preview {
  QandAScreen(row: 0, col: 0, st: ChaMan.ChallengeStatus.allocated,   isPresentingDetailView: .constant(true), chmgr: ChaMan(playData: .mock), gs: GameState(size: starting_size,                                                                      topics: Array(MockTopics.mockTopics.prefix(starting_size)), challenges:Challenge.mockChallenges))
  
}
#Preview {
  QandAScreen(row: 0, col: 0, st:ChaMan.ChallengeStatus.playedCorrectly,  isPresentingDetailView: .constant(true), chmgr: ChaMan(playData: .mock), gs: GameState(size: starting_size,                                                                      topics: Array(MockTopics.mockTopics.prefix(starting_size)), challenges:Challenge.mockChallenges))
  
}
