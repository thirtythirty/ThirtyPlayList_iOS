//
//  PlayListData.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/09/20.
//  Copyright © 2016年 SKT. All rights reserved.
//

import RealmSwift
import MediaPlayer

// 端末内の曲の情報をアーティスト単位で格納するテーブル
class PlayListData: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var name = "" // アーティスト名
    dynamic var use = true // 使用するかどうかの情報
    let songs = List<SongData>() // SongDataと多対多の関係になるので、Realmのリストを活用する
    
    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(name: String?) -> PlayListData {
        var name_: String?
        
        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            name_ = "unkown"
        }
        
        let playlist = PlayListData()
        playlist.id = lastId()
        playlist.name = name_!
        playlist.use = true
        return playlist
    }
    
    // オートインクリメント機能
    static func lastId() -> Int {
        if let tail = realm.objects(PlayListData).last {
            return tail.id+1
        } else {
            return 1
        }
    }
    
    // すでに曲が保存されているかチェック
    // ある:true、保存されていない:false
    static func existCheckByInfo(name: String?) -> Bool {
        var name_: String?
        
        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            return false
        }
        
        
        let playlist = realm.objects(PlayListData).filter("name = %@",name_!)
        if(playlist.count == 0){
            return false
        } else {
            return true
        }
    }
    
    func save(){
        try! PlayListData.realm.write{
            PlayListData.realm.add(self)
        }
    }
    
    
    static func DataSet(){
        // 端末にある音楽を取得
        let query = MPMediaQuery.playlistsQuery()
        
        // クラウドにある音楽をフィルターで取り除く
        query.addFilterPredicate(MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem))
        
        if let collections = query.collections {
            for collection in collections {
                if let playlist: MPMediaPlaylist = collection as! MPMediaPlaylist {
                    let playlistName = playlist.valueForProperty(MPMediaPlaylistPropertyName) as? String
                    
                    // すでに保存しているかチェック
                    if(PlayListData.existCheckByInfo(playlistName) == true){
                        continue
                    }
                    let s = PlayListData.create(playlistName)
                    
                    for item in collection.items {
                        let songdata = SongData.getSongDataByInfo(item.title, artist: item.artist, album: item.albumTitle)
                        if(songdata.count != 0){
                            s.songs.append(songdata[0])
                        }
                    }
                    
                    s.save()
                }
            }
        }
    }
    
    
    // すべての曲の情報を取得する
    // 引数のsonginfoに格納する
    static func getAllPlayListInfo(inout playlistInfo: [[AnyObject]]) {
        playlistInfo.removeAll()
        
        let playlists = realm.objects(PlayListData)
        for playlist in playlists {
            playlistInfo.append([playlist.name, playlist.use, false])
        }
    }
    
    static func getSongInfoByPlayListName(playlistName: String) -> [SongInfo] {
        var songInfo: [SongInfo] = []
        let playlist = realm.objects(PlayListData).filter("name = %@", playlistName)
        
        if(playlist.count == 0){
            return songInfo
        } else {
            for song in playlist[0].songs {
                let key_song_number = KeySongData.keySongCheck(song.id)
                
                songInfo.append(SongInfo(id: song.id, title: song.name, use: song.use,
                    artist: song.artist, album: song.album, duration: song.duration, key_song_number: key_song_number))
            }
        }
        return songInfo
    }
    
    
    // useを更新する
    static func updateUseableByName(playlistName: String, use: Bool) {
        let playlist = realm.objects(PlayListData).filter("name = %@", playlistName)
        if(playlist.count == 0){
            return
        } else {
            let s = playlist[0]
            try! PlayListData.realm.write{
                s.use = use
                PlayListData.realm.add(s, update: true)
            }
        }
    }
    
    static func AllDelete(){
        let playlists = realm.objects(PlayListData)
        
        for playlist in playlists {
            try! realm.write {
                realm.delete(playlist)
            }
        }
    }
}