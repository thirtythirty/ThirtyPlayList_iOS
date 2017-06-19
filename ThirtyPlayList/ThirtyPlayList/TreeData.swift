//
//  TreeData.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/31.
//  Copyright © 2016年 SKT. All rights reserved.
//

import RealmSwift

class TreeData: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var treeName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(treeName: String) -> TreeData {
        
        let tree = TreeData()
        tree.id = lastId()
        tree.treeName = treeName
     
        return tree
    }
    
    static func lastId() -> Int {
        if let tail_tree = realm.objects(TreeData).last {
            return tail_tree.id+1
        } else {
            return 1
        }
    }


    func save(){
        try! TreeData.realm.write{
            TreeData.realm.add(self)
        }
    }

    
    static func TreeCount() ->Int {
        let tree = realm.objects(TreeData)
        return tree.count
    }
    
    static func getLastTreeInfo() -> TreeInfo {
        let tail_tree = realm.objects(TreeData).last!
        
        let leaves = realm.objects(TreeLeafData).filter("treeId = %@",tail_tree.id).sorted("id", ascending: true)
        
        if(leaves.count == 0){
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            
            let treeInfo = TreeInfo(id: tail_tree.id, treeName: tail_tree.treeName,totalTime_min: 0 ,totalDay: 0,haveLeafCount: 0,
                                    leafTime: [])
            return treeInfo
        }
        
        var totalTime = 0
        var totalDay = 0
        var leafTime: [Int] = []
        for leaf in leaves {
            totalTime += leaf.totalTime_min
            totalDay += 1
            leafTime.append(leaf.totalTime_min)
        }
        var haveLeafCount = totalDay
        if(haveLeafCount > 31){
            haveLeafCount = 31
        }
        let treeInfo = TreeInfo(id: tail_tree.id, treeName: tail_tree.treeName,totalTime_min: totalTime ,totalDay: totalDay,haveLeafCount: haveLeafCount,
                                leafTime: leafTime)
        return treeInfo
    }
    
    static func getLastLeaf() -> TreeLeafData{
        let tail_tree = realm.objects(TreeData).last!
        let leaves = realm.objects(TreeLeafData).filter("treeId = %@",tail_tree.id).sorted("id", ascending: true)
        
        if(leaves.count == 0){
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let reaf = TreeLeafData.create(tail_tree.id, totalTime_min: 0, leafNumber: 0, UpdateDate: calendar.dateByAddingUnit(.Day, value: -1, toDate: NSDate(),
                options: NSCalendarOptions())!)
            
            return reaf
        }
        return (leaves.last)!
    }

}
