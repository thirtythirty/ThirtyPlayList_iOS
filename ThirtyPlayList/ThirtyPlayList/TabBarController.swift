//
//  TabBarController.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/31.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 非選択時のタブの下の文字の色変更
        let colorNormal = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        let selectedAttributes_n = [NSForegroundColorAttributeName: colorNormal]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes_n, forState: UIControlState.Normal)
        // 選択時
        let colorSelected = UIColor(red: 36/255, green: 47/255, blue: 232/255, alpha: 1.0)
        let selectedAttributes_s = [NSForegroundColorAttributeName: colorSelected]
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes_s, forState: UIControlState.Selected)
        
        // タブ背景設定
        let colorBg = UIColor(red: 72/255, green: 187/255, blue: 255/255, alpha: 1.0)
        UITabBar.appearance().barTintColor = colorBg
        // アイコンの色
        let colorKey = UIColor(red: 36/255, green: 47/255, blue: 232/255, alpha: 1.0)
        UITabBar.appearance().tintColor = colorKey
        // Do any additional setup after loading the view.
        
        // 非選択時、アイコンが白になるようにする
        let img_names = ["keysong_icon_tab_30","play_tab_30","yaruki_tab_30"]
        for (i, item) in self.tabBar.items!.enumerate() {
            item.image = UIImage(named: img_names[i])?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
