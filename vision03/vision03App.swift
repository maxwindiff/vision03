//
//  vision03App.swift
//  vision03
//
//  Created by Max Ng on 5/18/24.
//

import SwiftUI

@main
struct vision03App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
