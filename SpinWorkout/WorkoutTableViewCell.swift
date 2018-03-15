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
    
    var gradientLayer: CAGradientLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.5
//        cardView.layer.shadowRadius = 3.0
//        cardView.layer.shadowOffset = CGSize(width: 1.5, height: 2.5)
//        cardView.layer.masksToBounds = false

        styleTextLabel(textLabel: workoutTitleLabel)
        styleTextLabel(textLabel: setCountLabel)
        styleTextLabel(textLabel: totalDurationLabel)
        
        createGradientLayer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func createGradientLayer() {
        
        let topColor = UIColor(red: 36.0/255.0, green: 48.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 46.0/255.0, green: 53.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = cardView.bounds
        gradientLayer.colors = [topColor, bottomColor]
        cardView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func styleTextLabel(textLabel: UILabel) {
        
        textLabel.layer.shadowColor = UIColor.black.cgColor
        textLabel.layer.shadowOpacity = 0.75
        textLabel.layer.shadowRadius = 3.0
        textLabel.layer.shadowOffset = CGSize(width: 1.5, height: 2.5)
        textLabel.layer.masksToBounds = false

    }

}
