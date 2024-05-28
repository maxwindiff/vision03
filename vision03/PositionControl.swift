import SwiftUI

struct PositionControl: View {
  var title: String
  @Binding var position: SIMD3<Float>
  @Binding var lookAt: SIMD3<Float>

  var body: some View {
    VStack {
      Text(title).font(.title)
      HStack {
        VStack {
          HStack {
            Slider(value: $position.x, in: -10...10)
            Text(String(format: "%.2f", position.x))
          }
          HStack {
            Slider(value: $position.y, in: -10...10)
            Text(String(format: "%.2f", position.y))
          }
          HStack {
            Slider(value: $position.z, in: -10...10)
            Text(String(format: "%.2f", position.z))
          }
        }
        VStack {
          HStack {
            Slider(value: $lookAt.x, in: -10...10)
            Text(String(format: "%.2f", lookAt.x))
          }
          HStack {
            Slider(value: $lookAt.y, in: -10...10)
            Text(String(format: "%.2f", lookAt.y))
          }
          HStack {
            Slider(value: $lookAt.z, in: -10...10)
            Text(String(format: "%.2f", lookAt.z))
          }
        }
      }
    }
    .padding(15)
    .frame(width: 500)
    .background(.thickMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

#Preview {
  PositionControl(title: "Controller",
                  position: .constant([0, 0, 0]),
                  lookAt: .constant([0, 0, 0]))
}
