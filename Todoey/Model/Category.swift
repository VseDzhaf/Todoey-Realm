//
//  Category.swift
//  Todoey
//
//  Created by Vsevolod on 28.11.2020.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String? = "#FFFFFF"
    let items = List<Item>()
    
}
