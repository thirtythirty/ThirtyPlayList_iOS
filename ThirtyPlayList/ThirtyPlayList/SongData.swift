//
//  Song.swift
//  ThirtyPlayLIst_Bata
//
//  Created by 坂田 和也 on 2016/08/20.
//  Copyright © 2016年 SKT. All rights reserved.
//

import RealmSwift
import MediaPlayer

// 端末内の曲の情報を格納するテーブル
class SongData: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var name = "" // 曲名
    dynamic var artist = "" // アーティスト名
    dynamic var album = "" // アルバム名
    dynamic var genre = "" // ジャンル名
    dynamic var duration: Double = 0.0 // 再生時間(秒)
    dynamic var use = true // この曲を使用するかどうかの情報
    
    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(name: String?, artist: String?, album: String?, genre: String?, duration: Double) -> SongData {
        var name_: String?
        var artist_: String?
        var album_: String?
        var genre_: String?
        
        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            name_ = "unkown"
        }
        if let tmp = artist{
            // nilではない
            artist_ = tmp
        } else {
            artist_ = ""
        }
        if let tmp = album{
            // nilではない
            album_ = tmp
        } else {
            album_ = ""
        }
        if let tmp = genre{
            // nilではない
            genre_ = tmp
        } else {
            genre_ = ""
        }

        let song = SongData()
        song.id = lastId()
        song.name = name_!
        song.artist = artist_!
        song.album = album_!
        song.genre = genre_!
        song.duration = duration
        song.use = true
        return song
    }
    
    // オートインクリメント機能
    static func lastId() -> Int {
        if let tail_song = realm.objects(SongData).last {
            return tail_song.id+1
        } else {
            return 1
        }
    }
    
    // すでに曲が保存されているかチェック
    // ある:true、保存されていない:false
    static func existCheckByInfo(name: String?, artist: String?, album: String?) -> Bool {
        var name_: String?
        var artist_: String?
        var album_: String?

        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            return false
        }
        if let tmp = artist{
            // nilではない
            artist_ = tmp
        } else {
            artist_ = ""
        }
        if let tmp = album{
            // nilではない
            album_ = tmp
        } else {
            album_ = ""
        }
        
        let song = realm.objects(SongData).filter("name = %@ AND artist = %@ AND album = %@",name_!,artist_!,album_!)
        if(song.count == 0){
            return false
        } else {
            return true
        }
    }
    
    // 曲名、アーティスト名、アルバム名から検索し、そのidを返す
    static func getIdSongByInfo(name: String?, artist: String?, album: String?) -> Int{
        var name_: String
        var artist_: String
        var album_: String
        
        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            return -1
        }
        if let tmp = artist{
            // nilではない
            artist_ = tmp
        } else {
            artist_ = ""
        }
        if let tmp = album{
            // nilではない
            album_ = tmp
        } else {
            album_ = ""
        }
        
        
        let song = realm.objects(SongData).filter("name = %@ AND artist = %@ AND album = %@",name_,artist_,album_)
        if(song.count == 0 || song[0].use == false){
            return -1
        } else {
            return song[0].id
        }
    }
    
    // 曲名、アーティスト名、アルバム名から検索し、そのもの（Results）を返す
    static func getSongDataByInfo(name: String?, artist: String?, album: String?) -> Results<SongData>{
        var name_: String
        var artist_: String
        var album_: String
        
        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            name_ = ""
        }
        if let tmp = artist{
            // nilではない
            artist_ = tmp
        } else {
            artist_ = ""
        }
        if let tmp = album{
            // nilではない
            album_ = tmp
        } else {
            album_ = ""
        }
        
        
        let song = realm.objects(SongData).filter("name = %@ AND artist = %@ AND album = %@",name_,artist_,album_)
        return song
    }
    
    func save(){
        try! SongData.realm.write{
            SongData.realm.add(self)
        }
    }
    
    static func deleteSong(song: SongData){
        try! realm.write {
            realm.delete(song)
        }
    }

    static func DataSet(){
        // 端末内の曲に変更があったか判定するフラグ
        var update_flag = false
        
        // 端末にある音楽を取得
        let query = MPMediaQuery.songsQuery()
        
        // クラウドにある音楽をフィルターで取り除く
        query.addFilterPredicate(MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem))
        
        if let songs = query.items {
            for song in songs {
                // すでに保存しているかチェック
                if(SongData.existCheckByInfo(song.title,artist: song.artist, album: song.albumTitle) == true){
                    continue
                }
                // ジャンルから音楽でないものを判定
                // 必ずジャンルが設定されているわけではないので、音楽以外が混ざってしまう可能性は存在する
                if(song.genre == "Spoken & Audio"){
                    continue
                }

                let s = SongData.create(
                    song.title,
                    artist: song.artist,
                    album: song.albumTitle,
                    genre: song.genre,
                    duration: song.playbackDuration)
                
                s.save()
                
                // 新しい曲が追加された
                update_flag = true
            }
        }
        
        // 以前保存された曲がまだ存在しているかチェック
        // 端末内に存在指定なけらば、削除
        let songsData = realm.objects(SongData)
        for songData in songsData {
            var notFound = true
            if let songs = query.items {
                for song in songs {
                    let name_: String = song.title! // 曲名がない曲はない
                    var artist_: String
                    var album_: String
                    
                    if let tmp = song.artist{
                        // nilではない
                        artist_ = tmp
                    } else {
                        artist_ = ""
                    }
                    if let tmp = song.albumTitle{
                        // nilではない
                        album_ = tmp
                    } else {
                        album_ = ""
                    }
                    
                    if(songData.name == name_ && songData.artist == artist_ && songData.album == album_){
                        notFound = false
                        break
                    }
                }
            }
            if(notFound == true){
                deleteSong(songData)
                // 端末内の曲が減った
                update_flag = true
            }
        }
        
        // 端末内の曲に変更があったら、端末内のプレイリストに変更があるはずなので
        // 保存されているプレイリストの情報を削除(作り直す)
        if(update_flag){
            PlayListData.AllDelete()
        }
    }
    
    // useがtrueの曲の数を返す
    static func UseableSongCount() -> Int{
        let songs = realm.objects(SongData)
        var count = 0
        for song in songs {
            if(song.use){
                count+=1
            }
        }
        return count
    }
    
    // すべての曲の情報を取得する
    // 引数のsonginfoに格納する
    static func getAllSongInfo() -> [SongInfo] {
        var songinfo: [SongInfo] = []
        
        let songs = realm.objects(SongData)
        for song in songs {
            let key_song_number = KeySongData.keySongCheck(song.id)
            
            songinfo.append(SongInfo(id: song.id, title: song.name, use: song.use,
                artist: song.artist, album: song.album, duration: song.duration, key_song_number: key_song_number))
        }
        return songinfo
    }
    
    // タイトルから検索し、結果を引数songinfoに格納する
    static func getSongInfoByTitleSearch(searchText: String) -> [SongInfo]{
        var songinfo: [SongInfo] = []
        
        let songs = realm.objects(SongData).filter("name CONTAINS %@",searchText)
        for song in songs {
            let key_song_number = KeySongData.keySongCheck(song.id)
            
            songinfo.append(SongInfo(id: song.id, title: song.name, use: song.use,
                artist: song.artist, album: song.album, duration: song.duration, key_song_number: key_song_number))
        }
        return songinfo
    }
    
    // songsId(SongDataのidの配列)から情報を検索し、songinfoに格納する
    static func getSongInfoBysongsId(inout songinfo: [SongInfo], songsId: [Int]){
        songinfo.removeAll()
        
        for songId in songsId {
            let song = realm.objects(SongData).filter("id = %@",songId)
            if(song.count == 0){
                return
            }
            let key_song_number = KeySongData.keySongCheck(songId)
            songinfo.append(SongInfo(id: songId, title: song[0].name, use: song[0].use,
                artist: song[0].artist, album: song[0].album, duration: song[0].duration, key_song_number: key_song_number))
        }
    }
    
    // useを更新する
    static func updateUseableById(songId: Int, use: Bool) {
        let song = realm.objects(SongData).filter("id = %@", songId)
        if(song.count == 0){
            return
        } else {
            let s = song[0]
            try! SongData.realm.write{
                s.use = use
                SongData.realm.add(s, update: true)
            }
        }
    }
}
