// FILE: SidebarPinnedSectionHeader.swift
// Purpose: Tappable header for the Pinned section. Hosts the pin glyph, label
//          and chevron that toggles the section open/closed.
// Layer: View Component
// Exports: SidebarPinnedSectionHeader
// Depends on: SwiftUI, HapticButton, SidebarPinIcon, RemodexIcon, AppFont

import SwiftUI

struct SidebarPinnedSectionHeader: View {
    let label: String
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        HapticButton(action: onToggle) {
            HStack(spacing: 8) {
                SidebarPinIcon(style: .header)
                Text(label)
                    .font(AppFont.body(weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer()
                RemodexIcon.image(systemName: "chevron.right")
                    .font(AppFont.subheadline(weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }
}

#if DEBUG
#Preview("Collapsed") {
    SidebarPinnedSectionHeader(label: "Pinned", isExpanded: false, onToggle: {})
}

#Preview("Expanded") {
    SidebarPinnedSectionHeader(label: "Pinned", isExpanded: true, onToggle: {})
}
#endif
