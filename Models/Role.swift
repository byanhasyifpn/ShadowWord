//
//  Role.swift
//  ShadowWord
//
//  Created by Byan Hasyif on 24/05/26.
//

import Foundation

enum Role: String, Codable {
    case civilian
    case undercover
    case mrWhite

    var displayName: String {
        switch self {
        case .civilian:
            return "Civilian"
        case .undercover:
            return "Undercover"
        case .mrWhite:
            return "Mr. White"
        }
    }
}
