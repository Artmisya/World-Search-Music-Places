//
//  SearchMusicPlaceViewController.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 15/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import UIKit
import MapKit

class SearchMusicPlaceViewController: UIViewController {
    
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 5000
    
    @IBOutlet var searchBar: UISearchBar!
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    
    private let lifeSpanTimer = RepeatingTimer(timeInterval: 1)
    
    var searchResult=[MusicPlace]()
    let pagingSearchManager=PaginSearchManager()
    var searchQueryInprogress:String=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUi()
        setUPViewControllerDelegates()
        configureSearchManager()
        
    }
    private func setUpUi(){
        
        self.title="Search Music Places"
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        loading.isHidden=true
        loading.hidesWhenStopped=true
        
        
    }
    private func setUPViewControllerDelegates(){
        
        pagingSearchManager.delegate = self
        searchBar.delegate=self
        mapView.register(PlacePinView.self,forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
    }
    
    private func configureSearchManager(){
        
        pagingSearchManager.pageLimit=20
        // set the Mode
        pagingSearchManager.mode=Constants.SearchManagerConfiguration.Mode.adaptive
    }
    
    /**This function call a repeating GCD timer that runs on a background thread to update the pin's display time every one second
     and then update the map  according to pin's display time in the main thread */
    private func updatePinsLifespan(){
        
        lifeSpanTimer.eventHandler = {
            // get all pins that their display time is NOT over yet
            var alivePins=self.searchResult.filter{$0.isDisplayTimeOver()==false}
            if alivePins.count==0{
                
                self.lifeSpanTimer.suspend()
            }
            // update display time for each pin
            for  place in alivePins {
                
                place.deductDisplyTime()
            }
            // update alivePins array
            let timeOverPins=alivePins.filter{$0.isDisplayTimeOver()==true}
            alivePins=alivePins.filter{$0.isDisplayTimeOver()==false}
            let fiveSecondtoVanishPins=alivePins.filter{$0.isTimeToBlink()==true}
            
            // update searchResult array and map view in the main thread
            DispatchQueue.main.async {
                
                //remove pins that their display time is over
                self.mapView.removeAnnotations(timeOverPins)
                 // remove and add back again the fiveSecondtoVanishPins in order to make their pin color update
                self.mapView.removeAnnotations(fiveSecondtoVanishPins)
                self.mapView.addAnnotations(fiveSecondtoVanishPins)
                
                // update search result array with alive pins
                self.searchResult=alivePins
                
            }
            
        }
        
        lifeSpanTimer.resume()
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    private func cancelSearch(){
        
        mapView.removeAnnotations(searchResult)
        searchResult.removeAll()
        
        pagingSearchManager.cancel()
        
        self.searchBar.showsCancelButton=false
        self.searchBar.text=""
        
        self.loading.stopAnimating()
        
    }
    
}

// MARK:- PaginSearchManagerDelegate
extension SearchMusicPlaceViewController:PaginSearchManagerDelegate{
    
    /**This delegate can be use in case we want to provide user with some progress information while a search is in progress. however I didnot call this delegate in PaginSearchManager class at all **/
    
    func didRecieveDataUpdate(reply:PaginSearchManagerReply){
        
        
    }
    
    func didFinishSearch(reply:PaginSearchManagerReply) {
        
        if (reply.searchQuery != searchQueryInprogress){
            
            return
        }
        if let error=reply.error {
            
            print ("->>did finish search with error:",error.localizedDescription)
            
            DispatchQueue.main.async {
                
                self.searchResult.removeAll()
                self.searchBar.showsCancelButton=false
                self.loading.stopAnimating()
                
                let message=error.localizedDescription
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            
            print("->> did finish search with data size:",reply.data.count)
            
            // update ui in the main thread
            DispatchQueue.main.async {
                
                self.searchBar.showsCancelButton=false
                self.loading.stopAnimating()
                
                if (reply.data.count==0){
                    
                    let message=Constants.ErrorMessage.noSearchResult
                    
                    let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else{
                    
                    self.searchResult += reply.data
                    let location=self.searchResult[0].coordinate
                    self.centerMapOnLocation(location:location)
                    self.mapView.addAnnotations(self.searchResult)
                    // start timer
                    self.updatePinsLifespan()
                }
            }
        }
    }
}

// MARK:- UISearchBarDelegate
extension SearchMusicPlaceViewController: UISearchBarDelegate {
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        dismissKeyboard()
        self.cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        dismissKeyboard()
        if var searchQuery=searchBar.text , searchQuery != ""{
            
            // stop timer
            lifeSpanTimer.suspend()
            
            searchBar.showsCancelButton=true
            if let cancelButton : UIButton = searchBar.value(forKey: "_cancelButton") as? UIButton{
                cancelButton.isEnabled = true
                cancelButton.tintColor=UIColor.white
            }
            
            self.loading.startAnimating()

            //remove all pins from map view
            mapView.removeAnnotations(searchResult)
            searchResult.removeAll()
            
            searchQuery="\""+searchQuery+"\""
            self.searchQueryInprogress=searchQuery
            
            // call search manager for a new search
            DispatchQueue.global(qos:.userInitiated).async {
                self.pagingSearchManager.search(searchQuery: searchQuery)
            }
        }
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        
        return .top
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

