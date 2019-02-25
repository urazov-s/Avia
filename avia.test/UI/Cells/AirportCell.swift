//
//  AirportCell.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

struct AirportCellViewModel {
    let title: String
    let subtitle: String
}

final class AirportCell: UITableViewCell, Configurable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.textColor = .xMainText
        titleLabel.font = .xMedium(16)

        subtitleLabel.textColor = .xDetailedText
        subtitleLabel.font = .xRegular(14)
    }

    func configure(_ model: AirportCellViewModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }

}
