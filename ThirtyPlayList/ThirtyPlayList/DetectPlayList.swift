//
//  DetectPlayList.swift
//  ThirtyPlayLIst_Bata
//
//  Created by 坂田 和也 on 2016/08/23.
//  Copyright © 2016年 SKT. All rights reserved.
//

import Foundation
import RealmSwift

// 任意の時間のplaylsitを算出する計算機クラス
class Detector {
    // keysong以外の曲を格納
    private var Songs: [SongList] = []
    // keysong(分割の最後にくる曲)を格納
    private var KeySongs: [SongList] = []
    
    init() {
        let realm = try! Realm() // データベース
        
        let key_songs = realm.objects(KeySongData) // KeySongDataテーブル
        let songs = realm.objects(SongData) // SongDataテーブル
        
        // KeySongsを初期化
        for key_song in key_songs {
            // KeySongDataテーブルからキーソングのSongDataのidを取得し、それを元にSongDataテーブルから情報を取得しKeySongsに格納
            let s = realm.objects(SongData).filter("id = %@",key_song.songdata_id)
            if(s.count != 0){
                KeySongs.append(SongList(songsId: [s[0].id],duration: s[0].duration))
            }
        }
        
        // Songsを初期化
        for song in songs {
            var uninclude_keysong = true
            for keysong in KeySongs {
                if(song.id == keysong.songsId[0]){
                    uninclude_keysong = false
                    break
                }
            }
            // キーソング以外を格納する
            if(uninclude_keysong == true){
                if(song.use == true){
                    Songs.append(SongList(songsId: [song.id],duration: song.duration))
                }
            }
        }
        // Songsを２つ組み合わせてものを一つのSongList構造体として格納する
        let single_songlist_count = Songs.count // 一つの曲の数
        var i = 0
        while i < single_songlist_count {
            var j = i+1
            while j < single_songlist_count {
                // 二つ曲を組み合わせ、一つの曲として扱う
                Songs.append(
                    SongList(songsId: Songs[i].songsId + Songs[j].songsId,
                        duration: Songs[i].duration + Songs[j].duration)
                )
                j+=1
            }
            i+=1
        }
        
        
        // Songsの数が0場合ははじく
        if(Songs.count == 0){
            return
        }
        // 昇順にソート
        quickSort(&Songs,first: 0,last: Songs.count-1)
    }
    
    // 任意の時間から十五分プレイリストを組み合わせて完成してプレイリストを返す関数
    // minute: 15~90の間
    func makePlayList(minute: Int, split: Int) ->SongList {
        var playlist:SongList = SongList(songsId: [],duration: 0)
        
        // 時間が短すぎる場合プレイリストが作れない可能性が高い
        // keysongは6個しか設定しないので、90分以上は作れないのではじく
        if(minute < 15 || minute > 90){
            return SongList(songsId: [],duration: 0)
        }
        // SongsやKeySongsの数が少なすぎる場合ははじく
        if(Songs.count <= 10 || KeySongs.count < 6){
            return SongList(songsId: [],duration: 0)
        }
        if(split < 1 || split > 6){
            return SongList(songsId: [],duration: 0)
        }
        
        var splitedDuration = Double(minute)/Double(split)
        var use_keysong = split-1 // はじめに使うキーソング
        
        for i in 0..<split {
            // keysongを追加さらにランダムに曲を選んであと17分以下にしてからdetectPlayList関数より計算
            var target_success_flag = false
            // 乱数を使うのでうまくいかなかったら3回までトライする
            for try_num in 0..<3 {
                var target_duration = splitedDuration * 60
                var target_songlist = SongList(songsId: [], duration: 0)
                target_duration -= KeySongs[use_keysong].duration
                while(target_duration > 17.0 * 60.0){
                    let rand = Int(arc4random_uniform(UInt32(Songs.count)))
                    var target_songsId = target_songlist.songsId + Songs[rand].songsId
                    if(uniqueCheck(&target_songsId)){
                        target_songlist.songsId += Songs[rand].songsId
                        target_songlist.duration += Songs[rand].duration
                        target_duration -= Songs[rand].duration
                    }
                }
                var results = detectPlayList(target_duration)
                if(results.count == 0){
                    continue
                } else {
                    // 3回ランダムを試す
                    for k in 0..<3 {
                        let rand = Int(arc4random_uniform(UInt32(results.count)))
                        var target_songsId = target_songlist.songsId + results[rand].songsId
                        if(uniqueCheck(&target_songsId)){
                            playlist.duration += target_songlist.duration + results[rand].duration
                            playlist.songsId +=  target_songlist.songsId + results[rand].songsId
                            target_success_flag = true
                            break
                        }
                    }
                    if(target_success_flag == true){
                        break
                    }
                    // 最初から探す
                    for result in results {
                        var target_songsId = target_songlist.songsId + result.songsId
                        if(uniqueCheck(&target_songsId)){
                            playlist.duration += target_songlist.duration + result.duration
                            playlist.songsId +=  target_songlist.songsId + result.songsId
                            target_success_flag = true
                            break
                        }
                    }
                    if(target_success_flag == true){
                        break
                    }
                }
            }
            if(target_success_flag == false){
                // 見つからなかった
                return SongList(songsId: [],duration: 0)
            }
            // 見つかった
            // キーソングを最後に追加
            playlist.duration += KeySongs[use_keysong].duration
            playlist.songsId += KeySongs[use_keysong].songsId
            // 一つぶんできたのでデクリメント
            use_keysong-=1
        }
        
        
        return playlist
    }
    
