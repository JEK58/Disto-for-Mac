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

    var firstMeasurement = true
    var pasteMode = Mode.paste

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
        pasteMode = .pasteMatchStyle
        updateView()
        savePasteModeSelection(mode: pasteMode)
    }
    @IBAction func setPasteModeToPaste(_ sender: Any) {
        pasteMode = .paste
        updateView()
        savePasteModeSelection(mode: pasteMode)
    }
    @IBAction func measureMenuItem(_ sender: Any) {
        communication.writeByte(data: 0x67) //Initiate new measurement
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

    func updateView() {
        switch pasteMode {
        case .paste: do {
            pasteMenuItem.state = .on
            pasteMatchStyleMenuItem.state = .off
        }
        case .pasteMatchStyle: do {
            pasteMenuItem.state = .off
            pasteMatchStyleMenuItem.state = .on
        }
        }
    }

    private func copyToClipBoard(textToCopy: Float) {
        let buffer = Int(textToCopy*1000) //convert to mm
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(String(buffer), forType: .string)
        print("CopyToClipBoard")
    }

    // Run AppleScript function for pasting
    func runScript(name: String) {
        if let scriptPath = Bundle.main.url(forResource: name, withExtension: nil)?.path {
            let process = Process()
            if process.isRunning == false {
                let pipe = Pipe()
                process.launchPath = "/usr/bin/osascript"
                process.arguments = [scriptPath]
                process.standardError = pipe
                process.launch()
            }
        } else {
            print("Script error")
        }
    }

    func pasteMatchStyle() {
        runScript(name: "pasteAndMatchStyle.scpt")
        print("pasteAndMatchStyle")
    }

    func paste() {
        runScript(name: "paste.scpt")
        print("paste")
    }

    // Needed to allow a script to emulate user input
    func checkAndAskForAssistiveAccess() {
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
        switch pasteMode {
        case .pasteMatchStyle: pasteMatchStyle()
        default: paste()
        }
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

        communication = BluetoothCommunication()
        communication.start(withDelegate: self)

        //Auto connect on start
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            self.communication.startScanning()
            print("Auto connect")
        })

        //Check if accessibility access is allowed
        checkAndAskForAssistiveAccess()

        //Load last paste mode
        pasteMode = loadPasteModeFromUserPrefs()

        updateView()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
