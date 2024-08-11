import SwiftUI
struct QandATopBarView: View {
    let gs:GameState
    let geometry: GeometryProxy
    let topic: String
    let hint:String
    let handlePass: () -> Void
    let handleGimmee: () -> Void
    let toggleHint: () -> Void
  
  @Binding var elapsedTime: TimeInterval   // Elapsed time in seconds
  @Binding var killTimer: Bool
  
  @State private var timer: Timer? = nil  // Timer to track elapsed time 
  @State   var gimmeeAlert = false
  func startTimer() {
    elapsedTime = 0
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      elapsedTime += 1
    }
  }

  public func stopTimer() {
    gs.totaltime += elapsedTime
    timer?.invalidate()
    timer = nil
  }
  
  var formattedElapsedTime: String {
    let minutes = Int(elapsedTime) / 60
    let seconds = Int(elapsedTime) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
  
    var body: some View {
     // let _ = print("//QandATopBarView \(formattedElapsedTime)")
        ZStack {
            HStack {
                passButton
                    .padding(.leading, 20)
                Spacer()
              gimmeeButton
                .padding(.trailing, 4)
          
                hintButton
                    .padding(.trailing, 20)
            }
          VStack(alignment:.center) {
            Text(topic).multilineTextAlignment(.center)
                    .font(.headline)
                    .lineLimit(2)//,reservesSpace: true)
                    .foregroundColor(.primary)
                elapsedTimeView
                additionalInfoView
            }.frame(width:geometry.size.width * 0.6)
        }
        .padding(.top)
        .gimmeeAlert(isPresented: $gimmeeAlert,
                     title: "I will replace this Question \nwith another from the same topic, \nif possible",
                     message: "I will charge you one gimmee",
                     button1Title: "OK",
                     button2Title: "Cancel",
                     onButton1Tapped: handleGimmee,
                     onButton2Tapped: { print("Gimmee cancelled")  },
                     animation: .spring())
        .onAppear {
          startTimer()
        }
        .onDisappear {
          stopTimer()
        }
        .onChange(of: killTimer) { oldValue, newValue in
          stopTimer()
        }
    }
    
    var passButton: some View {
        Button(action: {
            handlePass()
        }) {
            Image(systemName: "multiply.circle")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.gray)
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
              .frame(width: 40, height: 40)
              .background(Color.purple)
              .cornerRadius(10)
      }    .disabled(gs.gimmees<1)
      .opacity(gs.gimmees<1 ? 0.5:1)
  }
     
    var hintButton: some View {
        Button(action: {
            toggleHint()
        }) {
            Image(systemName: "lightbulb")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 40, height:40)
                .background(Color.orange)
                .cornerRadius(10)
        }
        .disabled(hint.count <= 1 )
        .opacity(hint.count <= 1 ? 0.5:1.0)
    }

    var elapsedTimeView: some View {
        Text("Elapsed Time: \(formattedElapsedTime)")
            .font(.footnote)
            .foregroundColor(.secondary)
    }

    var additionalInfoView: some View {
      Text("won:\(gs.woncount) lost:\(gs.lostcount) gimmees:\(gs.gimmees)")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

#Preview {
  GeometryReader { geometry in
    
    QandATopBarView(
      gs: GameState(size:1, topics:["foo"],challenges:[Challenge.complexMock]),
      geometry: geometry,
      topic: "American History running to great lengths",
      hint: "What can we say about history?",
      handlePass:{}, handleGimmee: {}, toggleHint: {},
      elapsedTime: .constant(23984923.0),
      killTimer:.constant(false)
    )
  }
}
