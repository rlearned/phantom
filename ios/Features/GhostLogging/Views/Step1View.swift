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
                            .onChange(of: viewModel.ticker) { _ in
                                viewModel.isTickerValid = false
                            }
                        
                        // Search button
                        Button(action: {
                            Task {
                                await viewModel.validateTicker()
                            }
                        }) {
                            if viewModel.isValidating {
                                ProgressView()
                                    .tint(.phantomTextSecondary)
                            } else {
                                Text("Search")
                                    .font(.phantomCaption)
                                    .foregroundColor(.phantomTextPrimary)
                            }
                        }
                        .disabled(viewModel.ticker.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isValidating)
                    }
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.phantomTextPrimary, lineWidth: 1)
                    )
                    
                    if viewModel.isTickerValid {
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
                    
                    // Price Source Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price")
                            .font(.phantomCaption)
                            .foregroundColor(.phantomTextSecondary)
                        
                        HStack(spacing: 16) {
                            PhantomSmallButton(
                                title: "Current Price",
                                isSelected: viewModel.priceSource == "MARKET",
                                action: {
                                    viewModel.priceSource = "MARKET"
                                    viewModel.intendedPriceText = ""
                                }
                            )
                            .frame(maxWidth: .infinity)
                            
                            PhantomSmallButton(
                                title: "Enter Price",
                                isSelected: viewModel.priceSource == "MANUAL",
                                action: {
                                    viewModel.priceSource = "MANUAL"
                                }
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Manual Price Input (only visible when "Enter Price" selected)
                    if viewModel.priceSource == "MANUAL" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Price per share")
                                .font(.phantomCaption)
                                .foregroundColor(.phantomTextSecondary)
                            
                            TextField("Enter price", text: $viewModel.intendedPriceText)
                                .textFieldStyle(PhantomTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    // Quantity Type Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.phantomCaption)
                            .foregroundColor(.phantomTextSecondary)
                        
                        HStack(spacing: 16) {
                            PhantomSmallButton(
                                title: "Shares",
                                isSelected: viewModel.quantityType == "SHARES",
                                action: {
                                    viewModel.quantityType = "SHARES"
                                    viewModel.quantityText = ""
                                }
                            )
                            .frame(maxWidth: .infinity)
                            
                            PhantomSmallButton(
                                title: "Dollars",
                                isSelected: viewModel.quantityType == "DOLLARS",
                                action: {
                                    viewModel.quantityType = "DOLLARS"
                                    viewModel.quantityText = ""
                                }
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Quantity Input (dynamic label based on quantityType)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.quantityType == "SHARES" ? "Number of shares" : "Dollar amount ($)")
                            .font(.phantomCaption)
                            .foregroundColor(.phantomTextSecondary)
                        
                        TextField(
                            viewModel.quantityType == "SHARES" ? "Enter shares" : "Enter total dollar amount",
                            text: $viewModel.quantityText
                        )
                        .textFieldStyle(PhantomTextFieldStyle())
                        .keyboardType(.decimalPad)
                    }
                    } // end if isTickerValid
                }
                
                Spacer()
                
                // Next Button (only visible when ticker is validated)
                if viewModel.isTickerValid {
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
