//
//  CustomAlerts.swift
//  calert4
//
//  Created by bill donner on 7/7/24.
//

import SwiftUI
import AVFoundation

// Extension for a custom 3D rotation transition
extension AnyTransition {
    static var rotateAndFade: AnyTransition {
        AnyTransition.modifier(
            active: RotateAndFadeModifier(angle: 360, opacity: 0),
            identity: RotateAndFadeModifier(angle: 0, opacity: 1)
        )
    }
}

// Custom view modifier for the 3D rotation and fade effect
fileprivate struct RotateAndFadeModifier: ViewModifier {
    let angle: Double
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
            .opacity(opacity)
    }
}

// A frosted background view using a blur effect
fileprivate struct FrostedBackgroundView: View {
    var body: some View {
        BlurView(style: .light)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 10)
            .padding()
    }
}

// A helper view to create a blur effect using UIViewRepresentable
fileprivate struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// Fireworks effect view using SF Symbol
fileprivate struct FireworksView: View {
    @State private var animate = false
    
    var body: some View {
        Image(systemName: "fireworks")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100) // Adjusted size
            .foregroundColor(.red)
            .scaleEffect(animate ? 1.2 : 0.8)
            .opacity(animate ? 1 : 0.5)
            .position(x: UIScreen.main.bounds.midX, y: 100) // More centered position
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    self.animate.toggle()
                }
            }
    }
}

// Custom alert view for YouWin with fireworks
fileprivate struct YouWinAlert: View {
    let title: String
    let bodyMessage: String
    let buttonTitle: String
    let onButtonTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            FireworksView()
                .frame(height: 100) // Adjusted size

            Text(title)
                .font(.largeTitle) // Larger title
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)

            Text(bodyMessage)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing])

            Spacer()
            
            Button(action: {
                onButtonTapped()
            }) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .padding(.bottom, 20) // Added padding below the button
            }
        }
        .background(FrostedBackgroundView())
        .cornerRadius(16)
        .padding()
    }
}

// Custom alert view for YouLose with sad music
fileprivate struct YouLoseAlert: View {
    let title: String
    let bodyMessage: String
    let buttonTitle: String
    let onButtonTapped: () -> Void
    
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(bodyMessage)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing])
            
            Spacer()
            
            Button(action: {
                onButtonTapped()
            }) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .padding(.top)
                    .padding(.bottom, 20) // Added padding
            }
        }
        .background(FrostedBackgroundView())
        .cornerRadius(16)
        .padding()
        .onAppear {
            playSadMusic()
        }
        .frame(height:300)
    }
    
    private func playSadMusic() {
        if let url = Bundle.main.url(forResource: "sad_music", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sad music: \(error.localizedDescription)")
            }
        }
    }
}
#Preview {
  HintAlert(title: "Welcome!", message: "This is a custom alert view with spring animation.", buttonTitle: "OK", onButtonTapped: {}, animation: .spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5) )
}
// Custom alert view with spring animation
fileprivate struct HintAlert: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onButtonTapped: () -> Void
    let animation: Animation
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
            
            Divider()
                .background(Color.primary)
                .padding([.leading, .trailing])
            
            Button(action: {
                withAnimation(animation) {
                    onButtonTapped()
                }
            }) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .padding(.bottom, 20) // Added padding below the button
            }
        }
        .background(FrostedBackgroundView())
        .cornerRadius(16)
        .rotationEffect(.degrees(rotationAngle))
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .rotateAndFade))
        .onAppear {
            withAnimation(animation.speed(0.5)) { // Slowed down rotation
                rotationAngle = 360
            }
        }
        .padding()
    }
}

// Custom alert view with easeInOut animation
fileprivate struct AnsweredAlert: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onButtonTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
            
            Divider()
                .background(Color.primary)
                .padding([.leading, .trailing])
            
            Button(action: {
                withAnimation(.easeInOut(duration: 2)) { // Slowed down by 2x
                    onButtonTapped()
                }
            }) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .padding(.bottom, 20) // Added padding below the button
            }
        }
        .background(FrostedBackgroundView())
        .cornerRadius(16)
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
        .padding()
    }
}

