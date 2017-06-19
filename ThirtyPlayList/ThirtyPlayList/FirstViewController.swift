//
//  FirstViewController.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/26.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SongCellDelegate, SongHeaderCellDelegate{
    
    @IBOutlet weak var SongTableView: UITableView!
    
    // ヘッダーの情報が入ったAnyObject配列
    private var headerInfo: [[AnyObject]] = []
    // 表示する曲の情報が入った構造体SongInfoの配列
    private var songInfo: [[SongInfo]] = []
    
    @IBOutlet weak var SongSearchBar: UISearchBar!
    @IBOutlet weak var ModeSelectBar: UIToolbar!
    private var modeNumber: Int = 1
    
    @IBAction func ChangeALLTable(sender: AnyObject) {
        modeNumber = 0
        changeColorInModeBar()
        // SongDataテーブルにあるすべての曲の情報をsongInfoに格納
        songInfo.removeAll()
        songInfo.append(SongData.getAllSongInfo())
        // アコーディオンテーブルのヘッダー作成
        headerInfo.removeAll()
        headerInfo.append(["すべての曲", true, true])
        SongTableView.reloadData()
    }
    @IBAction func ChangeArtistTable(sender: AnyObject) {
        modeNumber = 1
        changeColorInModeBar()
        songInfo.removeAll()
        ArtistData.getAllArtistInfo(&headerInfo)
        for h in headerInfo {
            let name = h[0] as! String
            songInfo.append(ArtistData.getSongInfoByArtistName(name))
        }
        SongTableView.reloadData()
    }
    @IBAction func ChangePlayListTable(sender: AnyObject){
        modeNumber = 2
        changeColorInModeBar()
        songInfo.removeAll()
        PlayListData.getAllPlayListInfo(&headerInfo)
        for h in headerInfo {
            let name = h[0] as! String
            songInfo.append(PlayListData.getSongInfoByPlayListName(name))
        }
        SongTableView.reloadData()
    }
    @IBAction func ChangeGenreTable(sender: AnyObject) {
        modeNumber = 3
        changeColorInModeBar()
        songInfo.removeAll()
        GenreData.getAllGenreInfo(&headerInfo)
        for h in headerInfo {
            let name = h[0] as! String
            songInfo.append(GenreData.getSongInfoByGenreName(name))
        }
        SongTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // テーブルのヘッダーの縦幅指定
        SongTableView.sectionHeaderHeight = 50

        
        // 端末にある曲を取得し、データベースに登録する
        SongData.DataSet()
        ArtistData.DataSet()
        GenreData.DataSet()
        PlayListData.DataSet()

        
        // キーソング(15分最後で鍵をかけられた(固定された)曲)が登録されていないなら初期化
        if(KeySongData.KeySongisSet() == false){
            // 端末から情報を取り、再生回数が多い順にKeySongDataテーブルに登録
            KeySongData.autoKeySongSet()
        }
        
        
        // SongDataテーブルにあるすべての曲の情報をsongInfoに格納
        songInfo.append(SongData.getAllSongInfo())
        // アコーディオンテーブルのヘッダー作成
        headerInfo.removeAll()
        headerInfo.append(["すべての曲", true, true])
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 表示モード選択バーをの文字の色を変える
    func changeColorInModeBar(){
        for i in 0..<ModeSelectBar.items!.count {
            ModeSelectBar.items![i].tintColor = UIColor(red: 187/255, green: 234/255, blue: 252/255, alpha: 1.0)
        }
        ModeSelectBar.items![1+modeNumber*2].tintColor = UIColor.whiteColor()
    }

    // Cellが選択された際に呼び出される
    // キーソング設定をするアクションシートを出す
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let keysongInfo = KeySongData.getAllKeySongInfo()
        
        let alertController = UIAlertController(
            title: "キーソング設定",
            message: "\"\(songInfo[indexPath.section][indexPath.row].title)\"を何番のキーソングに設定しますか？(キーソング１が一番優先度が高い)",
            preferredStyle: .ActionSheet)
        
        var messages: [String] = []
        for i in 0..<6{
            let str = "キーソング\(i+1)(\(keysongInfo[i].title))"
            messages.append(str)
        }
        
        
        
        let keySong1 = UIAlertAction(
            title: messages[0],
            style: .Default,
            handler: { action in
                self.updateKeySong(1, section: indexPath.section, index: indexPath.row, tableView: tableView)
        })
        let keySong2 = UIAlertAction(
            title: messages[1],
            style: .Default,
            handler: { action in
                self.updateKeySong(2, section: indexPath.section, index: indexPath.row, tableView: tableView)
        })
        let keySong3 = UIAlertAction(
            title: messages[2],
            style: .Default,
            handler: { action in
                self.updateKeySong(3, section: indexPath.section, index: indexPath.row, tableView: tableView)
        })
        let keySong4 = UIAlertAction(
            title: messages[3],
            style: .Default,
            handler: { action in
                self.updateKeySong(4, section: indexPath.section, index: indexPath.row, tableView: tableView)
        })
        let keySong5 = UIAlertAction(
            title: messages[4],
            style: .Default,
            handler: { action in
                self.updateKeySong(5, section: indexPath.section, index: indexPath.row, tableView: tableView)
        })
        let keySong6 = UIAlertAction(
            title: messages[5],
            style: .Default,
            handler: { action in
                self.updateKeySong(6, section: indexPath.section, index: indexPath.row, tableView: tableView)
        })
        let cancel = UIAlertAction(
            title: "キャンセル",
            style: .Cancel,
            handler: { action in
                // 何もしない
            }
        )
        
        
        alertController.addAction(keySong1)
        alertController.addAction(keySong2)
        alertController.addAction(keySong3)
        alertController.addAction(keySong4)
        alertController.addAction(keySong5)
        alertController.addAction(keySong6)
        alertController.addAction(cancel)
        
        self.presentViewController(alertController, animated: true,completion: nil)
    }
    
    // アクションシートから呼び出される、キーソング設定関数
    // 新しくデータを入れるわけではなく、更新する
    func updateKeySong(key_song_number: Int,section: Int, index: Int, tableView: UITableView){
        let keysong = KeySongData.create(songInfo[section][index].id,key_song_number: key_song_number)
        // すでにデータがある場合は、そのkey_song_numberのデータを更新する
        keysong.save()
        
        // headerInfo, songInfoを更新
        for i in 0..<headerInfo.count {
            for j in 0..<songInfo[i].count {
                if(songInfo[i][j].key_song_number == key_song_number){
                    if(i == section && j == index){
                        break
                    }
                    songInfo[i][j].key_song_number = -1
                    break
                }
            }
        }
        songInfo[section][index].key_song_number = key_song_number
        
        // テーブルを再描写
        SongTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = CustomHeaderFooterView(reuseIdentifier: "Header")
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FirstViewController.tapHeader(_:))))
        var canUseableSongCount = 0
        for song in songInfo[section] {
            if(song.use == true){
                canUseableSongCount+=1
            }
        }
        let headertext = (headerInfo[section][0] as? String)! + "(\(canUseableSongCount)/\(songInfo[section].count)曲)"
        cell.headerTitle.text = headertext
        cell.headerSwitch.setOn((headerInfo[section][1] as? Bool)!, animated: false)
        cell.section = section
        cell.frame.size.height = 100
        cell.setExpanded((headerInfo[section][2] as? Bool)!)
        cell.delegate = self
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return headerInfo.count
    }
    // テーブルに表示する配列の総数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if((headerInfo[section][2] as? Bool) == false){
            return 0
        }
        return songInfo[section].count
    }
    
    func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CustomHeaderFooterView else {
            return
        }
        let extended = headerInfo[cell.section][2] as? Bool
        headerInfo[cell.section][2] = !(extended!)
        SongTableView.reloadSections(NSIndexSet(index: cell.section), withRowAnimation: .None)
    }
    
    
    
    // Cellに値を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell") as! CustomSongTableViewCell

        // それぞれの値を設定
        cell.SongTitle.text = songInfo[indexPath.section][indexPath.row].title
        cell.setKeySongImg(songInfo[indexPath.section][indexPath.row].key_song_number)
        cell.songId = songInfo[indexPath.section][indexPath.row].id
        cell.SongUseSwitch_Outlet.firstItem.setOn!(songInfo[indexPath.section][indexPath.row].use, animated: false)
        cell.index = indexPath.row
        cell.section = indexPath.section
        // updateUseable関数をCustomSongTableViewCellから移譲
        cell.delegate = self
        return cell
    }
    
    // CustomSongTableViewCellからのデリゲート
    // songInfoのユーザからの使用、不使用の情報をsongInfoに更新する
    func updateUseable(section: Int, index: Int,use: Bool){
        songInfo[section][index].use = use
        SongTableView.reloadData()
    }
    
    // CustomHeaderFooterViewからのデリゲート
    // songInfoのユーザからの使用、不使用の情報をsongInfoに更新する
    func updateUseableInSameSection(section: Int, use: Bool){
        headerInfo[section][1] = use
        ArtistData.updateUseableByName((headerInfo[section][0] as? String)!,use: use)
        for i in 0..<songInfo[section].count {
            songInfo[section][i].use = use
            SongData.updateUseableById(songInfo[section][i].id,use: use)
        }
        SongTableView.reloadData()
    }
    
    //サーチバー更新時
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // 検索
        songInfo.removeAll()
        songInfo.append(SongData.getSongInfoByTitleSearch(searchText))
        headerInfo.removeAll()
        headerInfo.append(["検索結果:" + songInfo[0].count.description + "件", true, true])
        
        self.SongTableView.reloadData()
    }
    
    //キャンセルクリック時
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        SongSearchBar.text = ""
        ChangeALLTable([])
        self.view.endEditing(true)
    }
    
    //サーチボタンクリック時
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

