import SwiftUI
struct QandATopBarView: View {
    let topic: String
    let hint:String
    let elapsedTime: TimeInterval
    let additionalInfo: String
    let handlePass: () -> Void
    let toggleHint: () -> Void
  
  var formattedElapsedTime: String {
    let minutes = Int(elapsedTime) / 60
    let seconds = Int(elapsedTime) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
  
    var body: some View {
      let _ = print("//QandATopBarView \(formattedElapsedTime)")
 
        ZStack {
            HStack {
                passButton
                    .padding(.leading, 20)
                Spacer()
                hintButton
                    .padding(.trailing, 20)
            }
            VStack {
                Text(topic)
                    .font(.headline)
                    .foregroundColor(.primary)
                elapsedTimeView
                additionalInfoView
            }
        }
        .padding(.top)
        .onAppear {
          print ("//QandATopBarView onAppear")
        }
        .onDisappear {
          print ("//QandATopBarView onDisAppear")
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
        Text(additionalInfo)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

#Preview {
    QandATopBarView(
      topic: "American History", 
      hint: "What can we say about history?",
      elapsedTime: 23984923.0,
        additionalInfo: "Some extra information",
        handlePass: {},
        toggleHint: {}
    )
}
