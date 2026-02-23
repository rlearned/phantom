//
//  StartLogView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct StartLogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingGhostFlow = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.phantomWhite.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                    
                    VStack(spacing: 8) {
                        // Product Name
                        Text("Phantom")
                            .phantomTitleStyle()
                        
                        // Tagline
                        Text("Log the trades you didn't take")
                            .phantomSubheadlineStyle()
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Start Log Button
                    PhantomButton(
                        title: "Start Log",
                        style: .primary,
                        action: {
                            showingGhostFlow = true
                        },
                        fullWidth: true
                    )
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
            }
            .navigationDestination(isPresented: $showingGhostFlow) {
                Step1View(onDone: { dismiss() })
            }
        }
    }
}

#Preview {
    StartLogView()
}
