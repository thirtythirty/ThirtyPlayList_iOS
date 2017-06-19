//
//  CustomHeaderFooterView.swift
//  ThirtyPlayList
//
//  Created by 坂田 和也 on 2016/09/19.
//  Copyright © 2016年 SKT. All rights reserved.
//

import UIKit

protocol SongHeaderCellDelegate {
    func updateUseableInSameSection(section: Int,use: Bool)
}

class CustomHeaderFooterView: UITableViewHeaderFooterView {

    var section: Int = 0

    var arrow = UIImageView()
    var headerTitle = UILabel()
    var headerSwitch = UISwitch()
    
    var delegate: SongHeaderCellDelegate?


    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.arrow.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.arrow)
        self.contentView.addConstraints([
            NSLayoutConstraint(item: arrow, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: arrow, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: arrow,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.contentView,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.0,
                constant: 30),
            NSLayoutConstraint(item: arrow,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.contentView,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.0,
                constant: 30)])
        
        
        self.headerSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.headerSwitch)
        self.contentView.addConstraints([
            NSLayoutConstraint(item: headerSwitch, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: -12),
            NSLayoutConstraint(item: headerSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0)])
        headerSwitch.addTarget(self, action: #selector(CustomHeaderFooterView.onClickHeaderSwitch(_:)), forControlEvents: UIControlEvents.ValueChanged)
        headerSwitch.onTintColor = UIColor(red: 72/255, green: 187/255, blue: 255/255, alpha: 1.0)
        
        self.headerTitle.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.headerTitle)
        self.contentView.addConstraints([
            NSLayoutConstraint(item: headerTitle, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 50),
            NSLayoutConstraint(item: headerTitle, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: headerTitle,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.contentView,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.0,
                constant: 30)
            , NSLayoutConstraint(item: headerTitle, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.0, constant: 200)
            ])
        headerTitle.textColor = UIColor.grayColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func onClickHeaderSwitch(sender: UISwitch){
        updateUseableInSameSection(section,use: sender.on)
        if sender.on {
            print("on")
        }
        else {
            print("off")
        }
    }
    
    func setExpanded(expanded: Bool) {
        if(expanded == true){
            arrow.image = UIImage(named: "arrow_up")
        } else {
            arrow.image = UIImage(named: "arrow_down")
        }
    }
    
    func updateUseableInSameSection(section: Int,use: Bool){
        delegate?.updateUseableInSameSection(section, use: use)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
