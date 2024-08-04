import SwiftUI
struct QandATopBarView: View {
  let gs:GameState
  let geometry: GeometryProxy
    let topic: String
    let hint:String
    let handlePass: () -> Void
    let toggleHint: () -> Void
  
  @Binding var elapsedTime: TimeInterval   // Elapsed time in seconds
  @Binding var killTimer: Bool
  
  @State private var timer: Timer? = nil  // Timer to track elapsed time
   
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
            }.frame(width:geometry.size.width * 0.7)
        }
        .padding(.top)
        .onAppear {
          print ("//QandATopBarView onAppear")
          startTimer()
        }
        .onDisappear {
          print ("//QandATopBarView onDisAppear")
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
                .frame(width: 50, height: 50)
                .background(Color.gray)
                .cornerRadius(10)
        }
    }

    var hintButton: some View {
        Button(action: {
            toggleHint()
        }) {
            Image(systemName: "lightbulb")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
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
      handlePass:{}, toggleHint: {},
      elapsedTime: .constant(23984923.0),
      killTimer:.constant(false)
    )
  }
}
