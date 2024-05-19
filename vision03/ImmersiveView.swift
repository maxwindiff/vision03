//
//  ImmersiveView.swift
//  vision03
//
//  Created by Max Ng on 5/18/24.
//

import ARKit
import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
  let session = ARKitSession()
  let worldTracking = WorldTrackingProvider()
  
  @State var headAnchor = AnchorEntity(.head)
  
  // Panel0 (config)
  @State var panel0: ViewAttachmentEntity?
  @State var panel0Position: SIMD3<Float> = [0, -0.25, -0.8]
  @State var panel0LookAt: SIMD3<Float> = [0, 0, 0.5]
  
  @State var panel1Position: SIMD3<Float> = [0, 1, -3]
  @State var panel1LookAt: SIMD3<Float> = [0, 0, 0]
  
  @State var sphereEntity: Entity?
  
  var body: some View {
    RealityView { content, attachments in
      content.add(headAnchor)
      
      if let panel = attachments.entity(for: "panel0") {
        panel.look(at: panel0LookAt, from: panel0Position, relativeTo: nil, forward: .positiveZ)
        headAnchor.addChild(panel)
        panel0 = panel
      }
      
      let mesh = MeshResource.generateSphere(radius: 1)
      sphereEntity = ModelEntity(mesh: mesh)
      sphereEntity!.look(at: panel1LookAt, from: panel1Position, relativeTo: nil, forward: .positiveZ)
      content.add(sphereEntity!)
    } attachments: {
      Attachment(id: "panel0") {
        VStack {
          Text("Panel 1 Settings").font(.title)
          HStack {
            VStack {
              HStack {
                Slider(value: $panel1Position.x, in: -5...5)
                Text(String(format: "%.2f", panel1Position.x))
              }
              HStack {
                Slider(value: $panel1Position.y, in: -5...5)
                Text(String(format: "%.2f", panel1Position.y))
              }
              HStack {
                Slider(value: $panel1Position.z, in: -5...5)
                Text(String(format: "%.2f", panel1Position.z))
              }
            }
            VStack {
              HStack {
                Slider(value: $panel1LookAt.x, in: -2...2)
                Text(String(format: "%.2f", panel1LookAt.x))
              }
              HStack {
                Slider(value: $panel1LookAt.y, in: -2...2)
                Text(String(format: "%.2f", panel1LookAt.y))
              }
              HStack {
                Slider(value: $panel1LookAt.z, in: -2...2)
                Text(String(format: "%.2f", panel1LookAt.z))
              }
            }
          }
        }
        .onChange(of: [panel1Position, panel1LookAt]) {
          sphereEntity!.look(at: panel1LookAt, from: panel1Position, relativeTo: nil, forward: .positiveZ)
        }
        .padding(15)
        .frame(width: 500)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
      }
    }
    .task {
      try? await session.run([worldTracking])
    }
  }
}

#Preview(immersionStyle: .mixed) {
  ImmersiveView()
}
