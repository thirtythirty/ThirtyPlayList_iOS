//
//  SecondViewController.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/26.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // ピッカーで使う情報
    let useableMinute: [String] = ["15分", "20分", "25分", "30分", "35分", "40分", "45分", "50分", "55分", "60分", "65分", "70分", "75分", "80分", "85分", "90分"]
    let useableSplit: [String] = ["1分割","2分割","3分割","4分割","5分割","6分割"]
    
    // ピッカーで選択している値が入る
    // 初期値は30,2
    var selectMinute: Int = 30
    var selectSplit: Int = 2
    
    // 作るプレイリストの合計再生時間を決めるピッカー
    @IBOutlet weak var durationSelectPicker: UIPickerView!
    // 決定ボタン(storyboardで設定済み)
    @IBAction func GoToPlayBottom(sender: AnyObject) {
    }
    @IBOutlet weak var GoButtom: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GoButtom.layer.borderWidth = 10
        GoButtom.layer.borderColor = UIColor(red: 72/255, green: 187/255, blue: 255/255, alpha: 1.0).CGColor
        GoButtom.layer.cornerRadius = 85
        GoButtom.clipsToBounds = true

        
        // ピッカーの初期値を30分,２分割にする
        durationSelectPicker.selectRow(3, inComponent: 0, animated: true)
        durationSelectPicker.selectRow(1, inComponent: 1, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ピッカーのデータを返す
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0){
            return useableMinute[row]
        } else if(component == 1){
            return useableSplit[row]
        }
        return ""
    }
    
    // ピッカーは一つ
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // ピッカーの扱うデータの総数を返す
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if( component == 0){
            return useableMinute.count
        } else if(component == 1){
            return useableSplit.count
        }
        return 0
    }
    
    // ピッカーが止まったら、selectMinuteを更新
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            selectMinute = 15 + 5*row
            durationSelectPicker.selectRow((selectMinute / 15)-1, inComponent: 1, animated: true)
            selectSplit = (selectMinute / 15)
        } else if(component == 1){
            selectSplit = row+1
        }
    }
    
    // ピッカーが選択した時間を次のPlayViewControllerに渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let playViewController = segue.destinationViewController as! PlayViewController
        playViewController.selectedMinute = selectMinute
        playViewController.selectedSplit = selectSplit
        playViewController.hidesBottomBarWhenPushed = true
    }
}

