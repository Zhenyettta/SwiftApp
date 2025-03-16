import UIKit
import Kingfisher

class PostViewController: UIViewController {
    
    @IBOutlet private weak var postInfoLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var redditImage: UIImageView!
    @IBOutlet private weak var commentNumLabel: UILabel!
    @IBOutlet private weak var upsLabel: UILabel!
    @IBOutlet private weak var verticalStack: UIStackView!
    @IBOutlet private weak var bookmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIService.fetchPosts(subreddit: "ios", limit: 1) { [weak self] result in
            DispatchQueue.main.async {
                guard let post = try? result.get().first else { return }
                
                self?.updateUI(with: post)
            }
        }
    }
    
    private func updateUI(with post: RedditPost) {
        titleLabel.text = post.title
        postInfoLabel.text = "\(post.author) • \(post.timePassed) • \(post.subreddit_name_prefixed)"
        upsLabel.text = (post.ups - post.downs).description
        commentNumLabel.text = post.num_comments.description
        
        let iconName = post.saved ? "bookmark.fill" : "bookmark"
                bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
    
        
        if let imageUrlString = post.fixedImageURL ?? post.galleryFirstImageURL, let url = URL(string: imageUrlString) {
            redditImage.kf.setImage(with: url)
            redditImage.isHidden = false
        } else {
            redditImage.isHidden = true
        }
    }
}
