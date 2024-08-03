//
//  mainapp.swift
//  basic
//
//  Created by bill donner on 7/8/24.
//

import SwiftUI
let playDataFileName = "playdata.json"
let starting_size = 3 // Example size, can be 3 to 8
class OrientationLockedViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
 

// Assuming a mock PlayData JSON file in the main bundle


// The app's main entry point
@main
struct ChallengeGameApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  @State var chmgr = ChaMan(playData: PlayData.mock )
  @State var gs = GameState(size: starting_size,
                                   topics:[],// Array(MockTopics.mockTopics.prefix(starting_size)),
                                   challenges:Challenge.mockChallenges)

  var body: some Scene {
    WindowGroup {
      ContentView(gs: gs,chmgr: chmgr)
        .onAppear {
          // Ensure the orientation lock is applied
          assert(gs.checkVsChaMan(chmgr: chmgr))
           // chaMan.checkAllTopicConsistency("App init")
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
