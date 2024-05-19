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

public extension MeshResource {
  func invert() async throws {
    var replaced = contents
    replaced.models = .init(replaced.models.map { body in
      return MeshResource.Model(id: body.id,
                                parts: body.parts.map { part in
        if let normals = part.normals, let indices = part.triangleIndices {
          var inverted = part
          inverted.normals = .init(normals.map { $0 * -1.0 })
          inverted.triangleIndices = .init(indices.reversed())
          return inverted
        }
        return part
      })
    })
    try await replace(with: replaced)
  }
}

struct ImmersiveView: View {
  let session = ARKitSession()
  let worldTracking = WorldTrackingProvider()
  let headAnchor = AnchorEntity(.head)
  
  @State var panel0: ViewAttachmentEntity?
  @State var sphereEntity: Entity?
  
  var body: some View {
    RealityView { content, attachments in
      content.add(headAnchor)
      
      let mesh = MeshResource.generateSphere(radius: 1)
      try! await mesh.invert()
      
      let mat = try! await ShaderGraphMaterial(named: "/Root/MyMaterial", from: "Immersive.usda", in: realityKitContentBundle)
      sphereEntity = ModelEntity(mesh: mesh, materials: [mat])
      sphereEntity!.look(at: [0, 0, 0], from: [0, 1.5, -3],
                         relativeTo: nil, forward: .positiveZ)
      content.add(sphereEntity!)

      if let panel = attachments.entity(for: "sphere-controller") {
        panel.look(at: [0, 0, 0.5], from: [0, -0.25, -0.8],
                   relativeTo: nil, forward: .positiveZ)
        headAnchor.addChild(panel)
        panel0 = panel
      }
    } attachments: {
      Attachment(id: "sphere-controller") {
        PositionControl(title: "Sphere",
                        position: [0, 1.5, -3],
                        lookAt: [0, 0, 0],
                        onChange: { position, lookAt in
          sphereEntity!.look(at: lookAt, from: position, relativeTo: nil, forward: .positiveZ)
        })
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
