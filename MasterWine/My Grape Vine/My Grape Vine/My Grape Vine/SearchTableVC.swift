//
//  SearchTableVC.swift
//  My Grape Vine
//
//  Created by Daniel Martin (RIT Student) on 4/26/17.
//  Copyright © 2017 Daniel Martin (RIT Student). All rights reserved.
//
// API KEY 7dbccdc4de31b4985e1d024a261828e5
// URL Format http://services.wine.com/api/beta2/service.svc/format/resource?apikey=key&parameters

import UIKit

class SearchTableVC: UITableViewController {
    
    var key:String = "7dbccdc4de31b4985e1d024a261828e5"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    
    var searchResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        title = "Wine Journal"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(_ data: Data?){
        searchResults.removeAll()
        
        guard let data = data else{
            print("data is nil!")
            return
        }
        do{
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] else {
                print("JSON error")
                return
            }
            
            guard let outerDictionary = responseDictionary["Products"] as? [String: AnyObject] else{
                print("results key not found in dictionary - probably an error page")
                return
            }
            
            guard let array: AnyObject = outerDictionary["List"] else{
                print("results key not found in dictionary - probably an error page")
                return
            }
            
            for wineDictionary in array as! [AnyObject] {
                guard let wineDictionary = wineDictionary as? [String: AnyObject] else{
                    print("Not a dictionary - bail out")
                    return
                }
                
                let id = wineDictionary["Id"] as? String ?? "Unknown Id"
                
                let name = wineDictionary["Name"] as? String ?? "Unknown Name"
                
                let printString = "id=\(id),name=\(name)"
                print(printString)
                
                
                let s = "\(id) -- \(name)"
                searchResults.append(s)
                
            }
                
                
//            } else {
//                print("JSON error")
//            }
            print(searchResults)
        } catch {
            print("Error parsing results: \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row]
        // Configure the cell...
        
        return cell
    }
    
    //MARK - Helpers
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
}

//MARK - UISearchBarDelegate Methods
extension SearchTableVC:UISearchBarDelegate{
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        //check if there is a letter in the search bar
        let text = searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else{
            return
        }
        
        //kill dataTask if there is already one running
        if let dataTask = dataTask {
            dataTask.cancel()
        }
        
        
        // add url encoding for special chars
//        guard let searchTerm = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
//            print("||||Something is wrong with url||||")
//            return
//        }
        
        //build url to itunes web service
        guard let url = URL(string: "http://services.wine.com/api/beta2/service.svc/json/catalog?apikey=7dbccdc4de31b4985e1d024a261828e5&size=25&offset=0&filter=categories(7155+124)term=mondavi+cab") else {
            print(" ||||||Something is wrong with url|||||")
            return
        }
        
        //start spinner in status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //start downloading url
        dataTask = defaultSession.dataTask(with: url as URL) {
            data, response, error in
            
            //calling ui codeon main thread so it works consistently
            DispatchQueue.main.async {
                //hide the spinner
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //if there is an error print, otherwise continue with data
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.updateSearchResults(data)
                    }
                    print(httpResponse.statusCode)
                }
            }
        }
        //resume starts the download
        dataTask?.resume()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}
