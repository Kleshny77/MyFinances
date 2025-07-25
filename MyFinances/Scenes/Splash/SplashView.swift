//
//  SplashView.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import SwiftUI
import Lottie

struct SplashView: View {
    @State private var animationFinished = false
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                LottieView(name: "loading_animation")
                    .frame(width: 200, height: 200)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            animationFinished = true
                            showMainApp = true
                        }
                    }
                
                Text("Загрузка...")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            AccountTabContainer()
        }
    }
}

// MARK: - Lottie View Wrapper
struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
