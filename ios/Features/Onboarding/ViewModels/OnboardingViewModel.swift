//
//  OnboardingViewModel.swift
//  Phantom
//
//  Created on 2/15/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var isCompleting: Bool = false
    
    let totalPages = 5 // Opening + 4 steps
    
    var currentStep: Int {
        return currentPage // Step 1 = page 1, Step 2 = page 2, etc.
    }
    
    // Whether the current page shows a step indicator
    var showsStepIndicator: Bool {
        return currentPage > 0
    }
    
    // Progress value from 0.0 to 1.0 for the progress bar
    var progress: CGFloat {
        guard currentPage > 0 else { return 0 }
        return CGFloat(currentPage) / 4.0 // 4 steps total
    }
    
    var isFirstPage: Bool {
        currentPage == 0
    }
    
    var isLastPage: Bool {
        currentPage == totalPages - 1
    }
    
    func nextPage() {
        guard currentPage < totalPages - 1 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage += 1
        }
    }
    
    func previousPage() {
        guard currentPage > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage -= 1
        }
    }
    
    func goToPage(_ page: Int) {
        guard page >= 0 && page < totalPages else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = page
        }
    }
    
    // Complete onboarding and auto sign-in
    func completeOnboarding() async {
        isCompleting = true
        let authVM = AuthViewModel()
        await authVM.completeOnboarding()
        isCompleting = false
    }
}
