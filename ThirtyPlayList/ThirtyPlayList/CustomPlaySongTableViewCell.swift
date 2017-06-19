//
//  CustomPlaySongTableViewCell.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/29.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

class CustomPlaySongTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var SongImg: UIImageView!
    @IBOutlet weak var SongTitle: UILabel!
    @IBOutlet weak var SongDuration: UILabel!
    @IBOutlet weak var KeySongImg: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setKeySongImginPlaylist(key_song_number: Int){
        if(key_song_number == -1){
            KeySongImg.image = nil
        } else {
            KeySongImg.image = UIImage(named: "keysong_icon_" + key_song_number.description)
        }
    }

}
