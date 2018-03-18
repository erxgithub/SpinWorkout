//
//  WorkoutTableViewCell.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        styleTextLabel(textLabel: workoutTitleLabel)
        styleTextLabel(textLabel: setCountLabel)
        styleTextLabel(textLabel: totalDurationLabel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func styleTextLabel(textLabel: UILabel) {
        
        textLabel.layer.shadowColor = UIColor.black.cgColor
        textLabel.layer.shadowOpacity = 0.75
        textLabel.layer.shadowRadius = 3.0
        textLabel.layer.shadowOffset = CGSize(width: 1.5, height: 2.5)
        textLabel.layer.masksToBounds = false
        textLabel.textColor = UIColor.white

    }

}
