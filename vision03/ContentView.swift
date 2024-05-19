//
//  ContentView.swift
//  vision03
//
//  Created by Max Ng on 5/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissWindow) private var dismissWindow
  
  var body: some View {
    Button {
      Task {
        await openImmersiveSpace(id: "space")
        dismissWindow(id: "main")
      }
    } label: {
      Image(systemName: "power")
        .padding(50)
    }
    .glassBackgroundEffect(in: .circle)
    .controlSize(.extraLarge)
  }
}

#Preview(windowStyle: .volumetric) {
  ContentView()
}
