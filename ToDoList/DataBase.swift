//
//  DataBase.swift
//  ToDoList
//
//  Created by WooL on 2020/7/9.
//  Copyright © 2020 JeremyXue. All rights reserved.
//

import Foundation
import RealmSwift

class Task : Object{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var tasks = ""
    @objc dynamic var date = Date()
    override static func primaryKey() -> String? {
        return "id"
    }
}
