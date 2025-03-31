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
    let id: String
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
    let url: String
    var saved: Bool
    let permalink: String

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
    private static let savedPostsManager = SavedPostsManager()
    static func fetchPosts(
            subreddit: String,
            limit: Int,
            after: String? = nil,
            completion: @escaping (Result<(posts: [RedditPost], after: String?), Error>) -> Void
        ) {
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
                        var posts = redditResponse.data.children.map { $0.data }
                        for index in 0..<posts.count {
                                                var post = posts[index]
                            post.saved = self.savedPostsManager.isPostSaved(id: post.id)
                            posts[index] = post
                                            }
                        let after = redditResponse.data.after
                        completion(.success((posts, after)))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            }
        }



class SavedPostsManager {
    
    private let fileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("savedPosts.json")
    }
    
    func loadSavedPosts() -> [RedditPost]? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                return try decoder.decode([RedditPost].self, from: data)
            } catch {
                print("Error loading saved posts: \(error)")
            }
        }
        return nil
    }
    
    func saveSavedPosts(_ posts: [RedditPost]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(posts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving saved posts: \(error)")
        }
    }
    
    func toggleSavedPost(post: RedditPost) {
        var savedPosts = loadSavedPosts() ?? []
        
        if let index = savedPosts.firstIndex(where: { $0.id == post.id }) {
            savedPosts.remove(at: index)
        } else {
            savedPosts.append(post)
        }
        
        saveSavedPosts(savedPosts)
    }
    
    func isPostSaved(id: String) -> Bool {
        guard let savedPosts = loadSavedPosts() else { return false }
        return savedPosts.contains(where: { $0.id == id })
    }
}
