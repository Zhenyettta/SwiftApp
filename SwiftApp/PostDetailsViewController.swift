import UIKit
import Kingfisher

protocol PostDetailsViewControllerDelegate: AnyObject {
    func didUpdatePost(_ post: RedditPost)
}


class PostDetailsViewController: UIViewController {
    
    weak var delegate: PostDetailsViewControllerDelegate?
    
    @IBOutlet private weak var postInfoLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var redditImage: UIImageView!
    @IBOutlet private weak var commentNumLabel: UILabel!
    @IBOutlet private weak var upsLabel: UILabel!
    @IBOutlet private weak var bookmarkButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private static let savedPostsManager = SavedPostsManager()
    
    
    var post: RedditPost!
        
    override func viewDidLoad() {
            super.viewDidLoad()
        _ = UIButton.Configuration.plain()
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        redditImage.isUserInteractionEnabled = true
        redditImage.addGestureRecognizer(doubleTapGesture)
            updateUI(with: post)
        }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        let postURL = "https://www.reddit.com" + (post.permalink ?? "")
        print(postURL)
            
            guard let url = URL(string: postURL) else {
                print("Invalid URL")
                return
            }
            
            let items = [url]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
    }
        
    @IBAction func onSavePress(_ sender: UIButton) {
        post.saved.toggle()
        let iconName = post.saved ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
       
        PostDetailsViewController.savedPostsManager.toggleSavedPost(post: post)
        
        delegate?.didUpdatePost(post)
    
    }

    
    
    private func updateUI(with post: RedditPost) {
        self.titleLabel.text = post.title
        self.postInfoLabel.text = "\(post.author) • \(post.timePassed) • \(post.subreddit_name_prefixed)"
        self.upsLabel.text = "\(post.ups - post.downs)"
        self.commentNumLabel.text = "\(post.num_comments)"
        
        
        let iconName =  PostDetailsViewController.savedPostsManager.isPostSaved(id: post.id) ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        if let urlString = post.fixedImageURL ?? post.galleryFirstImageURL,
           let url = URL(string: urlString) {
            redditImage.kf.setImage(with: url)
        } else {
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func bookmarkPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width: CGFloat = 100
        let height: CGFloat = 120
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width/2, y: height - 30))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        return path
    }

    
    private func showBookmarkAnimation(saved: Bool) {
        let shapePath = bookmarkPath()
        let bookmarkLayer = CAShapeLayer()
        bookmarkLayer.path = shapePath.cgPath
        bookmarkLayer.fillColor = saved ? UIColor.systemBlue.cgColor : UIColor.systemGray.cgColor
        bookmarkLayer.bounds = shapePath.bounds
        bookmarkLayer.position = CGPoint(x: redditImage.bounds.midX, y: redditImage.bounds.midY)
        bookmarkLayer.opacity = 0

        redditImage.layer.addSublayer(bookmarkLayer)

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        fade.duration = 0.4
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.7
        scale.toValue = 1.2
        scale.duration = 0.4
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let group = CAAnimationGroup()
        group.animations = [fade, scale]
        group.duration = 0.8
        bookmarkLayer.add(group, forKey: "bookmarkAnimation")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            bookmarkLayer.removeFromSuperlayer()
        }
    }


    
    @objc private func handleDoubleTap() {
        post.saved.toggle()
        PostDetailsViewController.savedPostsManager.toggleSavedPost(post: post)
        delegate?.didUpdatePost(post)
        
        let iconName = post.saved ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        showBookmarkAnimation(saved: post.saved)
    }
}
