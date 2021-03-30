//
//  APIClient.swift
//  SimpleImageFetch
//
//  Created by Radoslav Blasko on 30/03/2021.
//

import Foundation

final class APIClient {
    static func fetchPhotos(page: Int = 2, limit: Int = 100, completion: @escaping (([Photo]) -> Void)) {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)") else {
            fatalError()
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let response: [Photo]
            do {
                response = try decoder.decode([Photo].self, from: data)
            } catch {
                response = []
            }

            DispatchQueue.main.async {
                completion(response)
            }
        }.resume()
    }
}

struct Photo: Decodable {
    let downloadUrl: URL
    let author: String
}
