import SwiftUI

@main
struct vision03App: App {
  var body: some Scene {
    WindowGroup(id: "main") {
      ContentView()
    }.windowStyle(.volumetric)
    
    ImmersiveSpace(id: "space") {
      ImmersiveView()
    }
  }
}
