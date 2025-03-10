import UIKit
import Kingfisher

class PostViewController: UIViewController {
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var redditImage: UIImageView!
    @IBOutlet weak var commentNumLabel: UILabel!
    @IBOutlet weak var upsLabel: UILabel!
    @IBOutlet weak var verticalStack: UIStackView!
    
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
        
        verticalStack.setCustomSpacing(16, after: postInfoLabel)
        
        if let imageUrlString = post.fixedImageURL ?? post.galleryFirstImageURL, let url = URL(string: imageUrlString) {
            redditImage.kf.setImage(with: url)
            redditImage.isHidden = false
            verticalStack.setCustomSpacing(16, after: titleLabel)
        } else {
            redditImage.isHidden = true
        }
    }
}
