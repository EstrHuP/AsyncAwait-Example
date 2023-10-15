//
//  CharacterInfoModel.swift
//  AsyncExample
//
//  Created by EstrHuP on 22/9/23.
//

import Foundation

struct CharacterInfoModel: Decodable {
    let name: String
    let image: URL?
    let firstEpisodeTitle: String
    let dimension: String
    
    static var empty: Self {
        .init(name: "", image: nil, firstEpisodeTitle: "", dimension: "")
    }
}
