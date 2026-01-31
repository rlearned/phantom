//
//  EmotionView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct EmotionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var dotPosition = CGPoint(x: 164, y: 164) // Center position
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.phantomWhite.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Progress
                    HStack(spacing: 16) {
                        Text("GHOST LOGGED")
                            .font(.phantomCaption)
                            .foregroundColor(.phantomTextPrimary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.phantomTextSecondary.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(8)
                                
                                Rectangle()
                                    .fill(Color.phantomPurple)
                                    .frame(width: geometry.size.width, height: 8)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .frame(height: 20)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How did it feel?")
                            .phantomHeadlineStyle()
                        
                        Text("Track your emotional state")
                            .font(.phantomBodyMedium)
                            .foregroundColor(.phantomTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Emotion Compass
                    ZStack {
                        // Background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.phantomLightPurple)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.phantomBorderPurple, lineWidth: 1)
                            )
                        
                        // Axes
                        VStack {
                            Rectangle()
                                .fill(Color.phantomBorderPurple)
                                .frame(width: 1, height: 328)
                        }
                        
                        HStack {
                            Rectangle()
                                .fill(Color.phantomBorderPurple)
                                .frame(width: 328, height: 1)
                        }
                        
                        // Labels
                        VStack {
                            Text("HIGH STRESS")
                                .font(.phantomCaption)
                                .foregroundColor(.phantomTextPrimary)
                                .padding(8)
                            
                            Spacer()
                            
                            Text("CALM")
                                .font(.phantomCaption)
                                .foregroundColor(.phantomTextPrimary)
                                .padding(8)
                        }
                        .frame(height: 328)
                        
                        HStack {
                            Text("FEAR")
                                .font(.phantomCaption)
                                .foregroundColor(.phantomTextPrimary)
                                .padding(8)
                                .frame(width: 38)
                            
                            Spacer()
                            
                            Text("GREED")
                                .font(.phantomCaption)
                                .foregroundColor(.phantomTextPrimary)
                                .padding(8)
                                .frame(width: 38)
                        }
                        .frame(width: 328)
                        
                        // Draggable Dot
                        Circle()
                            .fill(Color.phantomPurple)
                            .frame(width: 24, height: 24)
                            .shadow(color: Color.phantomPurple.opacity(0.2), radius: 2, x: 0, y: 0)
                            .position(dotPosition)
                            .offset(dragOffset)
                            .gesture(
                                DragGesture()
                                    .updating($dragOffset) { value, state, _ in
                                        state = value.translation
                                    }
                                    .onEnded { value in
                                        // Calculate new position within bounds
                                        let newX = min(max(dotPosition.x + value.translation.width, 12), 316)
                                        let newY = min(max(dotPosition.y + value.translation.height, 12), 316)
                                        dotPosition = CGPoint(x: newX, y: newY)
                                    }
                            )
                    }
                    .frame(width: 328, height: 328)
                    
                    Spacer()
                    
                    // Back Button
                    PhantomButton(
                        title: "Back",
                        style: .primary,
                        action: {
                            dismiss()
                        },
                        fullWidth: true
                    )
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.phantomTextPrimary)
                }
            }
        }
    }
}

#Preview {
    EmotionView()
}
