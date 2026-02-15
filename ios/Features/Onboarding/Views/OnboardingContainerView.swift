//
//  OnboardingContainerView.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.phantomWhite.ignoresSafeArea()
            
            // Page content
            pageContent
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(viewModel.currentPage) // Forces view recreation for transition
            
            // Navigation bar (shown on all pages)
            VStack {
                Spacer()
                
                OnboardingNavigationBar(
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    onPrevious: {
                        viewModel.previousPage()
                    },
                    onNext: {
                        if viewModel.isLastPage {
                            // Complete onboarding and auto sign-in
                            Task {
                                await authViewModel.completeOnboarding()
                            }
                        } else {
                            viewModel.nextPage()
                        }
                    }
                )
                .padding(.bottom, 20)
            }
            
            // Loading overlay when completing onboarding
            if viewModel.isCompleting || authViewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.phantomPurple)
                    
                    Text("Setting up your account...")
                        .font(.phantomBodySmall)
                        .foregroundColor(.phantomWhite)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
    }
    
    @ViewBuilder
    private var pageContent: some View {
        switch viewModel.currentPage {
        case 0:
            OnboardingOpeningView(onNext: {
                viewModel.nextPage()
            })
        case 1:
            OnboardingStep1View()
        case 2:
            OnboardingStep2View()
        case 3:
            OnboardingStep3View()
        case 4:
            OnboardingStep4View()
        default:
            OnboardingOpeningView(onNext: {
                viewModel.nextPage()
            })
        }
    }
}

#Preview {
    OnboardingContainerView()
}
