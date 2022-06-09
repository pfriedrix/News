

import UIKit

class ArticleTableViewCell: UITableViewCell {

    var isSave = false
    
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discLabel: UILabel!
    
    @IBOutlet weak var articleImage: UIImageView!

    @IBOutlet weak var saveButton: UIButton!
    
    var article: Article?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func save(_ sender: Any) {
        isSave.toggle()
        if isSave {
            saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            guard let article = article else {
                return
            }
            
            ArticleRepository.shared.save(article)
            
        } else {
            saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            
        }
    }
}
