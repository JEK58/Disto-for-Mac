//
//  AppDelegate.swift
//  Disto for Mac
//
//  Created by Stephan Schöpe on 08.08.2019.
//  Copyright © 2019 Stephan Schöpe. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BluetoothCommunicationDelegate {

    var communication: BluetoothCommunication!
    private var pasteMode = "Paste" // PasteMatchStyle or Paste

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var connect: NSMenuItem!

    @IBOutlet weak var pasteMatchStyleMenuItem: NSMenuItem!
    @IBOutlet weak var pasteMenuItem: NSMenuItem!

    @IBAction func connect(_ sender: Any) {
        communication.startScanning()
    }

    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func setPasteModeToPasteMatchStyle(_ sender: Any) {
        pasteMode = "PasteMatchStyle"
        self.pasteMenuItem.state = .off
        self.pasteMatchStyleMenuItem.state = .on
    }
    @IBAction func setPasteModeToPaste(_ sender: Any) {
        pasteMode = "Paste"
        self.pasteMenuItem.state = .on
        self.pasteMatchStyleMenuItem.state = .off
    }
    func bluetoothDidUpdateState() {
        self.connect.title = "BT off"
        self.connect.isEnabled = false
    }

    func bluetoothIsPoweredOn() {
        self.connect.title = "Connect"
        self.connect.isEnabled = true
    }

    func deviceDidConnect() {
        self.connect.title = "Connected"
        self.connect.isEnabled = false
    }

    func deviceDidDisconnect() {
        self.connect.isEnabled = true
        self.connect.title = "Connect"

    }

    private func copyToClipBoard(textToCopy: Float) {
        let buffer = Int(textToCopy*1000) //convert to mm
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(String(buffer), forType: .string)
        print("CopyToClipBoard")
    }

    private func pasteMatchStyle() {
        /*Source:
         https://stackoverflow.com/questions/40096457/swift-macos-how-to-paste-into-another-application
         Possible Alternative: https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
        */
        // opt-shft-cmd-v down
        let pasteKeyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x09), keyDown: true)
        pasteKeyDownEvent?.flags = [CGEventFlags.maskCommand, CGEventFlags.maskShift, CGEventFlags.maskAlternate]
        // opt-shf-cmd-v up
        let pasteKeyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x09), keyDown: false)
        pasteKeyUpEvent?.flags = [CGEventFlags.maskCommand, CGEventFlags.maskShift, CGEventFlags.maskAlternate]

        pasteKeyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        usleep(100)
        pasteKeyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        usleep(100)

        print("pasteMatchStyle")

    }

    private func paste() {

        let event1 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true); // cmd-v down
        event1?.flags = CGEventFlags.maskCommand

        let event2 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false) // cmd-v up
        event2?.flags = CGEventFlags.maskCommand

        event1?.post(tap: CGEventTapLocation.cghidEventTap)
        usleep(100)
        event2?.post(tap: CGEventTapLocation.cghidEventTap)
        usleep(100)

        print("paste")
    }

    private func pressEnterKey() {

        let enterKeyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x24), keyDown: true)

        let enterKeyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x24), keyDown: false)

        enterKeyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        usleep(100)
        enterKeyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        usleep(100)
        print("Enter")
    }

    private func checkAccess() {
        // https://stackoverflow.com/questions/58675555/how-to-grant-accessibilty-access-in-xcode
        //get the value for accesibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        //set the options: false means it wont ask
        //true means it will popup and ask
        let options = [checkOptPrompt: true]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)

        if accessEnabled == true {
            print("Access Granted")
        } else {
            print("Access not allowed")
        }
    }

    func deviceHasNewData(_ data: Float) {

        copyToClipBoard(textToCopy: data)

        //Check how to paste the clipboard
        if pasteMode == "PasteMatchStyle" {
                pasteMatchStyle()
        } else {
            paste()
            }

        pressEnterKey()
     }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        //Set menu bar icon
        statusItem.menu = statusMenu
        statusMenu.autoenablesItems = false
        if let button = statusItem.button {
            button.image = #imageLiteral(resourceName: "laser_symbol")
            //button.title = "LDM"
        }

        //Set paste mode
        pasteMode = "Paste"
        pasteMenuItem.state = .on
        pasteMatchStyleMenuItem.state = .off

        communication = BluetoothCommunication()
        communication.start(withDelegate: self)

        //Auto connect on start
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            self.communication.startScanning()
            print("Auto connect")
        })

        // Check if accessibility access is allowed
        checkAccess()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
