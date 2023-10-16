//
//  Utils.swift
//  AsyncExample
//
//  Created by EstrHuP on 16/10/23.
//

import Foundation

class Utils {
    
    static var shared: Utils = Utils()
    
    func performDataTask<T: Decodable>(with url: URL, completionHandler: @escaping (T) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                if let error = error {
                    // Manejar el error de red aquí
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data else {
                    // Manejar el caso en el que los datos sean nulos
                    print("Data is nil")
                    return
                }
                
                let model = try JSONDecoder().decode(T.self, from: data)
                completionHandler(model)
            } catch {
                // Manejar errores de decodificación JSON
                print("Error decoding \(T.self): \(error)")
            }
        }.resume()
    }
}
