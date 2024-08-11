import SwiftUI


struct QandAScreen: View {
  let row: Int
  let col: Int
 // let st: ChaMan.ChallengeStatus?
  @Binding var isPresentingDetailView: Bool
  @Bindable  var chmgr:ChaMan //
  @Bindable var gs: GameState  //
  @Environment(\.dismiss) var dismiss  // Environment value for dismissing the view
  @State  var showInfo = false
 // @State   var gimmeeAllAlert = false
  @State   var showThumbsUp:Challenge? = nil
  @State   var showThumbsDown: Challenge? = nil
  @State   var selectedAnswer: String? = nil  // State to track selected answer
  @State   var answerCorrect: Bool = false   // State to track if the selected answer is correct
  @State   var showCorrectAnswer: Bool = false  // State to show correct answer temporarily
  @State   var showBorders: Bool = false  // State to show borders after animation
  @State   var showHint: Bool = false  // State to show/hide hint
  @State   var animateBackToBlue: Bool = false  // State to animate answers back to blue
  @State   var dismissToRootFlag = false // take all the way to GameScreen if set
  @State   var answerGiven: Bool = false  // prevent further interactions after an answer is given
  @State   var killTimer:Bool = false // set true to get the timer to stop
  @State   var elapsedTime: TimeInterval = 0
  @State   var questionedWasAnswered: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      let ch = chmgr.everyChallenge[gs.board[row][col]]
      ZStack {
        VStack {
          QandATopBarView(
            gs: gs, geometry:geometry, 
            topic: ch.topic,
            hint: ch.hint,
            handlePass:handlePass,
            handleGimmee: handleGimmee, 
            toggleHint:  toggleHint,
            elapsedTime: $elapsedTime,
            killTimer: $killTimer)
          .disabled(questionedWasAnswered)
          
          questionAndAnswersSectionVue(geometry: geometry).disabled(questionedWasAnswered)
          Spacer()
          bottomButtons.disabled(questionedWasAnswered)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
        
        .hintAlert(isPresented: $showHint, title: "Here's Your Hint: ", message: ch.hint,
                   buttonTitle: "Dismiss", onButtonTapped: {
          handleDismissal(toRoot:false)
        }, animation: .spring())
        
        .answeredAlert(isPresented: $answerGiven, 
                       title: (answerCorrect ? "Correct: " :"Incorrect: ") + ch.correct,
                       message: ch.explanation ?? "xxx",
                       buttonTitle: "OK",
                       onButtonTapped: {
                        handleDismissal(toRoot:true)
                        questionedWasAnswered = false // to guard against tapping toomany times
                          })
        .sheet(isPresented: $showInfo){
          ChallengeInfoScreen(challenge: ch)
        }
        .sheet(item:$showThumbsDown) { ch in
          NegativeSentimentView(id: ch.id)
        }
        .sheet(item:$showThumbsUp) { ch in
          PositiveSentimentView(id: ch.id)
        }
  
        
//        .gimmeeAllAlert(isPresented: $gimmeeAllAlert, title: "I will replace this Question \nwith another from any topic", message: "I will charge you one gimmee", buttonTitle: "OK", onButtonTapped: {
//          handleGimmee(row:row,col:col)
//          handleDismissal(toRoot:false)
//        }, animation: .spring())
      }
    }
  }
  
  var bottomButtons: some View {
    HStack(spacing: 10) {
      thumbsUpButton
      thumbsDownButton
      markCorrectButton
      markIncorrectButton
      //gimmeeButton
      infoButton
    }
    .padding(.bottom)
    .frame(height: 60)
  }
  
  var thumbsUpButton: some View {
      Button(action: {
        showThumbsUp =  chmgr.everyChallenge[gs.board[row][col]]
      }){
        Image(systemName: "hand.thumbsup").font(.title)
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(8)
              //.symbolEffect(.wiggle,isActive: true)
      }
  }
  var thumbsDownButton: some View {
      Button(action: {
        showThumbsDown = chmgr.everyChallenge[gs.board[row][col]]
      }){
        Image(systemName: "hand.thumbsdown").font(.title)
              .padding()
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(8)
             // .symbolEffect(.wiggle,isActive: true)
      }
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
      let x = chmgr.everyChallenge[gs.board[row][col]]
      answeredCorrectly(x,row:row,col:col,answered:x.correct)
    }) {
      Image(systemName: "checkmark.circle")
        .font(.headline)
       // .foregroundColor(.white)
        .frame(width: 50, height: 50)
       // .background(Color.green)
        .cornerRadius(10)
    }
  }
  var markIncorrectButton: some View {
    Button(action: {
      let x = chmgr.everyChallenge[gs.board[row][col]]
      answeredIncorrectly(x,row:row,col:col,answered:x.correct)
    }) {
      Image(systemName: "xmark.circle")
        .font(.headline)
       // .foregroundColor(.white)
        .frame(width: 50, height: 50)
        //.background(Color.red)
        .cornerRadius(10)
    }
  }
//  var gimmeeButton: some View {
//    Button(action: {
//      gimmeeAlert = true
//    }) {
//      Image(systemName: "arcade.stick.and.arrow.down")
//        .font(.title)
//        .foregroundColor(.white)
//        .frame(width: 50, height: 50)
//        .background(Color.purple)
//        .cornerRadius(10)
//    }
//    .disabled(gs.gimmees<1)
//    .opacity(gs.gimmees<1 ? 0.5:1)
//    
//  }
  var infoButton: some View {
    Button(action: {
      showInfo = true
    }) {
      Image(systemName: "info.circle")
        .font(.headline)
      //  .foregroundColor(.white)
        .frame(width: 50, height: 50)
        //.background(Color.blue)
        .cornerRadius(10)
    }
  }
