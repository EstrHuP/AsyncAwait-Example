//
//  ViewModel.swift
//  Callback_vs_AsynAwait
//
//  Created by EstrHuP on 20/9/23.
//

import Foundation

final class ViewModel: ObservableObject {
    
    @Published var characterBasicInfo: CharacterInfoModel = .empty
    
    func executeRequestWithCallback() {
        guard let characterURL = URL(string: HttpConstants.baseURL) else { return }
        
        // 1. Character call
        URLSession.shared.dataTask(with: characterURL) { data, response, error in
            let characterModel = try! JSONDecoder().decode(CharacterModel.self, from: data!)
            print("Character: \(characterModel)")
            
            // 2. First episode call
            let firstEpisodeURL = URL(string: characterModel.episode.first!)!
            URLSession.shared.dataTask(with: firstEpisodeURL) { data, response, error in
                let episodeModel = try! JSONDecoder().decode(EpisodeModel.self, from: data!)
                print("Episode: \(episodeModel)")
                
                // 3. Location call
                let characterLocationURL = URL(string: characterModel.locationURL)!
                URLSession.shared.dataTask(with: characterLocationURL) { data, response, error in
                    let locationModel = try! JSONDecoder().decode(LocationModel.self, from: data!)
                    print("Location: \(locationModel)")
                    
                    // Save character data in empty model
                    DispatchQueue.main.async {
                        self.characterBasicInfo = .init(name: characterModel.name,
                                                        image: URL(string: characterModel.image),
                                                        firstEpisodeTitle: episodeModel.name,
                                                        dimension: locationModel.dimension)
                    }
                    
                }
                // 3.
                .resume()
            }
            // 2.
            .resume()
        }
        // 1.
        .resume()
    }
    
    func executeRequestWithAsyncAwait() async {
        guard let characterURL = URL(string: HttpConstants.baseURL) else { return }

        // 1. Character call
        let (data, _) = try! await URLSession.shared.data(from: characterURL)
        let characterModel = try! JSONDecoder().decode(CharacterModel.self, from: data)
        print("Character: \(characterModel)")
        
        // 2. First episode call
        let firstEpisodeURL = URL(string: characterModel.episode.first!)!
        let (dataEpisode, _) = try! await URLSession.shared.data(from: firstEpisodeURL)
        let episodeModel = try! JSONDecoder().decode(EpisodeModel.self, from: dataEpisode)
        print("Episode: \(episodeModel)")
        
        // 3. Location call
        let locationURL = URL(string: characterModel.locationURL)!
        let (dataLocation, _) = try! await URLSession.shared.data(from: locationURL)
        let locationModel = try! JSONDecoder().decode(LocationModel.self, from: dataLocation)
        print("Location: \(locationModel)")

        // Save character data in empty model
        DispatchQueue.main.async {
            self.characterBasicInfo = .init(name: characterModel.name,
                                            image: URL(string: characterModel.image),
                                            firstEpisodeTitle: episodeModel.name,
                                            dimension: locationModel.dimension)
        }
    }
}