// Custom alert modifier for YouWinAlert
fileprivate struct YouWinAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let bodyMessage: String
    let buttonTitle: String
  let onButtonTapped: () -> Void
  
  func body(content: Content) -> some View {
      ZStack {
          content
              .blur(radius: isPresented ? 2 : 0)
          
          if isPresented {
              YouWinAlert(
                  title: title,
                  bodyMessage: bodyMessage,
                  buttonTitle: buttonTitle,
                  onButtonTapped: {
                      withAnimation(.easeInOut(duration: 1.25)) { // Slower dismissal
                          isPresented = false
                      }
                      onButtonTapped()
                  }
              )
          }
      }
  }
}

// Custom alert modifier for YouLoseAlert
fileprivate struct YouLoseAlertModifier: ViewModifier {
  @Binding var isPresented: Bool
  let title: String
  let bodyMessage: String
  let buttonTitle: String
  let onButtonTapped: () -> Void
  
  func body(content: Content) -> some View {
      ZStack {
          content
              .blur(radius: isPresented ? 2 : 0)
          
          if isPresented {
              YouLoseAlert(
                  title: title,
                  bodyMessage: bodyMessage,
                  buttonTitle: buttonTitle,
                  onButtonTapped: {
                      withAnimation(.easeInOut(duration: 1.25)) { // Slower dismissal
                          isPresented = false
                      }
                      onButtonTapped()
                  }
              )
          }
      }
  }
}

// Custom alert modifier for AnsweredAlert with easeInOut animation
fileprivate struct AnsweredAlertModifier: ViewModifier {
  @Binding var isPresented: Bool
  let title: String
  let message: String
  let buttonTitle: String
  let onButtonTapped: () -> Void
  
  func body(content: Content) -> some View {
      ZStack {
          content
              .blur(radius: isPresented ? 2 : 0)
          
          if isPresented {
              AnsweredAlert(
                  title: title,
                  message: message,
                  buttonTitle: buttonTitle,
                  onButtonTapped: {
                      withAnimation(.easeInOut(duration: 1.25)) { // Slowed down by 1.25x
                          isPresented = false
                      }
                      onButtonTapped()
                  }
              )
          }
      }
  }
}

// Custom alert modifier for HintAlert with spring animation
fileprivate struct HintAlertModifier: ViewModifier {
  @Binding var isPresented: Bool
  let title: String
  let message: String
  let buttonTitle: String
  let onButtonTapped: () -> Void
  let animation: Animation
  
  func body(content: Content) -> some View {
      ZStack {
          content
              .blur(radius: isPresented ? 2 : 0)
          
          if isPresented {
              HintAlert(
                  title: title,
                  message: message,
                  buttonTitle: buttonTitle,
                  onButtonTapped: {
                      withAnimation(animation.speed(0.5)) { // Slower dismissal
                          isPresented = false
                      }
                      onButtonTapped()
                  },
                  animation: animation
              )
          }
      }
  }
}

// Extension methods for the new alerts
extension View {
  func youWinAlert(isPresented: Binding<Bool>, title: String, bodyMessage: String, buttonTitle: String, onButtonTapped: @escaping () -> Void) -> some View {
      self.modifier(YouWinAlertModifier(isPresented: isPresented, title: title, bodyMessage: bodyMessage, buttonTitle: buttonTitle, onButtonTapped: onButtonTapped))
  }
  
  func youLoseAlert(isPresented: Binding<Bool>, title: String, bodyMessage: String, buttonTitle: String, onButtonTapped: @escaping () -> Void) -> some View {
      self.modifier(YouLoseAlertModifier(isPresented: isPresented, title: title, bodyMessage: bodyMessage, buttonTitle: buttonTitle, onButtonTapped: onButtonTapped))
  }
  
  func answeredAlert(isPresented: Binding<Bool>, title: String, message: String, buttonTitle: String, onButtonTapped: @escaping () -> Void) -> some View {
      self.modifier(AnsweredAlertModifier(isPresented: isPresented, title: title, message: message, buttonTitle: buttonTitle, onButtonTapped: onButtonTapped))
  }
  
  func hintAlert(isPresented: Binding<Bool>, title: String, message: String, buttonTitle: String, onButtonTapped: @escaping () -> Void, animation: Animation) -> some View {
      self.modifier(HintAlertModifier(isPresented: isPresented, title: title, message: message, buttonTitle: buttonTitle, onButtonTapped: onButtonTapped, animation: animation))
  }
}
