//
//  ThirdViewController.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/30.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var TreeGroundImg: UIImageView!
    @IBOutlet weak var treeNameTextField: UITextField!
    
    @IBOutlet weak var toDayTotalTime: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalDayLabel: UILabel!
    @IBOutlet weak var RunningDayLabel: UILabel!
    
    @IBOutlet weak var MessageLabel: UILabel!
    @IBAction func TapResetButton(sender: AnyObject) {
        let alertController = UIAlertController(
            title: "やる木のリセット",
            message: "やる木をリセットして、新しくやる木を育てますか？",
            preferredStyle: .Alert)
        let resetAction = UIAlertAction(
            title: "OK",
            style: .Default,
            handler: { action in
                self.resetTree()
        })
        let cancelAction = UIAlertAction(
            title: "キャンセル",
            style: .Cancel,
            handler: { action in
                //                print("no")
        })
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true,completion: nil)
    }
    
    
    var TreeCGRect = CGRect()
    var TreeTrunkView = UIImageView()
    var TreeLeaves: [UIImageView] = []
    let MaxLeavesNum = [2,7,16,30,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let TreeX = TreeGroundImg.frame.origin.x
        let TreeY = TreeGroundImg.frame.origin.y
        let TreeWidth = TreeGroundImg.frame.width
        let TreeHeight = TreeGroundImg.frame.height
        
        TreeCGRect = CGRectMake(TreeX, TreeY, TreeWidth, TreeHeight)
        
        displayTreeAndInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayTreeAndInfo(){
        for i in 0..<TreeLeaves.count {
            TreeLeaves[i].removeFromSuperview()
        }
        TreeLeaves.removeAll()
        
        if(TreeData.TreeCount() == 0){
            let tree = TreeData.create("")
            tree.save()
        }
        
        let treeInfo = TreeData.getLastTreeInfo()
        let lastLeaf = TreeData.getLastLeaf()
        
        treeNameTextField.text = treeInfo.treeName
        toDayTotalTime.text = "\(lastLeaf.totalTime_min)分"
        totalTimeLabel.text = "\(treeInfo.totalTime_min)分"
        totalDayLabel.text = "\(treeInfo.totalDay)日"
        //        var treeimg_num = treeInfo.totalDay
        //        if( treeimg_num > 31){
        //            treeimg_num = 31
        //        }
        //        treeImg.image = UIImage(named: "yaruki_"+"\(treeimg_num)")
        
        var yaruki_type = 1
        for i in 0..<MaxLeavesNum.count {
            if(treeInfo.haveLeafCount <= MaxLeavesNum[i]){
                yaruki_type = i+1
                break
            }
        }
        if(treeInfo.haveLeafCount > 30){
            yaruki_type = 5
        }
        // 幹の描画
        TreeTrunkView.image = UIImage(named: "yaruki"+yaruki_type.description)
        TreeTrunkView.frame = TreeCGRect
        self.view.addSubview(TreeTrunkView)
        
        // やる木の５段階目には葉っぱがない
        if(yaruki_type > 4){
            MessageLabel.text = "１ヶ月継続、習慣化おめでとう！(これ以上やる木は成長しません)"
            return
        } else {
            MessageLabel.text = ""
        }
        
        // 葉の描画
        for i in 1...MaxLeavesNum[yaruki_type-1] {
            
            let leafImg = UIImageView()
            leafImg.image = UIImage(named: "yaruki"+yaruki_type.description + "_" + i.description)?.imageWithRenderingMode(.AlwaysTemplate)
            leafImg.frame = TreeCGRect
            if(treeInfo.leafTime.count < i){
                leafImg.tintColor = UIColor.whiteColor()
            } else if(treeInfo.leafTime[i-1] < 15){
                leafImg.tintColor = UIColor(red: 162/255, green: 255/255, blue: 159/255, alpha: 1.0)
            } else if(treeInfo.leafTime[i-1] < 30){
                leafImg.tintColor = UIColor(red: 174/255, green: 255/255, blue: 69/255, alpha: 1.0)
            } else if(treeInfo.leafTime[i-1] < 45){
                leafImg.tintColor = UIColor(red: 12/255, green: 205/255, blue: 2/255, alpha: 1.0)
            } else if(treeInfo.leafTime[i-1] < 60){
                leafImg.tintColor = UIColor(red: 21/255, green: 148/255, blue: 0/255, alpha: 1.0)
            } else if(treeInfo.leafTime[i-1] < 75){
                leafImg.tintColor = UIColor(red: 248/255, green: 234/255, blue: 7/255, alpha: 1.0)
            } else if(treeInfo.leafTime[i-1] < 90){
                leafImg.tintColor = UIColor(red: 240/255, green: 156/255, blue: 10/255, alpha: 1.0)
            } else {
                leafImg.tintColor = UIColor(red: 241/255, green: 82/255, blue: 43/255, alpha: 1.0)
            }
            
            TreeLeaves.append(leafImg)
            self.view.addSubview(leafImg)
        }
    }
    
    //改行ボタンが押された際に呼ばれるデリゲートメソッド.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        var treeInfo = TreeData.getLastTreeInfo()
        treeInfo.treeName = treeNameTextField.text!
        let tree = TreeData()
        
        try! TreeData.realm.write{
            tree.id = treeInfo.id
            tree.treeName = treeInfo.treeName
            TreeData.realm.add(tree, update: true)
        }
        
        return true
    }
    
    func resetTree(){
        let tree = TreeData.create("")
        tree.save()
        
        displayTreeAndInfo()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
