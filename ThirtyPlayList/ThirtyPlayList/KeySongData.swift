//
//  KeySongData.swift
//  ThirtyPlayLIst_Bata
//
//  Created by 坂田 和也 on 2016/08/25.
//  Copyright © 2016年 SKT. All rights reserved.
//

import RealmSwift
import MediaPlayer

// キーソングを格納するテーブル
class KeySongData: Object {
    static let realm = try! Realm()
    
    dynamic var id = 0
    dynamic var songdata_id = 0
    dynamic var key_song_number = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(songdata_id: Int, key_song_number: Int) -> KeySongData {
        let key_song = KeySongData()
        key_song.id = lastId()
        key_song.songdata_id = songdata_id
        key_song.key_song_number = key_song_number

        return key_song
    }
    
    static func lastId() -> Int {
        if let tail_song = realm.objects(KeySongData).last {
            return tail_song.id+1
        } else {
            return 1
        }
    }
    
    // すでに存在するならそれを更新する
    func save(){
        let song = KeySongData.realm.objects(KeySongData).filter("key_song_number = %@",self.key_song_number)
        if(song.count == 0){
            try! SongData.realm.write{
                SongData.realm.add(self)
            }
        } else {
            try! SongData.realm.write{
                self.id = song[0].id
                SongData.realm.add(self, update: true)
            }
        }
    }
    
    // キーソングかどうかチェック
    static func keySongCheck(songdata_id: Int) -> Int {
        let keysong = realm.objects(KeySongData).filter("songdata_id = %@",songdata_id)
        if(keysong.count == 0){
            return -1
        } else {
            return keysong[0].key_song_number
        }
    }
    
    // キーソングが設定されているかチェック
    static func KeySongisSet() ->Bool{
        var isSet = true
        for i in 1...6 {
            let keysong = realm.objects(KeySongData).filter("key_song_number = %@", i)
            if(keysong.count == 0){
                isSet = false
            } else {
                let song = realm.objects(SongData).filter("id = %@",keysong[0].songdata_id)
                if(song.count == 0){
                    isSet = false
                }
                
            }
        }
        return isSet
    }
    
    // すべてのキーソングを取得
    static func getAllKeySongInfo() ->[SongInfo] {
        var songinfo: [SongInfo] = []
        
        
        let keysongs = realm.objects(KeySongData).sorted("key_song_number")
        for keysong in keysongs {
            let song = realm.objects(SongData).filter("id = %@",keysong.songdata_id)
            songinfo.append(SongInfo(id: song[0].id, title: song[0].name, use: song[0].use,
                artist: song[0].artist, album: song[0].album, duration: song[0].duration, key_song_number: keysong.key_song_number))
        }
        return songinfo
    }
    
    // 再生回数順にキーソングを取得する
    static func autoKeySongSet() ->Bool {
        var playCounts: [Int] = []
        var playCountsIds: [Int] = []
        let query = MPMediaQuery.albumsQuery()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem))

        if let songs = query.items {
            for song in songs {
                let id = SongData.getIdSongByInfo(song.title,artist: song.artist, album: song.albumTitle)
                if(id != -1){
                    playCounts.append(song.playCount)
                    playCountsIds.append(id)
                }
            }
        }
        if(playCounts.count == 0){
            return false
        }
        
        let sorted = playCounts.sort()
        var i = sorted.count-1
        var key_song_id: [Int] = []
        while (i >= sorted.count-6){
            var j = 0
            while(playCounts[j] != sorted[i]){j+=1}
            key_song_id.append(playCountsIds[j])
            i-=1;
        }
        
        for i in 0..<key_song_id.count {
            let key_song = KeySongData.create(key_song_id[i],key_song_number: i+1)
            key_song.save()
        }
        return true
    }
}
