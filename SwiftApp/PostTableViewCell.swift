import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var redditImage: UIImageView!
    @IBOutlet weak var commentNumLabel: UILabel!
    @IBOutlet weak var upsLabel: UILabel!
    
    static let identifier = "PostTableViewCell"
    
    private var postUrl: String?
    
    
    
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    
    func configure(with post: RedditPost) {
        self.titleLabel.text = post.title
        self.postInfoLabel.text = "\(post.author) • \(post.timePassed)"
        self.upsLabel.text = "\(post.ups - post.downs)"
        self.commentNumLabel.text = "\(post.num_comments)"
        
        
        if let urlString = post.fixedImageURL ?? post.galleryFirstImageURL,
           let url = URL(string: urlString) {
            redditImage.kf.setImage(with: url)
            redditImage.isHidden = false
        } else {
            redditImage.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        redditImage.kf.cancelDownloadTask()
        redditImage.image = nil
    }
}
