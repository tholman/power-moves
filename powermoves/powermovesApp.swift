import SwiftUI

@main
struct PowerMovesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No visible WindowGroup to prevent the app window from popping up
        Settings { }
    }
}

import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var showPercentage = true
    var countdownTimer: Timer?
    var batteryPercentage = 2

    func applicationDidFinishLaunching(_ notification: Notification) {
        let colors: [NSColor] = [.gray]
        let colorIndex = 0

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            updateStatusBar(button: button, batteryPercentage: batteryPercentage, color: colors[colorIndex])
        }

        // Request notification permissions
        requestNotificationPermissions()

        // Add menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Percentage", action: #selector(togglePercentage), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Show Sleep Notification", action: #selector(showSleepNotification), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "1 Minute Countdown", action: #selector(start1MinuteCountdown), keyEquivalent: "1"))
        menu.addItem(NSMenuItem(title: "2 Minute Countdown", action: #selector(start2MinuteCountdown), keyEquivalent: "2"))
        menu.addItem(NSMenuItem(title: "5 Minute Countdown", action: #selector(start5MinuteCountdown), keyEquivalent: "5"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    func updateStatusBar(button: NSStatusBarButton, batteryPercentage: Int, color: NSColor) {
        let configuration = NSImage.SymbolConfiguration(pointSize: 20, weight: .light)
            .applying(.init(paletteColors: [color]))
        let image = NSImage(systemSymbolName: "battery.0", accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration)

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image

        let targetHeight: CGFloat = 15
        if let imageSize = image?.size {
            let aspectRatio = imageSize.width / imageSize.height
            imageAttachment.bounds = CGRect(x: 0, y: -3.5, width: targetHeight * aspectRatio, height: targetHeight)
        }

        let imageString = NSAttributedString(attachment: imageAttachment)

        if showPercentage {
            let percentageString = "\(batteryPercentage)% "
            let attributedString = NSMutableAttributedString(string: percentageString, attributes: [
                .foregroundColor: NSColor.textColor,
                .font: NSFont.systemFont(ofSize: 11, weight: .medium),
                .baselineOffset: 0
            ])
            attributedString.append(imageString)
            button.attributedTitle = attributedString
        } else {
            button.attributedTitle = imageString
        }
    }

    @objc func togglePercentage() {
        showPercentage.toggle()
        if let button = statusItem?.button {
            updateStatusBar(button: button, batteryPercentage: batteryPercentage, color: .gray)
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    @objc func showSleepNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Low Battery Warning"
        content.body = "Your Mac will sleep soon unless plugged into a power outlet."
        content.sound = UNNotificationSound.default
        content.userInfo = ["customData": "lowBattery"]

        let request = UNNotificationRequest(identifier: "lowBatteryWarning", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notification permissions: \(error)")
            }
        }
    }

    @objc func start1MinuteCountdown() {
        startCountdown(duration: 1)
    }

    @objc func start2MinuteCountdown() {
        startCountdown(duration: 2)
    }

    @objc func start5MinuteCountdown() {
        startCountdown(duration: 5)
    }

    func startCountdown(duration: Int) {
        batteryPercentage = 5 // Instantly draw to 5%
        if let button = statusItem?.button {
            updateStatusBar(button: button, batteryPercentage: batteryPercentage, color: .gray)
        }

        countdownTimer?.invalidate() // Stop any existing timer

        let decrementInterval = Double(duration * 60) / 4.0 // Calculate interval for decrementing battery percentage

        countdownTimer = Timer.scheduledTimer(withTimeInterval: decrementInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.batteryPercentage -= 1

            if let button = self.statusItem?.button {
                self.updateStatusBar(button: button, batteryPercentage: self.batteryPercentage, color: .gray)
            }

            if self.batteryPercentage <= 1 {
                timer.invalidate()
                self.showSleepNotification()
            }
        }
    }
}
