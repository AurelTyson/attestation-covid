//
//  CertificateListViewController.swift
//  AttestationCovid
//
//  Created by David Yang on 11/04/2020.
//  Copyright © 2020 David Yang. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class CertificateListViewController: UITableViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var deleteAllCertificatesButton: UIBarButtonItem!
    
    // MARK: Attributes
    
    private var certificates: [URL] = []
    
    private var documentDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 65
        self.tableView.register(cellType: CertificateTableViewCell.self)
        
        // Delete all certificates
        self.deleteAllCertificatesButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                
                self?.showDeleteAllCertificatesAlert()
                
            })
            .disposed(by: self.disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reload data
        self.load {
            
            // Reload tableView
            self.tableView.reloadData()
            
        }
        
    }
    
    // MARK: Methods
    
    private func load(completion: () -> Void) {
        if let documentDirectory = documentDirectory,
           var files = try? FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: []) {
            
            // Sort by date, show newest on top of the list
            try? files.sort { (leftUrl: URL, rightUrl: URL) -> Bool in
                
                let leftAttributes = try FileManager.default.attributesOfItem(atPath: leftUrl.path)
                let rightAttributes = try FileManager.default.attributesOfItem(atPath: rightUrl.path)
                
                return (leftAttributes[.creationDate] as? Date ?? Date()) > (rightAttributes[.creationDate] as? Date ?? Date())
                
            }
            
            self.certificates = files
            completion()
        }
    }
    
    private func removeCertificate(at index: Int) throws {
        try FileManager.default.removeItem(at: self.certificates[index])
        self.certificates.remove(at: index)
    }
    
    private func removeAllCertificates() throws {
        
        // Foreach certificate index
        try self.certificates.forEach { (url: URL) in
            
            // Delete item at url
            try FileManager.default.removeItem(at: url)
            
        }
        
        // Reload data
        self.load() {
            
            // Reload tableView
            self.tableView.reloadData()
            
        }
        
    }
    
    private func showDeleteAllCertificatesAlert() {
        
        // Alert controller
        let alertController = UIAlertController(title: "certificates.deleteall.alert.title".localized(),
                                                message: NSLocalizedString("certificates.deleteall.alert.message", comment: ""),
                                                preferredStyle: .alert)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "certificates.deleteall.alert.cancel".localized(),
                                         style: .default,
                                         handler: nil)
        alertController.addAction(cancelAction)
        
        // Delete action
        let deleteAction = UIAlertAction(title: "certificates.deleteall.alert.delete".localized(),
                                         style: .destructive,
                                         handler: { [weak self] _ in
                                            
                                            do {
                                                
                                                // Remove all certificates
                                                try self?.removeAllCertificates()
                                                
                                            }
                                            catch {
                                                
                                                self?.showAlert(message: "Une erreur s'est produite. Impossible de supprimer les attestations")
                                                
                                            }
                                            
                                         })
        alertController.addAction(deleteAction)
        
        // Show alert
        self.present(alertController,
                     animated: true,
                     completion: nil)
        
    }
    
}

extension CertificateListViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return certificates.count
        
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue the cell
        let cell = tableView.dequeueReusableCell(cellType: CertificateTableViewCell.self)
        
        // Configure
        cell.configure(fileURL: certificates[indexPath.row])
        
        return cell
        
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let documentURL = certificates[indexPath.row]
        
        let attestationViewController = CertificateViewController(documentURL: documentURL)
        let navigationController = UINavigationController(rootViewController: attestationViewController)
        present(navigationController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try removeCertificate(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                self.showAlert(message: "Une erreur s'est produite. Impossible de supprimer l'attestation")
            }
        }
    }
    
}
