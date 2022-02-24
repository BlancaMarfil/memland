//
//  WordData.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 17/1/22.
//

import Foundation

struct WordData: Codable {
    let hits: [Hit]
}

struct Hit: Codable {
    let roms: [Rom]
}

struct Rom: Codable {
    let headword: String
    let headword_full: String
    let arabs: [Arab]
}

struct Arab: Codable {
    let header: String
    let translations: [Translation]
}

struct Translation: Codable {
    let source: String
    let target: String
}
