//
//  InvestorDNAView.swift
//  Phantom
//
//  this is for demo video, currently functionless
//

import SwiftUI

// MARK: - Investor DNA View

struct InvestorDNAView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - "Investor DNA" Section Header
                HStack {
                    Text("Investor DNA")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                    Spacer()
                }
                .padding(.top, 4)

                // MARK: - Your Investor Profile Card (Radar Chart)
                InvestorProfileCard()

                // MARK: - "Behavioral Insights" Section Header
                HStack {
                    Text("Behavioral Insights")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                    Spacer()
                }

                // MARK: - Behavioral Insight Cards (3 hardcoded)
                BehavioralInsightCard(
                    title: "Elevated Intensity",
                    description: "Over 70% of your ghosts happen during high-stress market moments."
                )

                BehavioralInsightCard(
                    title: "High Caution",
                    description: "You tend to hesitate most on days with elevated market volatility and uncertain signals."
                )

                BehavioralInsightCard(
                    title: "Low Conviction",
                    description: "Most of your ghost trades reflect second-guessing after initial analysis, not lack of research."
                )

                // Bottom padding to clear the tab bar
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(Color(hex: "#F8F8FA"))
    }
}

// MARK: - Investor Profile Card

struct InvestorProfileCard: View {
    var body: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Spacer()
                Text("Your Investor Profile")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1F"))
                Spacer()
            }

            // Radar chart
            RadarChartView(
                axes: ["Intensity", "Momentum", "Conviction", "Caution", "Deliberation", "Sensitivity"],
                values: [0.85, 0.60, 0.45, 0.75, 0.55, 0.65]
            )
            .frame(height: 220)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Radar Chart View

struct RadarChartView: View {
    let axes: [String]
    let values: [Double]  // 0.0 to 1.0 per axis

    var body: some View {
        GeometryReader { geo in
            RadarChartCanvas(
                axes: axes,
                values: values,
                size: geo.size
            )
        }
    }
}

// Extracted to its own struct so the type-checker only sees one layer of complexity
private struct RadarChartCanvas: View {
    let axes: [String]
    let values: [Double]
    let size: CGSize

    private var center: CGPoint { CGPoint(x: size.width / 2, y: size.height / 2) }
    private var radius: Double { min(size.width, size.height) / 2 - 28 }
    private let ringCount = 3

    private let gridColor   = Color(hex: "#DBDEE4")
    private let axisColor   = Color(hex: "#CFD2D7")
    private let fillColor   = Color(hex: "#3803B1").opacity(0.25)
    private let strokeColor = Color(hex: "#3803B1")
    private let labelColor  = Color(hex: "#54555A")

    var body: some View {
        ZStack {
            gridRings
            axisLines
            dataFill
            dataStroke
            centerDot
            axisLabels
        }
    }

    // MARK: Sub-expressions

    private var gridRings: some View {
        ForEach(1...ringCount, id: \.self) { ring in
            let fraction = Double(ring) / Double(ringCount)
            hexagonPath(center: center, radius: radius * fraction, sides: axes.count)
                .stroke(gridColor, lineWidth: 1)
        }
    }

    private var axisLines: some View {
        ForEach(0..<axes.count, id: \.self) { i in
            axisLinePath(index: i)
                .stroke(axisColor, lineWidth: 1)
        }
    }

    private var dataFill: some View {
        dataPolygonPath(center: center, radius: radius)
            .fill(fillColor)
    }

    private var dataStroke: some View {
        dataPolygonPath(center: center, radius: radius)
            .stroke(strokeColor, lineWidth: 2)
    }

    private var centerDot: some View {
        Circle()
            .fill(strokeColor)
            .frame(width: 8, height: 8)
            .position(center)
    }

    private var axisLabels: some View {
        ForEach(0..<axes.count, id: \.self) { i in
            axisLabel(index: i)
        }
    }

    // MARK: Helpers

    private func angle(index: Int) -> Double {
        let degrees = -90.0 + Double(index) * (360.0 / Double(axes.count))
        return degrees * .pi / 180.0
    }

    private func axisLinePath(index i: Int) -> Path {
        let a = angle(index: i)
        let tip = CGPoint(x: center.x + cos(a) * radius,
                          y: center.y + sin(a) * radius)
        return Path { path in
            path.move(to: center)
            path.addLine(to: tip)
        }
    }

    private func hexagonPath(center: CGPoint, radius: Double, sides: Int) -> Path {
        Path { path in
            for i in 0..<sides {
                let a = -90.0 + Double(i) * (360.0 / Double(sides))
                let rad = a * .pi / 180.0
                let pt = CGPoint(x: center.x + cos(rad) * radius,
                                 y: center.y + sin(rad) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
    }

    private func dataPolygonPath(center: CGPoint, radius: Double) -> Path {
        Path { path in
            for i in 0..<axes.count {
                let a = angle(index: i)
                let v = i < values.count ? values[i] : 0.5
                let pt = CGPoint(x: center.x + cos(a) * radius * v,
                                 y: center.y + sin(a) * radius * v)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
    }

    private func axisLabel(index i: Int) -> some View {
        let a = angle(index: i)
        let pos = CGPoint(x: center.x + cos(a) * (radius + 18),
                          y: center.y + sin(a) * (radius + 18))
        return Text(axes[i])
            .font(.system(size: 10, weight: .regular))
            .foregroundColor(labelColor)
            .multilineTextAlignment(.center)
            .fixedSize()
            .position(pos)
    }
}

// MARK: - Behavioral Insight Card

struct BehavioralInsightCard: View {
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundColor(.phantomPurple)
                        .frame(width: 16, height: 16)

                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A1F"))
                }

                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "#1A1A1F").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#8A8A96"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#E8E0FF").opacity(0.08),
                    Color(hex: "#3803B1").opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    InvestorDNAView()
}
