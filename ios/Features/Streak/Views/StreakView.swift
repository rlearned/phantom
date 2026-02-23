//
//  StreakView.swift
//  Phantom
//
//  Created on 2/22/2026.
//

import SwiftUI

// TODO: Implement the full Streak feature.
// This view should include:
//
// 1. CURRENT STREAK CARD:
//    - Display the user's current consecutive check-in streak (in days).
//    - Fetch from backend: GET /streak or from DashboardSummary.streakDays.
//    - Show a fire/flame icon alongside the streak number.
//
// 2. MONTHLY CALENDAR:
//    - Show a calendar grid for the current month (Sun–Sat columns).
//    - Color each day:
//        - Green (#C5FFC5) = checked in that day
//        - Red (#FFC8C8) = missed that day
//        - Default = future day (no fill)
//    - Include a legend: "= Checked In" and "= Missed".
//    - Data source: backend check-in history endpoint.
//
// 3. "CHECKED IN TODAY" BANNER:
//    - Show a green card ("Checked in today!") if the user has already checked in today.
//    - Otherwise show a "Check In" button to record today's check-in.
//    - POST to backend: /streak/checkin endpoint.
//
// 4. MILESTONES & REWARDS:
//    - Show a scrollable list of streak milestones (e.g., 3 days, 7 days, 30 days).
//    - Each milestone card shows: badge name, description, progress bar, locked/unlocked state.
//    - Unlocked badges appear in green; locked badges appear greyed out.
//    - Fetch from backend: GET /achievements or /streak/milestones.
//
// 5. "YOUR INVESTING COMMITMENT JOURNEY" SUBTITLE:
//    - Motivational subtitle below the page title.

struct StreakView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Placeholder flame icon
            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundColor(Color.orange.opacity(0.7))

            VStack(spacing: 8) {
                Text("Streak")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                Text("Your investing commitment journey")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.phantomTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Placeholder streak card
            VStack(spacing: 4) {
                Text("Current Streak")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.phantomTextPrimary)

                HStack(alignment: .bottom, spacing: 4) {
                    // TODO: Replace "7" with real streak value from backend
                    Text("7")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.phantomTextPrimary)
                    Text("days")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.phantomTextPrimary)
                        .padding(.bottom, 6)
                }

                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.horizontal, 36)

            Text("Full streak calendar, milestones & rewards\ncoming soon.")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.phantomTextSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color.phantomWhite)
    }
}

#Preview {
    StreakView()
}
