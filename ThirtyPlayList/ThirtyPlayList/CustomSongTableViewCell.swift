//
//  CustomSongTableViewCell.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/08/27.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

protocol SongCellDelegate {
    func updateUseable(section: Int, index: Int,use: Bool)
}

class CustomSongTableViewCell: UITableViewCell {
    
    public var songId: Int = 0
    var section: Int = 0
    var index: Int = 0
    var delegate: SongCellDelegate?
    
    @IBAction func SongUseSwitch(sender: UISwitch) {
        SongData.updateUseableById(songId,use: sender.on)
        updateUseable(section, index: index, use: sender.on)
    }
    @IBOutlet weak var SongUseSwitch_Outlet: NSLayoutConstraint!
    
    @IBOutlet weak var SongTitle: UILabel!
    @IBOutlet weak var keysong_img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setKeySongImg(key_song_number: Int){
        if(key_song_number == -1){
            keysong_img.image = UIImage(named: "keysong_icon_unset")
        } else {
            keysong_img.image = UIImage(named: "keysong_icon_" + key_song_number.description)
        }
    }
    
    func updateUseable(section: Int, index: Int,use: Bool){
        delegate?.updateUseable(section, index: index, use: use)
    }
}
