//
//  Product.swift
//  OnlineProducts
//
//  Created by Mac on 22/10/21.
//

import Foundation

struct Product: Decodable {
    var id: Int
    var title: String
    var price: Double
    var description: String
    var category: String
    var image: String
    var rating: Rating
}

struct Rating: Decodable {
    var rate: Double
    var count: Int
}
