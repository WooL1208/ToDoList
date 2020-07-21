//
//  changeDataBaseController.swift
//  realmTest
//
//  Created by WooL on 2020/7/8.
//  Copyright © 2020 WooL. All rights reserved.
//

import Foundation
import RealmSwift

class ControllDataBase {
    func writeData(_ Name:String,_ Price:String){
        let realm = try! Realm()
        let newOrder = Order()
        newOrder.name = Name
        newOrder.price = Price
        try! realm.write {
            realm.add(newOrder)
        }
    }

    func readData() -> String {
        let realm = try! Realm()
        let orders = realm.objects(Order.self)
        var display = ""
        if orders.count > 0 {
            for i in 0..<orders.count {
                display += orders[i].name + ": " + orders[i].price + "\n"
            }
        }
        return display
    }
    func deleteData(_ delName: String){
        let realm = try! Realm()
        let user = realm.objects(Order.self).filter("name = %@", delName)
        try! realm.write {
            realm.delete(user)
        }
    }
}
