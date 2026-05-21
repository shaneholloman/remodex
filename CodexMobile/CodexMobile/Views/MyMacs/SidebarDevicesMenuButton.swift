// FILE: SidebarDevicesMenuButton.swift
// Purpose: Circular glass menu button pinned at the leading edge of the
//          sidebar's bottom action bar. Opens a UIKit context menu listing the
//          paired devices visible in the menu (filtered by the per-device
//          visibility preference), with a divider and a "Devices settings"
//          entry that surfaces the management sheet.
// Layer: View Component
// Exports: SidebarDevicesMenuButton
// Depends on: SwiftUI, UIKit, CodexService, MyDevicesPresentation,
//             UIKitMenuButton, RemodexIcon, AdaptiveGlassModifier, HapticFeedback

import SwiftUI
import UIKit

struct SidebarDevicesMenuButton: View {
    @Environment(CodexService.self) private var codex

    let diameter: CGFloat
    let isSwitchingMac: Bool
    let switchingMacDeviceId: String?
    let onSelectDevice: (String) -> Void
    let onOpenDevicesSettings: () -> Void

    init(
        diameter: CGFloat = 44,
        isSwitchingMac: Bool,
        switchingMacDeviceId: String?,
        onSelectDevice: @escaping (String) -> Void,
        onOpenDevicesSettings: @escaping () -> Void
    ) {
        self.diameter = diameter
        self.isSwitchingMac = isSwitchingMac
        self.switchingMacDeviceId = switchingMacDeviceId
        self.onSelectDevice = onSelectDevice
        self.onOpenDevicesSettings = onOpenDevicesSettings
    }

    var body: some View {
        UIKitMenuButton(
            label: { labelContent },
            menu: { buildMenu() }
        )
        .frame(width: diameter, height: diameter)
        .accessibilityLabel("Devices")
    }

    private var labelContent: some View {
        RemodexIcon.image(
            systemName: MyDevicesPresentation.macIconSystemName,
            size: 18,
            weight: .semibold
        )
        .foregroundStyle(.primary)
        .frame(width: diameter, height: diameter)
        .adaptiveGlass(.regular, isInteractive: true, in: Circle())
        .contentShape(Circle())
    }

    private func buildMenu() -> UIMenu {
        let devices = MyDevicesPresentation
            .rowModels(from: codex, switchingDeviceId: switchingMacDeviceId)
            .filter { $0.isVisibleInMenu }

        let deviceItems: [UIMenuElement] = devices.map { device in
            UIAction(
                title: device.primaryName,
                subtitle: deviceSubtitle(for: device),
                image: deviceImage(for: device),
                attributes: deviceAttributes(for: device),
                state: device.isCurrent ? .on : .off
            ) { _ in
                guard !device.isCurrent, !isSwitchingMac else { return }
                HapticFeedback.shared.triggerImpactFeedback(style: .light)
                onSelectDevice(device.deviceId)
            }
        }

        let devicesSection = UIMenu(
            title: "",
            options: [.displayInline],
            children: deviceItems.isEmpty
                ? [emptyPlaceholderAction()]
                : deviceItems
        )

        let settingsSection = UIMenu(
            title: "",
            options: [.displayInline],
            children: [
                UIAction(
                    title: "Devices settings",
                    image: RemodexIcon.menuUIImage(systemName: "slider.horizontal.3")
                ) { _ in
                    HapticFeedback.shared.triggerImpactFeedback(style: .light)
                    onOpenDevicesSettings()
                },
            ]
        )

        return UIMenu(title: "", children: [devicesSection, settingsSection])
    }

    private func emptyPlaceholderAction() -> UIAction {
        let action = UIAction(
            title: "No paired devices yet",
            image: nil
        ) { _ in }
        action.attributes = [.disabled]
        return action
    }

    private func deviceSubtitle(for device: MyDeviceRowModel) -> String? {
        let subtitle = device.menuSubtitle
        return subtitle.isEmpty ? nil : subtitle
    }

    private func deviceImage(for device: MyDeviceRowModel) -> UIImage? {
        RemodexIcon.menuUIImage(systemName: MyDevicesPresentation.macIconSystemName)
    }

    private func deviceAttributes(for device: MyDeviceRowModel) -> UIMenuElement.Attributes {
        if device.isSwitching || (isSwitchingMac && !device.isCurrent) {
            return [.disabled]
        }
        return []
    }
}
