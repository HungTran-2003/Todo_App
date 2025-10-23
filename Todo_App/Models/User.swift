//
//  User.swift
//  Todo_App
//
//  Created by admin on 17/10/25.
//

struct User: Decodable {
    let id: Int
    let uuid: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
    }
}
