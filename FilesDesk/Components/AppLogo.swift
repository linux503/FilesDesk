import SwiftUI

struct AppLogo: View {
    var size: CGFloat = 64

    var body: some View {
        Image("AppLogo")
            .resizable()
            .interpolation(.high)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.223, style: .continuous))
            .shadow(color: Color.black.opacity(0.14), radius: size * 0.08, y: size * 0.04)
            .accessibilityLabel("FilesDesk")
    }
}
