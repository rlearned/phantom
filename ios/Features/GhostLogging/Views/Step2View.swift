//
//  Step2View.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct Step2View: View {
    @ObservedObject var viewModel: GhostLoggingViewModel
    @State private var searchText = ""
    @State private var navigateToSuccess = false
    @Environment(\.dismiss) var dismiss
    
    let availableTags = [
        "Fear of loss",
        "Not enough confidence",
        "Conflicting Signals",
        "Distracted",
        "Price too high",
        "Timing seems off",
        "Market volatility"
    ]
    
    var filteredTags: [String] {
        if searchText.isEmpty {
            return availableTags
        }
        return availableTags.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 60) {
                // Content
                VStack(spacing: 16) {
                    // Progress
                    ProgressIndicator(currentStep: 2, totalSteps: 2)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why did you hesitate?")
                            .phantomHeadlineStyle()
                        
                        Text("Add up to 3 tags")
                            .font(.phantomBodyMedium)
                            .foregroundColor(.phantomTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Selected Tags Display
                    if !viewModel.selectedTags.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(.phantomTextSecondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.selectedTags, id: \.self) { tag in
                                        HStack(spacing: 8) {
                                            Text(tag)
                                                .font(.phantomBodySmall)
                                                .foregroundColor(.phantomWhite)
                                            
                                            Button(action: {
                                                viewModel.selectedTags.removeAll { $0 == tag }
                                            }) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.phantomWhite)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color.phantomPurple)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.phantomTextPrimary, lineWidth: 1)
                        )
                    } else {
                        // Search Field
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(.phantomTextSecondary)
                            
                            TextField("Search or type reason...", text: $searchText)
                                .font(.phantomBodySmall)
                                .foregroundColor(.phantomTextSecondary)
                        }
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.phantomTextPrimary, lineWidth: 1)
                        )
                    }
                    
                    // Available Tags
                    VStack(spacing: 8) {
                        ForEach(filteredTags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                    .font(.phantomBodyMedium)
                                    .foregroundColor(.phantomTextSecondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    if viewModel.selectedTags.contains(tag) {
                                        viewModel.selectedTags.removeAll { $0 == tag }
                                    } else if viewModel.selectedTags.count < 3 {
                                        viewModel.selectedTags.append(tag)
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: viewModel.selectedTags.contains(tag) ? "checkmark" : "plus")
                                            .font(.system(size: 14))
                                        Text(viewModel.selectedTags.contains(tag) ? "Added" : "Add")
                                            .font(.phantomBodyMedium)
                                    }
                                    .foregroundColor(.phantomPurple)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                Spacer()
                
                // Log Ghost Button
                PhantomButton(
                    title: viewModel.isLoading ? "Logging Ghost..." : "Log Ghost",
                    style: .primary,
                    action: {
                        Task {
//                            await viewModel.createGhost()
//                            if viewModel.createdGhost != nil {
//                                navigateToSuccess = true
//                            }
                            
                            // Below is placeholder for testing
                            navigateToSuccess = true
                        }
                    },
                    isEnabled: !viewModel.isLoading && viewModel.isStep2Valid,
                    fullWidth: true
                )
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.phantomBodySmall)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 64)
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.phantomTextPrimary)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToSuccess) {
            GhostLoggedView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        Step2View(viewModel: GhostLoggingViewModel())
    }
}
