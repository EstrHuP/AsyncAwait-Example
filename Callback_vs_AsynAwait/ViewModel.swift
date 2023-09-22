//
//  ViewModel.swift
//  Callback_vs_AsynAwait
//
//  Created by EstrHuP on 20/9/23.
//

import Foundation

struct CharacterModel: Decodable {
    let id: Int
    let name: String
    let image: String
    let episode: [String]
    let locationName: String
    let locationURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case episode
        case location
        case locationURL = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CharacterModel.CodingKeys> = try decoder.container(keyedBy: CharacterModel.CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: CharacterModel.CodingKeys.id)
        self.name = try container.decode(String.self, forKey: CharacterModel.CodingKeys.name)
        self.image = try container.decode(String.self, forKey: CharacterModel.CodingKeys.image)
        self.episode = try container.decode([String].self, forKey: CharacterModel.CodingKeys.episode)
        let locationContainter = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        self.locationName = try locationContainter.decode(String.self, forKey: .name)
        self.locationURL = try container.decode(String.self, forKey: .locationURL)
        
    }
}

final class ViewModel {
    
    func executeRequest() {
        guard let characterURL = URL(string: "https://rickandmortyapi.com/api/character/1") else { return }
        
        URLSession.shared.dataTask(with: characterURL) { data, response, error in
            let characterModel = try! JSONDecoder().decode(CharacterModel.self, from: data!)
            print(characterModel)
        }.resume()
    }
}
