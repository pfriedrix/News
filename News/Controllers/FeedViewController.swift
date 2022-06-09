

import UIKit
import Combine

class FeedViewController: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableArticles: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var isSort: Bool = false
    var isLoading = false {
        didSet {
            if isLoading == false {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.indicatorView.stopAnimating()
                    self.indicatorView.alpha = 0
                }
            }
        }
    }
    
    var query: String?
    
    var country: String? {
        get {
            UserDefaults.standard.string(forKey: "country")
        } set {
            UserDefaults.standard.set(newValue, forKey: "country")
        }
    }
    
    var category: String? {
        get {
            UserDefaults.standard.string(forKey: "category")
        } set {
            UserDefaults.standard.set(newValue, forKey: "category")
        }
    }
    
    var sources: String? {
        get {
            UserDefaults.standard.string(forKey: "sources")
        } set {
            UserDefaults.standard.set(newValue, forKey: "sources")
        }
    }
    
    var endpoint = ""
    
    var images = [String: UIImage?]()
    var page = 1
    
    var articles = [Article]() {
        didSet {
            loadImages()
            DispatchQueue.main.async {
                self.tableArticles.reloadData()
            }
           
        }
    }
    
    lazy var search = UISearchController()
    let refreshControl = UIRefreshControl()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.searchBar.delegate = self
        search.searchBar.sizeToFit()
        self.navigationItem.searchController = search
        
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
        }
        
        
        endpoint = "top-headlines"
        country = "us"
        
        setUpBarButton()
        setUpTableView()
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableArticles.addSubview(refreshControl)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        country = nil
        query = searchBar.text
        articles = []
        page = 1
        
        fetch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        page = 1
        query = nil
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetch()
    }
    
    func setUpBarButton() {
        let rightBarButtonItem = UIButton()
        rightBarButtonItem.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        rightBarButtonItem.setImage(UIImage(named: isSort ? "listDown" : "listUp"), for: .normal)
        rightBarButtonItem.addTarget(self, action: #selector(sortByDate), for: .touchUpInside)
        
        
        let barItem = UIBarButtonItem(customView: rightBarButtonItem)
        barItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        barItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        self.navigationItem.rightBarButtonItem = barItem
        
        let leftBarItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), style: .plain, target: self, action: #selector(openFilter))
        
        navigationItem.leftBarButtonItem = leftBarItem
        
    }
    
    @objc func openFilter() {
        articles = []
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "filters")
        self.present(vc, animated: true)
    }
    
    @objc func sortByDate() {
        
        isSort.toggle()
        
        self.articles.sort(by: { first, second -> Bool in
            guard let firstDate = dateFormatter.date(from: first.publishedAt) else { return false }
            guard let secondDate = dateFormatter.date(from: second.publishedAt) else { return false}
            if isSort {
                return firstDate < secondDate
            } else {
                return firstDate > secondDate
            }
        })
        
        DispatchQueue.main.async {
            self.tableArticles.reloadData()
        }
        
        setUpBarButton()
    }
    
    func setUpTableView() {
        
        tableArticles.delegate = self
        tableArticles.dataSource = self
        tableArticles.prefetchDataSource = self
        
        let nib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        tableArticles.register(nib, forCellReuseIdentifier: "articleCell")
        fetch()
    }
    
    func fetch() {
        guard !isLoading else {
            return
        }
        indicatorView.alpha = 1
        indicatorView.startAnimating()
        isLoading = true
        NewsApi.shared.fetch(endpoint: endpoint, pageSize: 10, page: page, country: country, q: query, sources: sources, category: category) { result in
            switch result {
            case .success(let articles):
                self.articles.append(contentsOf: articles)
                self.page += 1
            case .failure(let error):
                print(error.localizedDescription)

            }
            self.isLoading = false
            DispatchQueue.main.async {
                self.tableArticles.reloadData()
            }


        }
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

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.item]
        let vc = WebViewController(article.url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableArticles.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.item]
        cell.sourceLabel.text = article.source?.name
        cell.authorLabel.text = article.author
        cell.discLabel.text = article.articleDescription
        cell.titleLabel.text = article.title
        cell.article = article
        
        guard let urlToImage = article.urlToImage, let image = images[urlToImage] else {
            print("no image")
            return cell
        }
        cell.articleImage.image = image
        return cell
    }
}


extension FeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        fetch()
    }
}
