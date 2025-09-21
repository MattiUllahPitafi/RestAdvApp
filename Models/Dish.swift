struct Dish: Codable, Identifiable {
    let dishId: Int
    let dishName: String
    let price: Double
    let prepTimeMinutes: Int
    let dishImageUrl: String

    var id: Int { dishId }

    enum CodingKeys: String, CodingKey {
        case dishId      = "dishId"
        case dishName    = "name"
        case price       = "price"
        case prepTimeMinutes = "prepTimeMinutes"
        case dishImageUrl    = "dishImageUrl"
    }
}
