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

  @State var spherePosition: SIMD3<Float> = [0, 1.5, 0]
  @State var sphereLookAt: SIMD3<Float> = [0, 0, 0]
  @State var sphereEntity: Entity?

  var body: some View {
    RealityView { content, attachments in
      content.add(headAnchor)
      
      do {
        let mesh = MeshResource.generateSphere(radius: 1)
        try await mesh.invert()
        let mat = try await ShaderGraphMaterial(named: "/Root/MyMaterial", from: "Immersive.usda", in: realityKitContentBundle)
        let entity = ModelEntity(mesh: mesh, materials: [mat])
        entity.look(at: sphereLookAt, from: spherePosition, relativeTo: nil, forward: .positiveZ)
        content.add(entity)
        sphereEntity = entity
      } catch {
        print("Failed to create sphere: \(error)")
        return;
      }

      if let panel = attachments.entity(for: "sphere-controller") {
        panel.look(at: [0, 0, 0.5], from: [0, -0.25, -0.8],
                   relativeTo: nil, forward: .positiveZ)
        headAnchor.addChild(panel)
      }
    } attachments: {
      Attachment(id: "sphere-controller") {
        PositionControl(title: "Sphere",
                        position: $spherePosition,
                        lookAt: $sphereLookAt)
        .onChange(of: [spherePosition, sphereLookAt]) {
          sphereEntity!.look(at: sphereLookAt, from: spherePosition, relativeTo: nil, forward: .positiveZ)
        }
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
