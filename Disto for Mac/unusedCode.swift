//
//  unusedCode.swift
//  Disto for Mac


import Foundation

//func deviceHasNewData(_ data: Float) {
//
//    copyToClipBoard(textToCopy: data)
//
//    //Check how to paste the clipboard
//    switch pasteMode {
//    case .pasteMatchStyle: pasteMatchStyle()
//    default: paste()
//    }
//    usleep(50)
//    pressEnterKey()

//        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
//
//        let cmdKey: UInt16 = 0x38
//        let numberThreeKey: UInt16 = 0x14
//        let enterKey: UInt16 = 0x24
//
//        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true)
//        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false)
//        let keyThreeDown = CGEvent(keyboardEventSource: source, virtualKey: numberThreeKey, keyDown: true)
//        let keyThreeUp = CGEvent(keyboardEventSource: source, virtualKey: numberThreeKey, keyDown: false)
//        let enterDown = CGEvent(keyboardEventSource: source, virtualKey: enterKey, keyDown: true)
//        let enterUp = CGEvent(keyboardEventSource: source, virtualKey: enterKey, keyDown: false)
//
//
//        func testShortcut() {
//
//        let loc = CGEventTapLocation.cghidEventTap
//
//        cmdDown?.flags = CGEventFlags.maskCommand
//        cmdUp?.flags = CGEventFlags.maskCommand
//        keyThreeDown?.flags = CGEventFlags.maskCommand
//        keyThreeUp?.flags = CGEventFlags.maskCommand
//        enterDown?.flags = CGEventFlags.maskCommand
//        enterUp?.flags = CGEventFlags.maskCommand

//        cmdDown?.post(tap: loc)
//        keyThreeDown?.post(tap: loc)
//        cmdUp?.post(tap: loc)
//        keyThreeUp?.post(tap: loc)
//            enterDown?.post(tap: loc)
//            enterUp?.post(tap: loc)
//        }
//
//        testShortcut()
// }

//
//        let enterKeyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x24), keyDown: true)
//
//        let enterKeyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x24), keyDown: false)
//
//        enterKeyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
//        usleep(100)
//        enterKeyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
//        usleep(100)

//
//        let event1 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true); // cmd-v down
//        event1?.flags = CGEventFlags.maskCommand
//
//        let event2 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false) // cmd-v up
//        event2?.flags = CGEventFlags.maskCommand
//
//        event1?.post(tap: CGEventTapLocation.cghidEventTap)
//        usleep(100)
//        event2?.post(tap: CGEventTapLocation.cghidEventTap)
//        usleep(100)

//func pasteMatchStyle() {
//    /*Source:
//     https://stackoverflow.com/questions/40096457/swift-macos-how-to-paste-into-another-application
//     Possible Alternative: https://stackoverflow.com/questions/27484330/simulate-keypress-using-swift
//    */
//    // opt-shft-cmd-v down
//    let pasteKeyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x09), keyDown: true)
//    pasteKeyDownEvent?.flags = [CGEventFlags.maskCommand, CGEventFlags.maskShift, CGEventFlags.maskAlternate]
//    // opt-shf-cmd-v up
//    let pasteKeyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(0x09), keyDown: false)
//    pasteKeyUpEvent?.flags = [CGEventFlags.maskCommand, CGEventFlags.maskShift, CGEventFlags.maskAlternate]
//
//    pasteKeyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
//    usleep(100)
//    pasteKeyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
//    usleep(100)
//
//    print("pasteMatchStyle")
//}

//    func checkAndAskForAssistiveAccess() {
//        // https://stackoverflow.com/questions/58675555/how-to-grant-accessibilty-access-in-xcode
//        //get the value for accesibility
//        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
//        //set the options: false means it wont ask
//        //true means it will popup and ask
//        let options = [checkOptPrompt: true]
//        //translate into boolean value
//        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
//
//        if accessEnabled == true {
//            print("Access Granted")
//        } else {
//            print("Access not allowed")
//        }
//    }
