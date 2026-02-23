//
//  GhostLoggedView.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct GhostLoggedView: View {
    @ObservedObject var viewModel: GhostLoggingViewModel
    @State private var showingNotes = false
    @State private var showingEmotion = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                
                // Success Message
                Text("Ghost Logged")
                    .font(.custom("DMSans-SemiBold", size: 40))
                    .foregroundColor(.phantomTextPrimary)
                
                Spacer()
                
                // Optional Actions
                VStack(spacing: 16) {
                    // Add Notes
                    Button(action: { showingNotes = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Add Notes")
                                    .font(.phantomBody)
                                    .foregroundColor(.phantomTextPrimary)
                                
                                Text("Any specifics you want to remember?")
                                    .font(.phantomCaption)
                                    .foregroundColor(.phantomTextSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.phantomTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    // Log Emotion
                    Button(action: { showingEmotion = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.circle")
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Log Emotion")
                                    .font(.phantomBody)
                                    .foregroundColor(.phantomTextPrimary)
                                
                                Text("Track your emotional state")
                                    .font(.phantomCaption)
                                    .foregroundColor(.phantomTextSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.phantomTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Spacer()
                
                // Done Button
                PhantomButton(
                    title: "Done",
                    style: .primary,
                    action: {
                        // Navigate back to dashboard
                        // For now, dismiss the entire navigation stack
                        dismiss()
                    },
                    fullWidth: true
                )
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 32)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingNotes) {
            NotesView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEmotion) {
            EmotionView()
        }
    }
}

#Preview {
    GhostLoggedView(viewModel: GhostLoggingViewModel())
}