    // 任意の時間のPlayListを作る関数
    // 返り値はSongListの配列
    // Songsの各組み合わせだけを検索(2~4曲の組み合わせだけ)とし、検索範囲を縮小
    // 二分探索を用いて高速化
    func detectPlayList(duration: Double) ->[SongList]{
        var detectSongs: [SongList] = []
        let range = [0.1, 1.0]
        
        for r in range {
            for i in 0..<Songs.count {
                // Songs[i]を使用する場合を二分探査で検索
                var results = binarySearch(duration-Songs[i].duration, range: r)
                
                if(results.count > 0){ // 一つでもあったなら
                    for j in 0..<results.count  {
                        // Song[i]を組み合わせる
                        results[j].duration += Songs[i].duration
                        results[j].songsId += Songs[i].songsId
                        // 要素が重複していないなら、追加
                        if(uniqueCheck(&results[j].songsId)){
                            detectSongs.append(results[j])
                        }
                    }
                }
            }
            if(detectSongs.count > 0){
                break
            }
        }

        return detectSongs
    }
    
    // 与えられたSongList配列をduration(再生時間)を元に昇順ソート
    private func quickSort(inout songs: [SongList],first: Int,last: Int){
        var right = last
        var left = first
        
        let pivot = first
        while(left < right){
            while(songs[left].duration <= songs[pivot].duration && left < last){left+=1}
            while(songs[right].duration > songs[pivot].duration && right > first){right-=1}
            if(left < right){
             (songs[right], songs[left]) = (songs[left],songs[right])
            }
        }
        
        (songs[pivot], songs[right]) = (songs[right],songs[pivot])
        if((right-1)-first > 0){
            quickSort(&songs,first: first, last: right-1)
        }
        if(last-left > 0){
            quickSort(&songs,first: left, last: last)
        }
    }
    
    // 与えられた時間の曲をSongs配列から二分探索で探す関数
    // 許容誤差分すべて取ってくる
    private func binarySearch(duration: Double, range: Double) ->[SongList]{
        var left = -1
        var right = Songs.count
        var songs: [SongList] = []
        
        while (right - left > 1){
            let mid = (left+right)/2
            if (Songs[mid].duration <= duration && Songs[mid].duration >= duration-range){
                var i = mid
                while(i+1 < Songs.count && Songs[i+1].duration <= duration){ i+=1 }
                while(i >= 0 && Songs[i].duration >= duration-range){
                    songs.append(Songs[i])
                    i-=1
                }
                return songs
            } else if(Songs[mid].duration < duration-range) {
                left = mid
            } else {
                right = mid
            }
        }
        return songs
    }
    
    // 与えれれたInt型配列に重複がないか判定
    func uniqueCheck(inout a: [Int]) ->Bool{
        var i = 0
        var unique = true
        while(i < a.count){
            var j = i+1
            while(j < a.count){
                if(a[i] == a[j]){
                    unique = false
                    break
                }
                j+=1
            }
            if(unique == false){ break }
            i+=1
        }
        return unique
    }
}