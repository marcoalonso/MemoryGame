//
//  LaunchAnimationView.swift
//  MemoryGame
//
//  Created by Marco Alonso Rodriguez on 16/12/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct LaunchAnimationView: View {
    @State private var navigateToGame = false // Controla la navegación

    var body: some View {
        ZStack {
            // Fondo blanco
            Color.white
                .edgesIgnoringSafeArea(.all)

            // Animación GIF ajustada a toda la pantalla
            VStack {
                Spacer()
                SDAnimatedImageViewRepresentable(name: "demo")
                    .frame(width: 200, height: 200)
                Spacer()
            }

            // Navegación a MemoryGameView
            NavigationLink(
                destination: MemoryGameView()
                    .navigationBarBackButtonHidden(true) // Oculta el botón de retroceso
                    .navigationBarHidden(true), // Oculta la barra de navegación
                isActive: $navigateToGame,
                label: { EmptyView() }
            )
        }
        .onAppear {
            // Esperar 3 segundos antes de navegar
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                navigateToGame = true
            }
        }
        .navigationBarHidden(true) // Oculta la barra de navegación en LaunchAnimationView
    }
}

// Representación de SDAnimatedImageView en SwiftUI
struct SDAnimatedImageViewRepresentable: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        if let path = Bundle.main.path(forResource: name, ofType: "gif") {
            imageView.sd_setImage(with: URL(fileURLWithPath: path))
        }
        imageView.contentMode = .scaleAspectFit // Asegura que el GIF llene el área
        return imageView
    }

    func updateUIView(_ uiView: SDAnimatedImageView, context: Context) {}
}
#Preview {
    LaunchAnimationView()
}
