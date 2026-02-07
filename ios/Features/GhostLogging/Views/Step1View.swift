//
//  Step1View.swift
//  Phantom
//
//  Created on 1/30/2026.
//

import SwiftUI

struct Step1View: View {
    @StateObject private var viewModel = GhostLoggingViewModel()
    @State private var navigateToStep2 = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            VStack(spacing: 60) {
                // Content
                VStack(spacing: 16) {
                    // Progress
                    ProgressIndicator(currentStep: 1, totalSteps: 2)
                    
                    // Title
                    HStack {
                        Text("What did you almost trade?")
                            .phantomHeadlineStyle()
                        Spacer()
                    }
                    
                    // Ticker Search
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.phantomTextSecondary)
                        
                        TextField("SEARCH TICKER (E.G. NVDA)", text: $viewModel.ticker)
                            .font(.phantomBodySmall)
                            .foregroundColor(.phantomTextSecondary)
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.phantomTextPrimary, lineWidth: 1)
                    )
                    
                    // Direction Selection
                    HStack(spacing: 16) {
                        PhantomSmallButton(
                            title: "Buy",
                            isSelected: viewModel.direction == "BUY",
                            action: {
                                viewModel.direction = "BUY"
                            }
                        )
                        .frame(maxWidth: .infinity)
                        
                        PhantomSmallButton(
                            title: "Sell",
                            isSelected: viewModel.direction == "SELL",
                            action: {
                                viewModel.direction = "SELL"
                            }
                        )
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Share Size Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of shares")
                            .font(.phantomCaption)
                            .foregroundColor(.phantomTextSecondary)
                        
                        TextField("Enter quantity", text: $viewModel.shareSizeText)
                            .textFieldStyle(PhantomTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                Spacer()
                
                // Next Button
                PhantomButton(
                    title: "Next",
                    style: .primary,
                    action: {
                        navigateToStep2 = true
                    },
                    isEnabled: viewModel.isStep1Valid,
                    fullWidth: true
                )
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
        .navigationDestination(isPresented: $navigateToStep2) {
            Step2View(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        Step1View()
    }
}
