import SwiftUI
import Foundation
import Combine

@main
struct MyApp: App {
    
    @ObservedObject var userSettings = UserSettings()
    var body: some Scene {
        WindowGroup {
            if !userSettings.isUsedBefore {
                WelcomeView()
            } else {
                NavigationViewController()
            }
        }
    }
}

class UserSettings: ObservableObject {
    @Published var isUsedBefore: Bool
    
    init() {
        print("In init \(UserDefaults.standard.bool(forKey: "firstTime"))")
        self.isUsedBefore = UserDefaults.standard.bool(forKey: "firstTime")
    }
}
