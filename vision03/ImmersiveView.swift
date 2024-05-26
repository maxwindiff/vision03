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

  let startDate = Date.now

  @State var spherePosition: SIMD3<Float> = [0, 1.2, -1.5]
  @State var sphereLookAt: SIMD3<Float> = [0, 0, -1]
  @State var sphereEntity: ModelEntity?

  var body: some View {
    TimelineView(.animation) { context in
      RealityView { content, attachments in
        do {
          let mesh = MeshResource.generateSphere(radius: 2)
          try await mesh.invert()
          let mat = try await ShaderGraphMaterial(named: "/Root/MyMaterial", from: "Immersive.usda", in: realityKitContentBundle)
          let entity = ModelEntity(mesh: mesh, materials: [mat])
          entity.name = "Sphere"
          entity.look(at: sphereLookAt, from: spherePosition, relativeTo: nil, forward: .positiveZ)
          content.add(entity)
          sphereEntity = entity
        } catch {
          print("Failed to create sphere: \(error)")
          return;
        }
        
        //      content.add(headAnchor)
        //      if let panel = attachments.entity(for: "sphere-controller") {
        //        panel.look(at: [0, 0, 0.5], from: [0, -0.25, -0.8],
        //                   relativeTo: nil, forward: .positiveZ)
        //        headAnchor.addChild(panel)
        //      }
      } update: { content, attachments in
        // TODO: can't use @State from here?
        let elapsed = context.date.timeIntervalSince(startDate)
        if let entity = content.entities.first(where: { $0.name == "Sphere" }) as? ModelEntity,
           var mat = entity.model?.materials.first as? ShaderGraphMaterial {
          try? mat.setParameter(name: "Time", value: .float(Float(elapsed)))
          entity.model?.materials = [mat]
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
}

#Preview(immersionStyle: .mixed) {
  ImmersiveView()
}
