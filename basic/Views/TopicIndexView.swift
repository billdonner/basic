import SwiftUI

struct Tdi: Identifiable {
    let name: String
    let id = UUID()
}

struct TopicIndexView: View {
    let gs: GameState
    let chmgr: ChaMan
    @Environment(\.colorScheme) var colorScheme // System light/dark
    @State var succ = false
    @State var topicDetailInfo: Tdi? = nil

    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]

    var body: some View {
        GeometryReader { geometry in
            let isIpad = geometry.size.width > 600
            
            VStack {
             // Text("      ") // push this down a bit
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(gs.basicTopics(), id: \.name) { topic in
                        HStack {
                            RoundedRectangle(cornerSize: CGSize(width: 10.0, height: 3.0))
                                .frame(width: isIpad ? 25 : 15, height: isIpad ? 25 : 15)
                                .foregroundStyle(gs.colorForTopic(topic.name).0)
                            Text(truncatedText(topic.name, count: isIpad ? 60 : 15))
                                .lineLimit(1)
                                .font(isIpad ? .headline : .caption2)
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .frame(width: geometry.size.width / (1.0 * //1.1
                          CGFloat(columns.count)), height: isIpad ? 30 : 24)
                        .padding(.horizontal, isIpad ? 8 : 4)
                        .background(Color.clear)
                        //.cornerRadius(8)
                        .onTapGesture {
                            topicDetailInfo = Tdi(name: topic.name)
                        }
                    }
                }
                .padding(4)
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
            .sheet(item: $topicDetailInfo) { tdi in
                TopicDetailsView(topic: tdi.name, gs: gs, chmgr: chmgr)
            }
            .padding()
        }
    }

    // Computed properties for background and text colors
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.96)
    }

    private var textColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    private func truncatedText(_ text: String, count: Int) -> String {
        if text.count > count {
            let index = text.index(text.startIndex, offsetBy: count)
            return String(text[..<index]) + "..."
        }
        return text
    }
}

// Assuming you have the ChaMan and colorSchemes to preview the view
struct TopicIndexView_Previews: PreviewProvider {
    static var previews: some View {
        TopicIndexView(
            gs: GameState(size: 3, topics: Array(MockTopics.mockTopics.prefix(12)),
                          challenges: Challenge.mockChallenges),
            chmgr: ChaMan(playData: PlayData.mock)
        )
    }
}
