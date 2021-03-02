//
//  Preferences.swift
//  Disto for Mac


import Foundation

enum PasteMode: String {
    case paste = "paste"
    case pasteMatchStyle = "pasteAndMatchStyle"
    }

func savePasteModeSelection(mode: PasteMode) {
    let defaults = UserDefaults.standard
    defaults.set(mode.rawValue, forKey: "pasteMode")
}

func loadPasteModeFromUserDefaults() -> PasteMode {
    let defaults = UserDefaults.standard
    if let pasteModeRawValue = defaults.object(forKey: "pasteMode") as? String {
        let pasteMode = PasteMode(rawValue: pasteModeRawValue)!
        print(pasteMode)
        return pasteMode
    }
    //Fallback mode if no user defaults present
   return .paste
}
