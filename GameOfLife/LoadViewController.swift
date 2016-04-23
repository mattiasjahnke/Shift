//
//  LoadViewController.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

class LoadCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.textColor = .whiteColor()
    }
}

class LoadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let data: [String] = /*[]*/["Foo", "Bar"]
    let staticData: [String] = ["Static"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? data.count : staticData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Your saves" : "Presets"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? LoadCell else { fatalError() }
        
        let text = indexPath.section == 0 ? data[indexPath.row] : staticData[indexPath.row]
        
        cell.textLabel!.text = text
        
        return cell
    }
}