//  var gimmeeAllButton: some View {
//    Button(action: {
//      gimmeeAllAlert = true
//    }) {
//      Image(systemName: "arcade.stick.and.arrow.up")
//        .font(.title)
//        .foregroundColor(.white)
//        .frame(width: 50, height: 50)
//        .background(Color.purple)
//        .cornerRadius(10)
//    }
//    .disabled(gs.gimmees<1)
//    .opacity(gs.gimmees<1 ? 0.5:1)
//  }
}
extension QandAScreen {
  func questionAndAnswersSectionVue(geometry: GeometryProxy) -> some View {
    VStack(spacing: 15) {
      questionSectionVue(geometry: geometry)
      answerButtonsVue(geometry: geometry)
    }
    .padding(.horizontal)
    .padding(.bottom)
    
    // Invalid frame dimension (negative or non-finite).?
    .frame(maxWidth: max(0, geometry.size.width), maxHeight: max(0, geometry.size.height * 0.8))//make bigger when bottom buttons gone
  }
  
  func questionSectionVue(geometry: GeometryProxy) -> some View {
    let paddingWidth = geometry.size.width * 0.1
    let contentWidth = geometry.size.width - paddingWidth
    let ch = chmgr.everyChallenge[gs.board[row][col]]
    let topicColor =   gs.colorForTopic(ch.topic).0
    
    return ZStack {
      RoundedRectangle(cornerRadius: 10).fill(topicColor.opacity(0.8))
      // Invalid frame dimension (negative or non-finite).?
      .frame(width: max(0,contentWidth), height:max(0,  geometry.size.height * 0.3))
      HStack {
        Spacer()
        markCorrectButton
          .foregroundColor(foregroundColorFrom( backgroundColor: topicColor ))
        markIncorrectButton
          .foregroundColor(foregroundColorFrom( backgroundColor: topicColor ))
        infoButton
          .foregroundColor(foregroundColorFrom( backgroundColor: topicColor ))
        
      }.offset(x:0, y:-geometry.size.height * 0.15 + 25)
    
      Text(ch.question)
        .font(.title2)
        .padding(.horizontal)
        //.background(topicColor.opacity(0.8)) // Use topic color for background //topicColor
      
      
      // Invalid frame dimension (negative or non-finite).?
        .frame(width: max(0,contentWidth), height:max(0,  geometry.size.height * 0.3))//0.2
        .lineLimit(8)
        .fixedSize(horizontal: false, vertical: true) // Ensure the text box grows vertically
        .foregroundColor(foregroundColorFrom( backgroundColor: topicColor ))
    }
  }
 
  
  func answerButtonsVue(geometry: GeometryProxy) -> some View {
    let answers = chmgr.everyChallenge[gs.board[row][col]]
      .answers.shuffled() // mix it up
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
        
        // Invalid frame dimension (negative or non-finite).?
          .frame(width: contentWidth) // Set width of the scrolling area
        
      )
    } else if answers.count == 3 {
      return AnyView(
        VStack(spacing: 15) {
          answerButtonVue(answer: answers[0],row:row,col:col, buttonWidth: contentWidth / 2, buttonHeight: contentWidth / 2)
          HStack {
            answerButtonVue(answer: answers[1],row:row,col:col, buttonWidth: contentWidth / 2.5, buttonHeight: contentWidth / 2.5)
            answerButtonVue(answer: answers[2],row:row,col:col, buttonWidth: contentWidth / 2.5, buttonHeight: contentWidth / 2.5)
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
  
  func answerButtonVue(answer: String,row:Int,col:Int, buttonWidth: CGFloat, buttonHeight: CGFloat, taller: Bool = false) -> some View {
    func ff()->some View {
      let ch = chmgr.everyChallenge[gs.board[row][col]]
      if answerGiven {
        if answer == selectedAnswer {
          return answerCorrect == true ? Color.green : Color.red
        } else if answerCorrect == true {
          return Color.red
        } else if showCorrectAnswer && answer == ch.correct {
          return Color.green
        }  else {
          return Color.blue
        }
      }
      return Color.blue
    }
    return  Button(action: {
      handleAnswerSelection(answer: answer,row:row,col:col)
    })
    {
      let ch = chmgr.everyChallenge[gs.board[row][col]]
      Text(answer)
        .font(.body)
        .foregroundColor(.white)
        .padding()
        //.frame(width: buttonWidth*0.9, height: buttonHeight*0.9)
        .background(
          Group {
            ff()
          }
        )
        .cornerRadius(5)  // Make the buttons rounded rectangles
        .minimumScaleFactor(0.5)  // Adjust font size to fit
        .lineLimit(8)
        .rotationEffect(showCorrectAnswer && answer == ch.correct ? .degrees(360) : .degrees(0))
        .overlay(
          RoundedRectangle(cornerRadius: 5)  // Match the corner radius
            .stroke(showBorders && answer == selectedAnswer && !answerCorrect ? Color.red : showBorders && answer == ch.correct && answerCorrect == false ? Color.green : Color.clear, lineWidth: 5)
        )
        .animation(.easeInOut(duration: showCorrectAnswer ? 1.0 : 0.5), value: showCorrectAnswer)
        .animation(.easeInOut(duration: answerGiven ? 1.0 : 0.5), value: animateBackToBlue)
        .animation(.easeInOut(duration: 0.5), value: showBorders)
    }
  }
  
}

#Preview {
  QandAScreen(row: 0, col: 0,   isPresentingDetailView: .constant(true), chmgr: ChaMan.mock, gs: GameState.mock)
  
}
#Preview {
  QandAScreen(row: 0, col: 0,  isPresentingDetailView: .constant(true), chmgr: ChaMan.mock, gs: GameState.mock )
  
}
