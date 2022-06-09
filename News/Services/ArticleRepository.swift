
import RealmSwift

class ArticleRepository {
    static var shared = ArticleRepository()
  
    
    func save(_ article: Article) {
        let realm = try! Realm()
        
        let articles = realm.objects(Article.self).filter { object in
            object.url == article.url
        }
        if articles.isEmpty {
            try! realm.write {
                realm.add(article)
            }
        }
        
    }
    
    func fetchAll() -> [Article] {
        let realm = try! Realm()

        return realm.objects(Article.self).filter {_ in true}
    }
}
