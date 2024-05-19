import SwiftUI

struct PositionControl: View {
  var title: String
  @State var position: SIMD3<Float> = [0, 0, 0]
  @State var lookAt: SIMD3<Float> = [0, 0, 0]
  var onChange: (_ position: SIMD3<Float>, _ lookAt: SIMD3<Float>) -> Void
  
  var body: some View {
    VStack {
      Text(title).font(.title)
      HStack {
        VStack {
          HStack {
            Slider(value: $position.x, in: -5...5)
            Text(String(format: "%.2f", position.x))
          }
          HStack {
            Slider(value: $position.y, in: -5...5)
            Text(String(format: "%.2f", position.y))
          }
          HStack {
            Slider(value: $position.z, in: -5...5)
            Text(String(format: "%.2f", position.z))
          }
        }
        VStack {
          HStack {
            Slider(value: $lookAt.x, in: -5...5)
            Text(String(format: "%.2f", lookAt.x))
          }
          HStack {
            Slider(value: $lookAt.y, in: -5...5)
            Text(String(format: "%.2f", lookAt.y))
          }
          HStack {
            Slider(value: $lookAt.z, in: -5...5)
            Text(String(format: "%.2f", lookAt.z))
          }
        }
      }
    }
    .padding(15)
    .frame(width: 500)
    .background(.thickMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .onChange(of: [position, lookAt]) {
      print(position, lookAt)
      onChange(position, lookAt)
    }
  }
}

#Preview {
  PositionControl(title: "Controller", onChange: { position, lookAt in })
}
