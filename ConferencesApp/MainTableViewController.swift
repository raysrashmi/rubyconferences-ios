//
//  MainTableViewController.swift
//  ConferencesApp
//
//  Created by Rashmi Yadav on 5/1/15.
//
//

import UIKit
import Haneke

class MainTableViewController: UITableViewController, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let CellIdentifier = "cell"
    var conferences:[Conference] =  []
    var filterConferences: [Conference] = []
    var conferenceDataStore = ConferenceDataStore()
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        searchBar.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ConferencesUpdatedNotificationHandler:",
            name:"ConferencesUpdatedNotification", object: nil)
        
        if Reachability().connectedToNetwork() {
            conferenceDataStore.getConferencesFromApi()
        }
    }
    
    func reloadData() {
        if Reachability().connectedToNetwork() {
            conferenceDataStore.getConferencesFromApi()
        } else {
            let alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    dynamic func ConferencesUpdatedNotificationHandler(notification: NSNotification) {
        conferences = conferenceDataStore.findAll()
        
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterConferences = conferenceDataStore.filterConferences(searchText)
        
        if(filterConferences.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    func conferencesData() -> [Conference]{
        if(searchActive){
            return filterConferences
        }else{
            return conferences
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let row_count: Int = conferencesData().count
        
        return row_count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        let conferenceInfo = conferencesData()[indexPath.row]
        
        let imageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        let logo_url = NSURL(string: conferenceInfo.logo_url)!
        imageView.hnk_setImageFromURL(logo_url)
        
        let title: UILabel = cell.contentView.viewWithTag(101) as! UILabel
        title.text = conferenceInfo.name
                
        let location: UILabel = cell.contentView.viewWithTag(103) as! UILabel
        location.text = conferenceInfo.place
        
        let when: UILabel = cell.contentView.viewWithTag(104) as! UILabel
        when.text = conferenceInfo.when
        
        return cell
    
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if(self.tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(self.tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        cell.preservesSuperviewLayoutMargins = false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
        if segue.identifier == "viewConference" {
            let selectedRow = tableView.indexPathForSelectedRow?.row
            let viewController = segue.destinationViewController as! ConferenceTableViewController

            viewController.conference = conferences[selectedRow!]
            viewController.conferenceDataStore = self.conferenceDataStore   
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
