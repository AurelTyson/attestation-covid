//
//  CertificateTableViewCell.swift
//  AttestationCovid
//
//  Created by Aurélien Tison on 30/10/2020.
//  Copyright © 2020 David Yang. All rights reserved.
//

import UIKit

public final class CertificateTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var generatedAtLabel: UILabel!
    
    // MARK: Attributes
    
    private let dateFormatter = DateFormatter()
    
    // MARK: TableViewCell
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure date formatter
        self.dateFormatter.dateStyle = .full
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.doesRelativeDateFormatting = true
        
        // Cell
        self.selectionStyle = .none
        
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Methods
    
    public func configure(fileURL: URL) {
        
        // Generated at
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let creationDate = attributes[.creationDate] as? Date {
            
            let dateValue = self.dateFormatter.string(from: creationDate)
            self.generatedAtLabel.text = "certificates.row.generatedAt".localizedFormat(dateValue)
            
        }
        else {
            
            self.generatedAtLabel.text = ""
            
        }
        
    }
    
}
