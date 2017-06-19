//
//  PlayViewController.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/29.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    // SecondViewControllerから渡された、作成するプレイリストの合計時間
    var selectedMinute: Int = 0
    var selectedSplit: Int = 0
    var player = MPMusicPlayerController() // 音楽を再生するプレイヤー
    var playlistInfo: [SongInfo] = [] // 作成したn分プレイリストの曲の情報を格納
    var playlistMediaItem: [MPMediaItem] = []
    var isPlay: Bool = true // 再生から始める
    var playedSongCount = 0
    var playedKeySongCount = 0
    
    
    @IBOutlet weak var Message: UILabel! // "もうすぐn分経過"を表示する
    @IBOutlet weak var KeySongImg: UIImageView!
    @IBOutlet weak var playlistProgressbar: UIProgressView! //プログレスバー
    @IBOutlet weak var PlayOrStopButtonView: UIButton!
    @IBAction func PlayOrStopButton(sender: AnyObject) { // 再生ボタン
        let button = (sender as! UIButton)
        if isPlay {
            player.pause()
            button.setImage(UIImage(named: "play_icon"), forState: UIControlState.Normal)
            UIApplication.sharedApplication().idleTimerDisabled = false // 自動ロック抑制を解除
            if timer.valid == true {
                timer.invalidate()
            }
            isPlay = false
        } else {
            player.play()
            button.setImage(UIImage(named: "stop_icon"), forState: UIControlState.Normal)
            UIApplication.sharedApplication().idleTimerDisabled = true
            if timer.valid == false {
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PlayViewController.countUpdate(_:)), userInfo: nil, repeats: true)// 自動ロック抑制
            }
            isPlay = true
        }
    }
    
    @IBOutlet weak var PlayListTableView: UITableView!
    @IBOutlet weak var SongImg: UIImageView!
    @IBOutlet weak var SongTitle: UILabel!
    
    var timer:NSTimer!
    @IBOutlet weak var playlistCountDown: UILabel!
    private var countDown: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        player = MPMusicPlayerController.systemMusicPlayer()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,selector: #selector(PlayViewController.nowPlayingItemChanged(_:)),name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification,object: player)
        player.beginGeneratingPlaybackNotifications()
        
        let detector = Detector() // プレイリスト計算機の生成
        let playlist = detector.makePlayList(selectedMinute, split: selectedSplit)// n分プレイリストを作成
        if(playlist.songsId.count == 0){
            // 検索に失敗
            let alertController = UIAlertController(
                title: "\(selectedMinute)分プレイリストの作成に失敗",
                message: "ヒント:曲を増やしたり、キーソングを変えたり、分割数を減らすと成功するかも！",
                preferredStyle: .Alert)
            
            let okAction = UIAlertAction(
                title: "OK",
                style: .Default,
                handler: { action in
                    self.navigationController?.popViewControllerAnimated(true)
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true,completion: nil)
            return
        }
        // 作成されたプレイリストの各曲の情報取得
        SongData.getSongInfoBysongsId(&playlistInfo, songsId: playlist.songsId)
        for i in 0..<playlist.songsId.count {
            // 各曲のMPMediaItemを取得
            let query = MPMediaQuery.songsQuery()
            query.addFilterPredicate(MPMediaPropertyPredicate(value: playlistInfo[i].title, forProperty: MPMediaItemPropertyTitle))
            playlistMediaItem.append(query.items![0])
        }
        let playlistMediaItemCollection = MPMediaItemCollection.init(items: playlistMediaItem)

        // 曲をプレイヤーに設定
        player.setQueueWithItemCollection(playlistMediaItemCollection)
        
        // タイマーを設定
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(PlayViewController.countUpdate(_:)), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        countDown = selectedMinute * 60
        
        // 自動ロック抑制
        UIApplication.sharedApplication().idleTimerDisabled = true
        // 再生開始
        player.play()
        
        treeUpdate(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification,object: player)
        player.endGeneratingPlaybackNotifications()
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        player.pause()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // タイマーを破棄する
        if(timer != nil && timer.valid == true){
            timer.invalidate()
        }
    }
    
    
    func nowPlayingItemChanged(notification:NSNotification){
        if let mediaItem = player.nowPlayingItem {
            updateSongInformationUI(mediaItem)
        }
    }
    
    //曲情報を更新
    func updateSongInformationUI(mediaItem: MPMediaItem){
        SongTitle.text = mediaItem.title ?? "不明な曲"
        
        if(playedSongCount < playlistInfo.count && playlistInfo[playedSongCount].title == mediaItem.title){
            if(playlistInfo[playedSongCount].key_song_number != -1){
                KeySongImg.image = UIImage(named: "keysong_icon_" + playlistInfo[playedSongCount].key_song_number.description)
                let splitedMinute = Double(selectedMinute)/Double(selectedSplit)
                playedKeySongCount+=1
                let time_soon = splitedMinute * Double(playedKeySongCount)
                if(Int((time_soon * 10) % 10) == 0){
                    Message.text = "もうすぐ\n\(Int(time_soon))分"
                }else {
                    Message.text = "もうすぐ\n\(String(format: "%.1f",time_soon))分"
                }
            } else {
                KeySongImg.image = nil
                Message.text = ""
            }
            playedSongCount+=1
        }
        
        if let artwork = mediaItem.artwork{
            let image = artwork.imageWithSize(SongImg.bounds.size)
            SongImg.image = image
        } else {
            SongImg.image = nil
            SongImg.backgroundColor = UIColor.whiteColor()
        }
    }
    
    // タイマー
    func countUpdate(sender: NSTimer){
        countDown-=1
        if((selectedMinute*60 - countDown) % (1*60) == 0){
            // 1分ごとでやる木の情報更新
            treeUpdate(1)
        }
        
        let h = countDown / (60*60)
        let m = countDown / 60 % 60
        let s = countDown % 60
        
        playlistCountDown.text = String(format: "%01d:%02d:%02d",h,m,s)
        
        playlistProgressbar.setProgress(1.0-Float(countDown)/Float(selectedMinute*60), animated: true)
        
        if(countDown == 0){
            // タイマー破棄
            timer.invalidate()
            return
        }
    }

    //テーブルに表示する配列の総数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistMediaItem.count
    }
    
    
    //Cellに値を設定する.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playSongCell") as! CustomPlaySongTableViewCell
        
        if let artwork = playlistMediaItem[indexPath.row].artwork {
            let image = artwork.imageWithSize(cell.SongImg.bounds.size)
            cell.SongImg.image = image
        } else {
            cell.SongImg.image = nil
            cell.SongImg.backgroundColor = UIColor.lightGrayColor()
        }
        cell.SongTitle.text = playlistInfo[indexPath.row].title
        let minute = Int(round(playlistInfo[indexPath.row].duration))/60
        let second = Int(round(playlistInfo[indexPath.row].duration))%60
        cell.SongDuration.text = String(format: "%d:%02d",minute,second)
        cell.setKeySongImginPlaylist(playlistInfo[indexPath.row].key_song_number)

        return cell
    }
    
    // やる木のパラメータ更新
    func treeUpdate(addMinute: Int){
        if(TreeData.TreeCount() == 0){// ないなら初期化
            let tree = TreeData.create("")
            tree.save()
        }
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        
        let lastLeaf = TreeData.getLastLeaf()
        var treeInfo = TreeData.getLastTreeInfo()
        var leaf = TreeLeafData()
        if(calendar!.isDate(lastLeaf.UpdateDate, inSameDayAsDate: NSDate()) == false){
            leaf = TreeLeafData.create(treeInfo.id, totalTime_min: 0, leafNumber: lastLeaf.leafNumber+1, UpdateDate: NSDate())
        } else {
            leaf = lastLeaf
        }
        
        try! TreeLeafData.realm.write{
            leaf.totalTime_min += addMinute
            TreeData.realm.add(leaf, update: true)
        }
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
