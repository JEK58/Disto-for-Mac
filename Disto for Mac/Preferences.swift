//
//  Preferences.swift
//  Disto for Mac
//
//  Created by Stephan Schöpe on 14.10.2020.
//  Copyright © 2020 Stephan Schöpe. All rights reserved.
//

import Foundation

enum Mode: Codable {

    case paste, pasteMatchStyle

    private enum CodingKeys: CodingKey {
        case paste, pasteMatchStyle
    }
    private struct InvalidDataError: Error {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
            if try container.decodeIfPresent(
              Bool.self,
              forKey: .paste
            ) == true { // This is an optional, hence `== true`.
              self = .paste
            } else if try container.decodeIfPresent(
              Bool.self,
              forKey: .pasteMatchStyle
            ) == true {
              self = .pasteMatchStyle
            } else {
              throw InvalidDataError()
            }
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .paste: try container.encode(true, forKey: .paste)
        case .pasteMatchStyle: try container.encode(true, forKey: .pasteMatchStyle)
        }
    }
}

let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let archiveURL = documentsDirectory.appendingPathComponent("DistoForMac").appendingPathExtension("plist")

let propertyListEncoder = PropertyListEncoder()

func savePasteModeSelection(mode: Mode) {
    let encodedMode = try? propertyListEncoder.encode(mode)
    try? encodedMode?.write(to: archiveURL)
    print(archiveURL)
}

func loadPasteModeFromUserPrefs() -> Mode {
    let propertyListDecoder = PropertyListDecoder()
    if let retrievedNotesData = try? Data(contentsOf: archiveURL),
       let decodedMode = try? propertyListDecoder.decode(Mode.self, from: retrievedNotesData) {
        print(decodedMode)
        return decodedMode
    }
    //Fallback mode if no default present
    return .paste
}
