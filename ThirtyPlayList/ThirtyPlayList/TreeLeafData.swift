//
//  TreeLeafData.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/09/23.
//  Copyright © 2016年 SKT. All rights reserved.
//

import RealmSwift


class TreeLeafData: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var treeId = 0
    dynamic var totalTime_min = 0
    dynamic var leafNumber = 0
    dynamic var UpdateDate = NSDate()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(treeId: Int, totalTime_min: Int, leafNumber: Int, UpdateDate: NSDate) -> TreeLeafData {
        
        let leaf = TreeLeafData()
        leaf.id = lastId()
        leaf.treeId  = treeId
        leaf.totalTime_min = totalTime_min
        leaf.leafNumber = leafNumber
        leaf.UpdateDate = UpdateDate
        
        return leaf
    }
    
    static func lastId() -> Int {
        if let tail_leaf = realm.objects(TreeLeafData).last {
            return tail_leaf.id+1
        } else {
            return 1
        }
    }
    
    
    func save(){
        try! TreeLeafData.realm.write{
            TreeLeafData.realm.add(self)
        }
    }
}