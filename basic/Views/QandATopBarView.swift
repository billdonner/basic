import SwiftUI
struct QandATopBarView: View {
    let topic: String
  let hint:String
    let elapsedTime: String
    let additionalInfo: String
    let handlePass: () -> Void
    let toggleHint: () -> Void
    
    var body: some View {
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
    }
    
    var passButton: some View {
        Button(action: {
            handlePass()
        }) {
            Image(systemName: "nosign")
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
        Text("Elapsed Time: \(elapsedTime)")
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
      topic: "American History", hint: "What can we say about history?",
        elapsedTime: "05:32",
        additionalInfo: "Some extra information",
        handlePass: {},
        toggleHint: {}
    )
}
