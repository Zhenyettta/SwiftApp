import Foundation

struct RedditResponse: Codable {
    let data: RedditData
}

struct RedditData: Codable {
    let children: [RedditChild]
    let after: String?
}

struct RedditChild: Codable {
    let data: RedditPost
}

struct RedditPost: Codable {
    let author: String
    let subreddit_name_prefixed: String
    let created_utc: Double
    let title: String
    let url_overridden_by_dest: String?
    let ups: Int
    let downs: Int
    let num_comments: Int
    let is_gallery: Bool?
    let media_metadata: [String: RedditMedia]?
    let gallery_data: RedditGallery?
    
    
    var saved: Bool {
           return Bool.random()
       }

    var timePassed: String {
        let interval = Date().timeIntervalSince(Date(timeIntervalSince1970: created_utc))
        let hours = Int(interval / 3600)
        return hours < 24 ? "\(hours)h" : "\(hours / 24)d"
    }

    var fixedImageURL: String? {
        url_overridden_by_dest?.replacingOccurrences(of: "&amp;", with: "&")
    }
    
    var galleryFirstImageURL: String? {
        guard let mediaMetadata = media_metadata, let galleryItems = gallery_data?.items else { return nil }
        for item in galleryItems {
            if let bestImageURL = mediaMetadata[item.media_id]?.s.u {
                return bestImageURL.replacingOccurrences(of: "&amp;", with: "&")
            }
        }
        return nil
    }

}

struct RedditGaglleryItem: Codable {
    let media_id: String
}

struct RedditGallery: Codable {
    let items: [RedditGaglleryItem]
}

struct RedditMedia: Codable {
    let s: RedditMediaSource
}

struct RedditMediaSource: Codable {
    let u: String?
}

final class APIService {
    static func fetchPosts(subreddit: String, limit: Int, after: String? = nil, completion: @escaping (Result<[RedditPost], Error>) -> Void) {
        var components = URLComponents(string: "https://www.reddit.com/r/\(subreddit)/top.json")!
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: after))
        }
        components.queryItems = queryItems
        guard let url = components.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let redditResponse = try JSONDecoder().decode(RedditResponse.self, from: data)
                completion(.success(redditResponse.data.children.map { $0.data }))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
