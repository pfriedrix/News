import Foundation
import RealmSwift

class Article: Object, Codable {
    @objc dynamic var source: Source?
    @objc dynamic var author: String?
    @objc dynamic var title: String = ""
    @objc dynamic var articleDescription: String?
    @objc dynamic var url: String = ""
    @objc dynamic var urlToImage: String?
    @objc dynamic var publishedAt: String = ""
    @objc dynamic var content: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

class Source: Object, Codable {
    @objc dynamic var id: String?
    @objc dynamic var name: String = ""
}
