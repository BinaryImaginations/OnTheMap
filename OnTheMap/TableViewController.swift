//
//  TableViewController.swift
//  OnTheMap
//
//  Created by George McMullen on 8/6/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: ControllerHelper, UITableViewDataSource, UITableViewDelegate {
    
    // Outlet for the table view object
    @IBOutlet weak var tableView: UITableView!
    
    // View loaded in memory
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // View about to appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // View is showing
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Reload the table view object (so that we show new items)
        tableView.reloadData()
    }

    // Return the number of cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of records in the array
        return ParseClient.sharedInstance().students.count
    }
    
    // Populate the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! UITableViewCell
        // Get the object from the array using the selected row
        let studentData = ParseClient.sharedInstance().students[indexPath.row]
        cell.textLabel!.text = studentData.mapPin.title
        cell.imageView!.image = UIImage(named: "Pin")
        cell.detailTextLabel!.text = studentData.mapPin.subtitle
        return cell
    }
    
    // Get the selected cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapPin = ParseClient.sharedInstance().students[indexPath.row].mapPin
        if let url = NSURL(string: mapPin.subtitle!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func pinPressed(sender: AnyObject) {
        // Create a new controller to our add pin controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AddPinViewController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        // Logout of Udacity
        UdacityClient.sharedInstance().logOut() { (complete) in
            if !complete {
                println("Failure")
            }
        }
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
}



