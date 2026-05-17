// FILE: SidebarConnectionStatusBadge.swift
// Purpose: Compact capsule pill that surfaces the live relay connection phase
//          at the leading edge of the sidebar (top-left), just below the
//          brand header. Hides itself when the relay is fully `.connected`
//          so the happy-path sidebar stays uncluttered.
// Layer: View Component
// Exports: SidebarConnectionStatusBadge
// Depends on: SwiftUI, CodexConnectionPhase, AppFont

import SwiftUI

struct SidebarConnectionStatusBadge: View {
    let connectionPhase: CodexConnectionPhase

    @State private var dotPulse = false
    @State private var connectionAttemptStartedAt: Date?

    var body: some View {
        if connectionPhase == .connected {
            EmptyView()
        } else {
            // Self-contained layout: leading-aligned within its row, with
            // horizontal + bottom padding baked in. The connected branch above
            // is a pure EmptyView so the surrounding stack truly collapses to
            // zero height when there's nothing to show (avoiding a phantom
            // padded slot under the search field on the happy path).
            badge
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .onAppear {
                    if connectionPhase == .connecting {
                        connectionAttemptStartedAt = Date()
                    }
                    dotPulse = isBusy
                }
                .onChange(of: connectionPhase) { _, phase in
                    connectionAttemptStartedAt = phase == .connecting ? Date() : nil
                    dotPulse = isBusy
                }
        }
    }

    private var badge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusDotColor)
                .frame(width: 6, height: 6)
                .scaleEffect(dotPulse ? 1.4 : 1.0)
                .opacity(dotPulse ? 0.6 : 1.0)
                .animation(
                    isBusy
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: dotPulse
                )

            Text(statusLabel)
                .font(AppFont.caption(weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color(.systemBackground)))
        .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Connection status: \(statusLabel)"))
    }

    private var isBusy: Bool {
        switch connectionPhase {
        case .connecting, .loadingChats, .syncing:
            return true
        case .offline, .connected:
            return false
        }
    }

    private var statusDotColor: Color {
        switch connectionPhase {
        case .connecting, .loadingChats, .syncing:
            return .orange
        case .connected:
            return .green
        case .offline:
            return Color(.tertiaryLabel)
        }
    }

    private var statusLabel: String {
        switch connectionPhase {
        case .connecting:
            guard let connectionAttemptStartedAt else { return "Connecting" }
            let elapsed = Date().timeIntervalSince(connectionAttemptStartedAt)
            if elapsed >= 12 { return "Still connecting…" }
            return "Connecting"
        case .loadingChats:
            return "Loading chats"
        case .syncing:
            return "Syncing"
        case .connected:
            return "Connected"
        case .offline:
            return "Offline"
        }
    }
}

#if DEBUG
#Preview("Offline") {
    SidebarConnectionStatusBadge(connectionPhase: .offline)
        .padding()
}

#Preview("Connecting") {
    SidebarConnectionStatusBadge(connectionPhase: .connecting)
        .padding()
}

#Preview("Loading chats") {
    SidebarConnectionStatusBadge(connectionPhase: .loadingChats)
        .padding()
}

#Preview("Connected (hidden)") {
    SidebarConnectionStatusBadge(connectionPhase: .connected)
        .padding()
        .border(.red)
}
#endif
