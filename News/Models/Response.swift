import Foundation

struct Response: Codable {
    let status: String
    let totalResults: Int?
    let articles: [Article]
    let error: String?
    let code: String?
    let message: String?
}

