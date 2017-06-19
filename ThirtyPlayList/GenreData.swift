//
//  GenreData.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/09/20.
//  Copyright © 2016年 SKT. All rights reserved.
//

import RealmSwift
import MediaPlayer

// 端末内の曲の情報をアーティスト単位で格納するテーブル
class GenreData: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var name = "" // アーティスト名
    dynamic var use = true // 使用するかどうかの情報
    
    // idをプライマリキーに設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(name: String?) -> GenreData {
        var name_: String?
        
        if let tmp = name{
            name_ = tmp
            // nilではない
        } else {
            // 名前のない曲は存在しないはず
            name_ = "unkown"
        }
        
        let artist = GenreData()
        artist.id = lastId()
        artist.name = name_!
        artist.use = true
        return artist
    }
    
    // オートインクリメント機能
    static func lastId() -> Int {
        if let tail = realm.objects(GenreData).last {
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
        
        
        let artist = realm.objects(GenreData).filter("name = %@",name_!)
        if(artist.count == 0){
            return false
        } else {
            return true
        }
    }
    
    func save(){
        try! GenreData.realm.write{
            GenreData.realm.add(self)
        }
    }
    
    
    static func DataSet(){
        // 端末にある音楽を取得
        let query = MPMediaQuery.genresQuery()
        
        // クラウドにある音楽をフィルターで取り除く
        query.addFilterPredicate(MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem))
        
        if let collections = query.collections {
            for collection in collections {
                if let genreName = collection.representativeItem!.genre {
                    // すでに保存しているかチェック
                    if(GenreData.existCheckByInfo(genreName) == true){
                        continue
                    }
                    let s = GenreData.create(genreName)
                    
                    s.save()
                }
            }
        }
    }
    
    
    // すべての曲の情報を取得する
    // 引数のsonginfoに格納する
    static func getAllGenreInfo(inout genreInfo: [[AnyObject]]) {
        genreInfo.removeAll()
        
        let artists = realm.objects(GenreData)
        for artist in artists {
            genreInfo.append([artist.name, artist.use, false])
        }
    }
    
    static func getSongInfoByGenreName(genreName: String) -> [SongInfo] {
        var songInfo: [SongInfo] = []
        let songs = realm.objects(SongData).filter("genre = %@", genreName)
        
        if(songs.count == 0){
            return songInfo
        } else {
            for song in songs {
                let key_song_number = KeySongData.keySongCheck(song.id)
                
                songInfo.append(SongInfo(id: song.id, title: song.name, use: song.use,
                    artist: song.artist, album: song.album, duration: song.duration, key_song_number: key_song_number))
            }
        }
        return songInfo
    }
    
    
    // useを更新する
    static func updateUseableByName(genreName: String, use: Bool) {
        let artist = realm.objects(GenreData).filter("name = %@", genreName)
        if(artist.count == 0){
            return
        } else {
            let s = artist[0]
            try! GenreData.realm.write{
                s.use = use
                GenreData.realm.add(s, update: true)
            }
        }
    }
}