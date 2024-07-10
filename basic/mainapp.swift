//
//  mainapp.swift
//  basic
//
//  Created by bill donner on 7/8/24.
//

import SwiftUI

class OrientationLockedViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
func getPlayData()-> PlayData {
  return PlayData.mock 
}
// The app's main entry point
@main
struct ChallengeGameApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  private var challengeManager = ChallengeManager(playData: getPlayData())
  private var gameBoard = GameBoard(size: 1,
                                    topics: Array(MockTopics.mockTopics.prefix(1)),
                                    challenges:[ Challenge.complexMock])
  var body: some Scene {
    WindowGroup {
      ContentView() 
        .environmentObject(challengeManager)
        .environmentObject(gameBoard)
        .onAppear {
                      // Ensure the orientation lock is applied
                      AppDelegate.lockOrientation(.portrait)
                  }
    }
  }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  static var orientationLock = UIInterfaceOrientationMask.portrait

  static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
      self.orientationLock = orientation
      UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      
      // Notify the system to update the orientation
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
          windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
      }
  }

  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
      return AppDelegate.orientationLock
  }
}
