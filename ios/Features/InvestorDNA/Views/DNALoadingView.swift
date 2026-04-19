//
//  DNALoadingView.swift
//  Phantom
//
//  Interactive loading screen for the Investor DNA profile generation.
//  Designed to keep the user engaged while the backend (and LLM) compute
//  the profile — modeled after background-check-style progress flows
//  with rotating phase labels and a smooth asymptotic progress bar.
//

import SwiftUI

struct DNALoadingView: View {
    @ObservedObject var viewModel: InvestorDNAViewModel

    // The labels rotate as `viewModel.loadingPhase` advances 0…5.
    private let phaseLabels: [String] = [
        "Pulling your ghost trades…",
        "Analyzing hesitation patterns…",
        "Mapping emotional volatility…",
        "Scoring conviction signals…",
        "Cross-referencing market sensitivity…",
        "Compiling your behavioral profile…"
    ]

    private var currentPhase: String {
        let idx = max(0, min(phaseLabels.count - 1, viewModel.loadingPhase))
        return phaseLabels[idx]
    }

    private var percentText: String {
        "\(Int((viewModel.loadingProgress * 100).rounded()))%"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated DNA emblem
            DNAHelixEmblem()
                .frame(width: 120, height: 120)
                .padding(.bottom, 32)

            // Title
            Text("Generating your Investor DNA")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1F"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)

            Text("This usually takes a few seconds")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "#8A8A96"))
                .padding(.bottom, 28)

            // Progress bar + percent
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#E8E0FF"))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#7E5BEC"), Color(hex: "#5B37D4")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(viewModel.loadingProgress), height: 8)
                            .animation(.linear(duration: 0.15), value: viewModel.loadingProgress)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text(percentText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#5B37D4"))
                    Spacer()
                    Text("\(viewModel.loadingPhase + 1) of \(phaseLabels.count)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: "#8A8A96"))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)

            // Rotating phase label
            HStack(spacing: 10) {
                PulsingDot()
                Text(currentPhase)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#3D2494"))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .id(currentPhase) // force re-animation on label change
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(Color(hex: "#5B37D4").opacity(0.06))
            .cornerRadius(12)
            .padding(.horizontal, 32)
            .animation(.easeInOut(duration: 0.35), value: currentPhase)

            // Phase trail — six little checkmarks/dots that progressively light up
            PhaseTrail(currentPhase: viewModel.loadingPhase, total: phaseLabels.count)
                .padding(.top, 24)
                .padding(.horizontal, 32)

            Spacer()

            Text("Analyzing locally and against your full ghost history")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(hex: "#C5C5CD"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
    }
}

// MARK: - Animated DNA Helix Emblem

private struct DNAHelixEmblem: View {
    @State private var rotate = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#5B37D4").opacity(0.08))
                .scaleEffect(pulse ? 1.08 : 0.95)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

            Circle()
                .stroke(Color(hex: "#5B37D4").opacity(0.18), lineWidth: 1.5)
                .scaleEffect(0.85)

            // Two orbiting dots — abstract DNA strand feel
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "#5B37D4"))
                    .frame(width: 8, height: 8)
                    .offset(y: -38)
                    .rotationEffect(.degrees(Double(i) * 60.0 + (rotate ? 360 : 0)))
            }
            .animation(.linear(duration: 4.0).repeatForever(autoreverses: false), value: rotate)

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color(hex: "#5B37D4"))
        }
        .onAppear {
            rotate = true
            pulse = true
        }
    }
}

// MARK: - Pulsing Dot (for the active phase indicator)

private struct PulsingDot: View {
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(Color(hex: "#5B37D4"))
            .frame(width: 8, height: 8)
            .scaleEffect(pulse ? 1.4 : 0.9)
            .opacity(pulse ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

// MARK: - Phase Trail (six progressing tick marks)

private struct PhaseTrail: View {
    let currentPhase: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                ZStack {
                    Circle()
                        .fill(i <= currentPhase ? Color(hex: "#5B37D4") : Color(hex: "#E8E0FF"))
                        .frame(width: 18, height: 18)

                    if i < currentPhase {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    } else if i == currentPhase {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: currentPhase)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DNALoadingView(viewModel: InvestorDNAViewModel())
}
