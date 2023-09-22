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
        self.locationURL = try locationContainter.decode(String.self, forKey: .locationURL)
        
    }
}

struct EpisodeModel: Decodable {
    let id: Int
    let name: String
}

struct LocationModel: Decodable {
    let id: Int
    let name: String
    let dimension: String
}

final class ViewModel {
    
    func executeRequest() {
        guard let characterURL = URL(string: "https://rickandmortyapi.com/api/character/1") else { return }
        
        URLSession.shared.dataTask(with: characterURL) { data, response, error in
            let characterModel = try! JSONDecoder().decode(CharacterModel.self, from: data!)
            print("Character: \(characterModel)")
            
            let firstEpisodeURL = URL(string: characterModel.episode.first!)!
            URLSession.shared.dataTask(with: firstEpisodeURL) { data, response, error in
                let episodeModel = try! JSONDecoder().decode(EpisodeModel.self, from: data!)
                print("Episode: \(episodeModel)")
                
                let characterLocationURL = URL(string: characterModel.locationURL)!
                URLSession.shared.dataTask(with: characterLocationURL) { data, response, error in
                    let locationModel = try! JSONDecoder().decode(LocationModel.self, from: data!)
                    print("Location: \(locationModel)")
                }
                .resume()
            }
            .resume()
        }
        .resume()
    }
}
