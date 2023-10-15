//
//  ViewModel.swift
//  AsyncExample
//
//  Created by EstrHuP on 20/9/23.
//

import Foundation
import Combine

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
    
    
    private var cancellables = Set<AnyCancellable>()
    
    func executeRequestWithCombine() {
        guard let characterURL = URL(string: HttpConstants.baseURL) else { return }

        //1. Character call
        URLSession.shared.dataTaskPublisher(for: characterURL)
            .map(\.data)
            .decode(type: CharacterModel.self, decoder: JSONDecoder())
        
            //2. Episode call
            .flatMap { characterModel in
                let firstEpisodeURL = URL(string: characterModel.episode.first!)!
                return URLSession.shared.dataTaskPublisher(for: firstEpisodeURL)
                    .map(\.data)
                    .decode(type: EpisodeModel.self, decoder: JSONDecoder())
                    .map { (characterModel, $0) }
            }
            //3. Location call
            .flatMap { characterModel, episodeModel in
                let characterLocationURL = URL(string: characterModel.locationURL)!
                return URLSession.shared.dataTaskPublisher(for: characterLocationURL)
                    .map(\.data)
                    .decode(type: LocationModel.self, decoder: JSONDecoder())
                    .map { (characterModel, episodeModel, $0) }
            }
            //execute in main thread
            .receive(on: DispatchQueue.main)
        
            //Save data in model (suscribe)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { characterModel, episodeModel, locationModel in
                self.characterBasicInfo = .init(name: characterModel.name,
                                                image: URL(string: characterModel.image),
                                                firstEpisodeTitle: episodeModel.name,
                                                dimension: locationModel.dimension)
            })
            //cancel suscription when view is remove
            .store(in: &cancellables)
    }
}
