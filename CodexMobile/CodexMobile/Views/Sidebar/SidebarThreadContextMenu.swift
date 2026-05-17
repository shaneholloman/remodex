// FILE: SidebarThreadContextMenu.swift
// Purpose: Shared context-menu content for thread-row long-press surfaces in
//          the sidebar and the Archived Chats screen. Each action is optional
//          so each callsite only opts into the entries it supports (e.g. the
//          archived list omits Pin and Rename). All actions are routed through
//          `HapticButton` so the long-press feedback stays consistent.
// Layer: View Component
// Exports: SidebarThreadContextMenu
// Depends on: SwiftUI, HapticButton, RemodexIcon, CodexThread

import SwiftUI

struct SidebarThreadContextMenu: View {
    let thread: CodexThread
    /// Drives the Pin / Unpin label. Ignored when `onPinToggle` is nil.
    var isPinned: Bool = false
    var onCopySessionId: (() -> Void)? = nil
    var onRename: (() -> Void)? = nil
    var onArchiveToggle: (() -> Void)? = nil
    var onPinToggle: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        // `RemodexIcon.menuLabel` keeps Central artwork inside SwiftUI's
        // contextMenu (the closure-based `Label { } icon: { }` path used by
        // `RemodexIcon.label` gets stripped to title-only by the renderer).
        if let onCopySessionId {
            HapticButton(action: onCopySessionId) {
                RemodexIcon.menuLabel("Copy sessionId", systemName: "doc.on.doc")
            }
        }

        if let onRename {
            HapticButton(action: onRename) {
                RemodexIcon.menuLabel("Rename", systemName: "pencil")
            }
        }

        if let onArchiveToggle {
            HapticButton(action: onArchiveToggle) {
                RemodexIcon.menuLabel(
                    thread.syncState == .archivedLocal ? "Unarchive" : "Archive",
                    systemName: thread.syncState == .archivedLocal ? "tray.and.arrow.up" : "archivebox"
                )
            }
        }

        if let onPinToggle, thread.syncState != .archivedLocal, !thread.isSubagent {
            HapticButton(action: onPinToggle) {
                RemodexIcon.menuLabel(
                    isPinned ? "Unpin" : "Pin",
                    systemName: isPinned ? "pin.slash" : "pin"
                )
            }
        }

        if let onDelete {
            HapticButton(role: .destructive, action: onDelete) {
                RemodexIcon.menuLabel("Remove from Phone", systemName: "trash")
            }
        }
    }
}
