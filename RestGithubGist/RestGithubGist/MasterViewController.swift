//
//  MasterViewController.swift
//  RestGithubGist
//
//  Created by Jimmy Hoang on 3/24/17.
//  Copyright © 2017 Jimmy Hoang. All rights reserved.
//

import UIKit
import PINRemoteImage

class MasterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var detailViewController: DetailViewController? = nil
    var gists = [Gist]()
    
    var nextPageURLString: String?
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject))
        self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = gists[indexPath.row]
                
                if let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController {
                    controller.detailItem = gist
                    
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title: "Not Implemented", message: "Can't create new gists yet, will implement later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadGists(urlToLoad: String?) {
        self.isLoading = true
        
        GithubAPIManager.shared.fetchPublicGists(pageToLoad: urlToLoad) { (result, nextPage) in
            self.isLoading = false
            self.nextPageURLString = nextPage
            
            if self.tableView.refreshControl != nil, self.tableView.refreshControl!.isRefreshing {
                self.tableView.refreshControl?.endRefreshing()
            }
            
            guard result.error == nil else {
                self.handleLoadGistsError(result.error!)
                return
            }
            
            guard let fetchedGists = result.value else {
                print("no gists fetched")
                return
            }
            
            if urlToLoad == nil {
                self.gists = []
            }
            
            self.gists += fetchedGists
            
            self.tableView.reloadData()
        }
    }
    
    func handleLoadGistsError(_ error: Error) {
        
    }
    
    // MARK: - Pull to Refresh
    func refresh(sender: Any) {
        nextPageURLString = nil // so it doesnt try to append the results
        GithubAPIManager.shared.clearCache()
        loadGists(urlToLoad: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // pull to refresh
        if tableView.refreshControl == nil {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadGists(urlToLoad: nil)
    }
    
}

extension MasterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let gist = gists[indexPath.row]
        cell.textLabel?.text = gist.description
        cell.detailTextLabel?.text = gist.ownerLogin
        cell.imageView?.image = nil
        
        if let urlString = gist.ownerAvatarURL, let url = URL(string: urlString) {
            
            cell.imageView?.pin_setImage(from: url, placeholderImage: UIImage(named: "Avatar"), completion: { (result) in
                if let cellToUpdate = self.tableView.cellForRow(at: indexPath) {
                    
                    // Will work even if image is nil, need reload view - which wont happen otherwise since this is async call
                    cellToUpdate.setNeedsLayout()
                }
            })
        } else {
            cell.imageView?.image = UIImage(named: "Avatar")
        }
        
        if !isLoading {
            let rowsLoaded = gists.count
            let rowsRemaining = rowsLoaded - indexPath.row
            let rowsToLoadFromBottom = 5
            
            if rowsRemaining <= rowsToLoadFromBottom {
                if let nextPage = nextPageURLString {
                    self.loadGists(urlToLoad: nextPage)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            gists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
}
