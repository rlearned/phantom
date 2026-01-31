//
//  GhostListView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct GhostListView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let ghosts = viewModel.ghosts, !ghosts.isEmpty {
                        ForEach(ghosts) { ghost in
                            NavigationLink(destination: GhostDetailView(ghost: ghost)) {
                                GhostListItem(ghost: ghost)
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "ghost")
                                .font(.system(size: 64))
                                .foregroundColor(.phantomTextSecondary)
                            
                            Text("No ghosts yet")
                                .font(.phantomHeadline)
                                .foregroundColor(.phantomTextPrimary)
                            
                            Text("Start logging your missed trades")
                                .font(.phantomBodyMedium)
                                .foregroundColor(.phantomTextSecondary)
                        }
                        .padding(.top, 64)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.phantomBodySmall)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
        .navigationTitle("All Ghosts")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
    }
}

// Ghost Detail View
struct GhostDetailView: View {
    let ghost: Ghost
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ghost.ticker)
                                .font(.custom("DMSans-Bold", size: 40))
                                .foregroundColor(.phantomTextPrimary)
                            
                            HStack {
                                Circle()
                                    .fill(ghost.direction == "BUY" ? Color.green : Color.red)
                                    .frame(width: 12, height: 12)
                                
                                Text(ghost.direction)
                                    .font(.phantomBody)
                                    .foregroundColor(.phantomTextPrimary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "$%.2f", ghost.intendedPrice))
                                .font(.phantomHeadline)
                                .foregroundColor(.phantomTextPrimary)
                            
                            Text(String(format: "%.2f shares", ghost.intendedSize))
                                .font(.phantomBodyMedium)
                                .foregroundColor(.phantomTextSecondary)
                        }
                    }
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Logged", value: ghost.createdDate.formatted())
                        DetailRow(label: "Status", value: ghost.status)
                        DetailRow(label: "Market Price (at log)", value: String(format: "$%.2f", ghost.loggedQuote.price))
                    }
                    
                    // Hesitation Tags
                    if let tags = ghost.hesitationTags, !tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hesitation Reasons")
                                .font(.phantomBody)
                                .foregroundColor(.phantomTextPrimary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.phantomBodyMedium)
                                        .foregroundColor(.phantomWhite)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.phantomPurple)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = ghost.noteText {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.phantomBody)
                                .foregroundColor(.phantomTextPrimary)
                            
                            Text(notes)
                                .font(.phantomBodyMedium)
                                .foregroundColor(.phantomTextSecondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.phantomLightPurple)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Detail Row Component
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.phantomBodyMedium)
                .foregroundColor(.phantomTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.phantomBodyMedium)
                .foregroundColor(.phantomTextPrimary)
        }
    }
}

// Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        GhostListView()
    }
}
