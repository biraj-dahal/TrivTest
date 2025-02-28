//
//  StringExtensions.swift
//  TrivTest
//
//  Created by Biraj Dahal on 2/28/25.
//

import Foundation

extension String {
    func decodedHTML() -> String {
        let decoded = self.replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&#039;", with: "'")
        return decoded
    }
}
