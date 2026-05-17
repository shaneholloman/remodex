// FILE: SidebarProjectSectionHeader.swift
// Purpose: Tappable header for a project section. Hosts the project glyph and
//          label on the leading edge and a trailing "new chat in project"
//          composer button. Exposes context-menu hooks for archive/delete.
// Layer: View Component
// Exports: SidebarProjectSectionHeader
// Depends on: SwiftUI, HapticButton, SidebarThreadGroup, RemodexIcon,
//             CodexWorktreeIcon, AppFont

import SwiftUI

struct SidebarProjectSectionHeader: View {
    let group: SidebarThreadGroup
    let isExpanded: Bool
    let isConnected: Bool
    let isCreatingThread: Bool
    let onToggle: () -> Void
    let onCreate: () -> Void
    var onArchive: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            HapticButton(action: onToggle) {
                HStack(spacing: 8) {
                    leadingIcon
                    Text(group.label)
                        .font(AppFont.body(weight: .regular))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contextMenu {
                if let onArchive {
                    HapticButton(action: onArchive) {
                        RemodexIcon.menuLabel("Archive Project", systemName: "archivebox")
                    }
                }

                if let onDelete {
                    HapticButton(role: .destructive, action: onDelete) {
                        Label("Remove from Phone", systemImage: "trash")
                    }
                }
            }

            HStack(spacing: 8) {
                HapticButton(hapticStyle: .medium, action: onCreate) {
                    RemodexIcon.image(systemName: "square.and.pencil", size: 20, weight: .medium)
                        .foregroundStyle(.secondary.opacity(0.6))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .disabled(!isConnected || isCreatingThread)
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 4)
        .padding(.top, 18)
        .padding(.bottom, 0)
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if group.iconSystemName == "arrow.triangle.branch" {
            CodexWorktreeIcon(pointSize: 16, weight: .medium)
                .foregroundStyle(.primary)
        } else {
            RemodexIcon.image(systemName: resolvedIconName)
                .font(AppFont.body(weight: .medium))
                .foregroundStyle(.primary)
                .contentTransition(.symbolEffect(.replace))
        }
    }

    private var resolvedIconName: String {
        if isExpanded, group.iconSystemName == "folder" {
            return "folder.fill"
        }
        return group.iconSystemName
    }
}
