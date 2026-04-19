//
//  EmotionView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct EmotionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GhostLoggingViewModel

    // Compass canvas geometry. Keep these in sync with the .frame(width:height:) below.
    private let canvasSize: CGFloat = 328
    private let dotSize: CGFloat = 24
    private var minDotCoord: CGFloat { dotSize / 2 }                       // 12
    private var maxDotCoord: CGFloat { canvasSize - dotSize / 2 }          // 316
    private var center: CGPoint { CGPoint(x: canvasSize / 2, y: canvasSize / 2) }

    @State private var dotPosition: CGPoint
    @GestureState private var dragOffset = CGSize.zero
    @State private var isSaving = false

    init(viewModel: GhostLoggingViewModel) {
        self.viewModel = viewModel
        // Restore previously saved position if the user reopens the sheet, otherwise center.
        let canvas: CGFloat = 328
        let dot: CGFloat = 24
        let usableMin: CGFloat = dot / 2
        let usableMax: CGFloat = canvas - dot / 2
        let usableRange = usableMax - usableMin

        let initialX: CGFloat
        if let sentiment = viewModel.emotionSentiment {
            initialX = usableMin + CGFloat(sentiment) * usableRange
        } else {
            initialX = canvas / 2
        }

        let initialY: CGFloat
        if let stress = viewModel.emotionStress {
            // y-axis: top = high stress, bottom = calm. So stress 1.0 → top (small y).
            initialY = usableMax - CGFloat(stress) * usableRange
        } else {
            initialY = canvas / 2
        }

        _dotPosition = State(initialValue: CGPoint(x: initialX, y: initialY))
    }

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
                                .frame(width: 1, height: canvasSize)
                        }

                        HStack {
                            Rectangle()
                                .fill(Color.phantomBorderPurple)
                                .frame(width: canvasSize, height: 1)
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
                        .frame(height: canvasSize)

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
                        .frame(width: canvasSize)

                        // Draggable Dot
                        Circle()
                            .fill(Color.phantomPurple)
                            .frame(width: dotSize, height: dotSize)
                            .shadow(color: Color.phantomPurple.opacity(0.2), radius: 2, x: 0, y: 0)
                            .position(dotPosition)
                            .offset(dragOffset)
                            .gesture(
                                DragGesture()
                                    .updating($dragOffset) { value, state, _ in
                                        state = value.translation
                                    }
                                    .onEnded { value in
                                        let newX = min(max(dotPosition.x + value.translation.width, minDotCoord), maxDotCoord)
                                        let newY = min(max(dotPosition.y + value.translation.height, minDotCoord), maxDotCoord)
                                        dotPosition = CGPoint(x: newX, y: newY)
                                    }
                            )
                    }
                    .frame(width: canvasSize, height: canvasSize)

                    Spacer()

                    // Save Button
                    PhantomButton(
                        title: isSaving ? "Saving…" : "Save",
                        style: .primary,
                        action: {
                            Task { await saveAndDismiss() }
                        },
                        fullWidth: true
                    )
                    .disabled(isSaving)
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

    /// Maps the 2D dot position into normalized (sentiment, stress) on [0,1] and persists.
    /// - sentiment: x-axis. left = fear (0), right = greed (1)
    /// - stress: y-axis inverted. top = high stress (1), bottom = calm (0)
    private func saveAndDismiss() async {
        let usableRange = maxDotCoord - minDotCoord
        let sentiment = Double((dotPosition.x - minDotCoord) / usableRange)
        let stress    = Double((maxDotCoord - dotPosition.y) / usableRange)

        isSaving = true
        await viewModel.saveEmotion(stress: stress, sentiment: sentiment)
        isSaving = false
        dismiss()
    }
}

#Preview {
    EmotionView(viewModel: GhostLoggingViewModel())
}
