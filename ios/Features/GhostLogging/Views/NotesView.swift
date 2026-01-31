//
//  NotesView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject var viewModel: GhostLoggingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.phantomWhite.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Progress (Ghost Logged)
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
                        Text("Notes")
                            .phantomHeadlineStyle()
                        
                        Text("Any specifics you want to remember?")
                            .font(.phantomBodyMedium)
                            .foregroundColor(.phantomTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Text Editor
                    TextEditor(text: $viewModel.noteText)
                        .font(.phantomBodyMedium)
                        .foregroundColor(.phantomTextTertiary)
                        .padding()
                        .frame(height: 88)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.phantomTextPrimary, lineWidth: 1)
                        )
                        .overlay(
                            Text("E.g. I saw a huge wall at $100 and got scared")
                                .font(.phantomBodyMedium)
                                .foregroundColor(.phantomTextTertiary)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .opacity(viewModel.noteText.isEmpty ? 1 : 0),
                            alignment: .topLeading
                        )
                    
                    Spacer()
                    
                    // Save Button
                    PhantomButton(
                        title: viewModel.isLoading ? "Saving..." : "Save",
                        style: .primary,
                        action: {
                            Task {
                                await viewModel.updateNotes()
                                dismiss()
                            }
                        },
                        isEnabled: !viewModel.noteText.isEmpty && !viewModel.isLoading,
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
    NotesView(viewModel: GhostLoggingViewModel())
}
