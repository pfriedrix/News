

import UIKit

class FavotiesViewController: UIViewController {
    
    var images = [String: UIImage?]()
    var articles = [Article]() {
        didSet {
            loadImages()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                self.indicator.alpha = 0
            }
        }
    }
    
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "articleCell")
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
       
        
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        articles = ArticleRepository.shared.fetchAll()
    }


    override func viewDidAppear(_ animated: Bool) {
        articles = ArticleRepository.shared.fetchAll()
    }
    
    func loadImages() {
        articles.forEach { article in
            
            guard let urlToImage = article.urlToImage else {
                print("no url image")
                return
            }
            
            if images.keys.first(where: {$0 == article.urlToImage}) == nil {
                DispatchQueue.main.async {
                    if let url = URL(string: urlToImage) {
                        do {
                            let data = try Data(contentsOf: url, options: .mappedIfSafe)
                            self.images[urlToImage] = UIImage(data: data)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
        }
    }
}


extension FavotiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.item]
        cell.sourceLabel.text = article.source?.name
        cell.authorLabel.text = article.author
        cell.discLabel.text = article.articleDescription
        cell.titleLabel.text = article.title
        cell.saveButton.isHidden = true
        cell.article = article
        cell.articleImage.image = UIImage(named: "Flag")
        guard let urlToImage = article.urlToImage, let image = images[urlToImage] else {
            print("no image")
            return cell
        }
        cell.articleImage.image = image
        return cell
    }

}

extension FavotiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.item]
        let vc = WebViewController(article.url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
