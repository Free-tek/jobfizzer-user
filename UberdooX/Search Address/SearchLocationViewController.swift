//
//  SearchLocationViewController.swift
//  UberdooX
//
//  Created by admin on 2/13/19.
//  Copyright © 2019 Uberdoo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import SwiftyJSON

protocol SearchLocationViewControllerDelegate: class
{
    func didSelectLocation(lat: Double,log: Double)
}

class SearchLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GMSAutocompleteFetcherDelegate,OfflineViewControllerDelegate
{
    func tryAgain() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var resultsArray: [NSDictionary] = []
    var gmsFetcher: GMSAutocompleteFetcher!
    weak var delegate: SearchLocationViewControllerDelegate?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /*        let headerNib = UINib.init(nibName: "SearchMapHeader", bundle: Bundle.main)
         tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "SearchMapHeader")*/
        tableView.register(UINib(nibName: "SearchMapCell", bundle: nil), forCellReuseIdentifier: "SearchMapCell")
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        gmsFetcher = GMSAutocompleteFetcher()
        gmsFetcher.delegate = self
        tableView.keyboardDismissMode = .onDrag
        //        tableView.contentInset = UIEdgeInsets.zero
        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.tableHeaderView = nil
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    @IBAction func back(_ sender: Any)
    {
        //        view.window!.layer.add(presentLeft(), forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
        //        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return resultsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    /*    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
     {
     let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchMapHeader") as! SearchMapHeader
     
     headerView.currentLocationBtn.addTarget(self, action: #selector(SearchLocationViewController.currentLocation(sender:)), for: .touchUpInside)
     
     
     return headerView
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
     {
     return 139
     }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMapCell", for: indexPath) as! SearchMapCell
        
        if resultsArray.count != 0
        {
            let dict : NSDictionary = resultsArray[indexPath.row]
            
            cell.locationLbl.text = dict["place"] as? String ?? ""
            cell.detailLbl.text = dict["complete"] as? String ?? ""
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    /*    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
     {
     return 0
     }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 67
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dict : NSDictionary = resultsArray[indexPath.row]
        //        getLatAndLog(location:dict["complete"] as? String ?? "")
        searchBar.resignFirstResponder()
        getAddress(address: dict["complete"] as? String ?? "")
    }
    
    
    @objc func currentLocation(sender: UIButton)
    {
        //        view.window!.layer.add(presentRight(), forKey: kCATransition)
        //        let StoaryBoard = UIStoryboard.init(name: "HomeStoryboard", bundle: nil)
        //        let presentedVC = StoaryBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        //        presentedVC.isDirectLocation = true
        //        self.navigationController?.pushViewController(presentedVC, animated: true)
        //        present(presentedVC, animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if Reachability.isConnectedToNetwork() {
            self.resultsArray.removeAll()
            gmsFetcher?.sourceTextHasChanged(searchText)
        }else {
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if Reachability.isConnectedToNetwork() {
            searchBar.resignFirstResponder()
        }else {
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    public func didFailAutocompleteWithError(_ error: Error)
    {
        
    }
    
    public func didAutocomplete(with predictions: [GMSAutocompletePrediction])
    {
        for prediction in predictions
        {
            if let prediction = prediction as GMSAutocompletePrediction!
            {
                let dict : NSDictionary = ["place":prediction.attributedPrimaryText.string,"complete":prediction.attributedFullText.string]
                self.resultsArray.append(dict)
            }
        }
        self.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }
    
    func reloadDataWithArray(_ array:[NSDictionary])
    {
        self.resultsArray = array
        tableView.reloadData()
    }
    
}
extension SearchLocationViewController
{
    func getAddress(address:String)
    {
        if Reachability.isConnectedToNetwork() {
            let key : String = Constants.mapsKey
            let postParameters:[String: Any] = [ "address": address,"key":key]
            let url : String = "https://maps.googleapis.com/maps/api/geocode/json"
            
            Alamofire.request(url, method: .get, parameters: postParameters, encoding: URLEncoding.default, headers: nil).responseJSON
                {
                    response in
                    if let receivedResults = response.result.value
                    {
                        let resultParams = JSON(receivedResults)
                        print(resultParams)
                        print(resultParams["status"])
                        
                        if resultParams["results"].count > 0
                        {
                            print(resultParams["results"][0]["geometry"]["location"]["lat"].doubleValue)
                            print(resultParams["results"][0]["geometry"]["location"]["lng"].doubleValue)
                            
                            self.delegate?.didSelectLocation(lat: resultParams["results"][0]["geometry"]["location"]["lat"].doubleValue, log: resultParams["results"][0]["geometry"]["location"]["lng"].doubleValue)
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            //                    self.moveViewController(lat: resultParams["results"][0]["geometry"]["location"]["lat"].doubleValue, log: resultParams["results"][0]["geometry"]["location"]["lng"].doubleValue)
                        }
                        else
                        {
                            //                    self.showAlertError(messageStr: resultParams["error_message"].stringValue)
                        }
                    }
                    else
                    {
                        
                    }
            }
        }else{
            let stoaryBoard = UIStoryboard.init(name: "SecondStoryboard", bundle: nil)
            let Dvc = stoaryBoard.instantiateViewController(withIdentifier: "OfflineViewController")as! OfflineViewController
            Dvc.modalTransitionStyle = .crossDissolve
            Dvc.delegate = self
            present(Dvc, animated: true, completion: nil)
        }
    }
    
    
    func getLatAndLog(location :String)
    {
        //        let urlpath = "https://maps.googleapis.com/maps/api/geocode/json?address=\(location)&sensor=false".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        let key = URLQueryItem(name: "key", value: Constants.mapsKey)
        let address = URLQueryItem(name: "address", value: location)
        components.queryItems = [key, address]
        
        
        let task = URLSession.shared.dataTask(with: components.url!)
        {
            (data, response, error) -> Void in
            
            print("self.searchResults[indexPath.row] = ",location)
            
            do
            {
                if data != nil
                {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    
                    print("dic = ",dic)
                    
                    let lat =   (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat")) as! Double
                    
                    let lon =   (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng")) as! Double
                    
                    //                    self.moveViewController(lat: lat, log: lon)
                    
                }
                
            }
            catch
            {
                print("Error")
            }
        }
        task.resume()
    }
    
    func moveViewController(lat :Double,log :Double)
    {
        DispatchQueue.main.async
            {
                
        }
    }
    
}
