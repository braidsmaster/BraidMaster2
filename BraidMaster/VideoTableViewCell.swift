//
//  VideoTableViewCell.swift
//  BraidMaster
//
//  Created by Kirill Lukyanov on 21.06.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoPlayerSuperView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
