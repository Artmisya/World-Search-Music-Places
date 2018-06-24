//
//  PaginSearchManager.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import MapKit

class PaginSearchManager{
    
    private var searchQueryInprogress:String=""
    private var pageNumbers:Int=0
    private var currentOffset:Int=0
    public var pageLimit:UInt=Constants.SearchManagerConfiguration.defualtPaginLimit
    private var searchResults=[MusicPlace]()
    
    public var mode=Constants.SearchManagerConfiguration.Mode.adaptive
    private var slowDownRequests:Int=0
    
    weak var delegate: PaginSearchManagerDelegate?
    
    private let networkService=NetworkService()
    
    private typealias JSONDictionary = [String: Any]
    
    
    
    func search(searchQuery:String){
        
        resetSearchParameters(searchQuery:searchQuery)
        
        guard let searchUrl=createSearchUrl() else {
            // inform view controler about the error
            let error=NSError(domain: Constants.DomainError.httpError, code: 0, userInfo: [NSLocalizedDescriptionKey : Constants.ErrorMessage.badUrl])
            
            let reply=PaginSearchManagerReply(data:self.searchResults, error: error, searchQuery: searchQuery)
            self.delegate?.didFinishSearch(reply:reply)
            
            return
        }
        
        // call network service
        if (self.mode==Constants.SearchManagerConfiguration.Mode.adaptive){
            
            self.callNetworkServiceForAdaptiveMode(url: searchUrl)
        }
        else if (self.mode==Constants.SearchManagerConfiguration.Mode.fixed){
            
            self.callNetworkServiceForFixedMode(url: searchUrl)
        }
        
    }
    
    func cancel(){
        
        resetSearchParameters(searchQuery: "")
    }
    
    // MARK:- Private Functions
    
    private func callNetworkService(url:URL){
        
        networkService.request(url: url) { (reply) in
            
            let searchQuery=self.getUrlSearchQuery(url: url)!
            if (self.searchQueryInprogress != searchQuery){
                
                return
            }
            // in case of error
            if let error=reply.error{
                
                print (">> received error",error.localizedDescription)
                let code=(error as NSError).code
                // this is a rate limit error, we need to slow down the request rate for the next 3 requests
                if(code==Constants.ErrorCode.serviceNotAvaliable){
                    
                    self.slowDownRequests=3
                    self.callNetworkServiceForAdaptiveMode(url: url)
                }
                else{
                    
                    // inform view controler that the search is done with an error
                    let reply=PaginSearchManagerReply(data:self.searchResults, error: error, searchQuery: searchQuery)
                    self.delegate?.didFinishSearch(reply:reply)
                }
                
            }
                // in case of receiving data
            else if let data=reply.data {
                
                self.updateSearchResults(data:data)
                
                // inform view controller about the progress
                
                let progress=self.getSearchProgress()
                let reply=PaginSearchManagerProgressReply(progress: progress, searchQuery: searchQuery)
                self.delegate?.didRecieveDataUpdate(reply: reply)
                
                
                // check if there is more pages?
                if (self.hasMorePage(data:data)){
                    
                    self.searchMorePage()
                }
                else{
                    // inform view controller that the search is sussefully done
                    let reply=PaginSearchManagerReply(data:self.searchResults, error: nil, searchQuery: searchQuery)
                    self.delegate?.didFinishSearch(reply:reply)
                }
            }
        }
    }
    private func resetSearchParameters(searchQuery:String){
        
        self.pageNumbers=0
        self.currentOffset=0
        searchQueryInprogress=searchQuery
        searchResults.removeAll()
    }
    
    private func createSearchUrl()->URL?{
        
        var urlComponents = URLComponents(string: Constants.ApiUrl.searchPlaceUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: searchQueryInprogress),
            URLQueryItem(name: "limit", value: String(pageLimit)),
            URLQueryItem(name: "offset", value: String(currentOffset)),
            URLQueryItem(name: "fmt", value: "json")
        ]
        if let seachUrl=urlComponents.url{
            
            return seachUrl
        }
        return nil
    }
    
    private func updateSearchResults(data:Data){
        
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            
            print( parseError.localizedDescription)
            return
        }
        
        // set the page numbers if it is not set yet
        if (pageNumbers==0){
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
                if let count = response!["count"] as? Int {
                    self.pageNumbers=count
                    
                }
            }catch let parseError {
                
                print (parseError.localizedDescription)
                
            }
        }
        
        guard let placeList = response!["places"] as? [Any] else {
            
            print( Constants.ErrorMessage.jsonError)
            return
            
        }
        // processing data....
        
        for placeDictionary in placeList {
            
            if let placeDictionary = placeDictionary as? [String:Any]{
                
                self.getPlaceCoordinates(placeDictionary:placeDictionary){ coordinates in
                    
                    //some of places are repeated in the different pages, check if this place has been added before no need to add it again
                    guard let id=self.checkForNullKey(param:placeDictionary["id"] as Any) as? String,
                        (self.searchResults.filter{$0.id==id}.count==0)else{
                            
                            return
                    }
                    let displyTime=self.getPlaceDisplyTime(placeDictionary:placeDictionary)
                    let name=self.checkForNullKey(param:placeDictionary["name"] as Any) as? String
                    
                    if let newPlace=MusicPlace(id: id, locationName: name, coordinates: coordinates, displyTime: displyTime){
                        
                        // update search results
                        self.searchResults.append(newPlace)
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    private func getSearchProgress()-> Float{

        if(pageNumbers==0){
            
            return 0
        }
        let progress=Float(currentOffset+1) / Float(pageNumbers)
        print (">>progress",progress,pageNumbers)
        return progress
        
    }
    private func searchMorePage(){
        
        currentOffset+=1
        
        guard let searchUrl=createSearchUrl() else {
            
            // inform view controler that the search is done with an error
            let error=NSError(domain: Constants.DomainError.httpError, code: 0, userInfo: [NSLocalizedDescriptionKey : Constants.ErrorMessage.badUrl])
            let reply=PaginSearchManagerReply(data:searchResults, error: error, searchQuery: searchQueryInprogress)
            self.delegate?.didFinishSearch(reply:reply)
            return
        }
        
        if (self.mode==Constants.SearchManagerConfiguration.Mode.adaptive){
            
            self.callNetworkServiceForAdaptiveMode(url: searchUrl)
        }
        else if (self.mode==Constants.SearchManagerConfiguration.Mode.fixed){
            
            self.callNetworkServiceForFixedMode(url: searchUrl)
        }
        
    }
    
    private func hasMorePage(data:Data)->Bool{
        
        if (pageNumbers-currentOffset>1){
            
            return true
        }
        return false
    }
    
    /***In this mode the search manager will call the MusicBrainz webservice without considering any rate limit
     until it get denied by MusicBrainz server with a 503 service unavailable error.
     As soon as receiving this error the search manager will try to drop the rate to 1 request per second for the next 3 requests
     & then back to sending requests without considering any rate limit again.***/
    
    private func callNetworkServiceForAdaptiveMode(url: URL){
        
        if (slowDownRequests>0){
            
            // we have received a 503 Service unavailable error by MusicBrainz server,
            // we need to drop the calling rate on MusicBrainz server
            DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + Constants.MusicBrainz.WebServiceRateLimit){
                
                self.callNetworkService(url: url)
                self.slowDownRequests -= 1
            }
        }
        else{
            
            // call MusicBrainz server without considering any rate limit
            self.callNetworkService(url: url)
        }
    }
    
    
    /***In this mode the search manager will call the MusicBrainz webservice according to a fixed rate limit suggested by MusicBrainz which is 1 request per second for a source IP.***/
    
    private func callNetworkServiceForFixedMode(url: URL){
        
        DispatchQueue.global(qos:.userInitiated).asyncAfter(deadline: .now() + Constants.MusicBrainz.WebServiceRateLimit) {
            
            self.callNetworkService(url: url)
        }
    }
    
    private func getUrlSearchQuery(url:URL)->String?{
        
        guard let url = URLComponents(string: url.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == "query" })?.value
    }
    
    private  func getPlaceCoordinates(placeDictionary: [String:Any],complationHandler:@escaping(CLLocationCoordinate2D?)->Void){
        
        if  let coordinatesDictionary = checkForNullKey(param:placeDictionary["coordinates"] as Any) as? [String:String],
            let latitude=self.checkForNullKey(param:coordinatesDictionary["latitude"] as Any) as? String,
            let longitude=self.checkForNullKey(param:coordinatesDictionary["longitude"] as Any) as? String{
            
            let latitudeDegrees : CLLocationDegrees = Double(latitude)!
            let longitudeDegrees : CLLocationDegrees = Double(longitude)!
            let coordinates = CLLocationCoordinate2D(latitude:latitudeDegrees, longitude:longitudeDegrees)
            complationHandler(coordinates)
        }
        else{
            
            // if the coordinates key does not exsit in the json try to get the coordinates from address field
            if let address=checkForNullKey(param:placeDictionary["address"] as Any) as? String{
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    
                    if let placemarks = placemarks,let location = placemarks.first?.location  {
                        
                        //location found
                        let coordinates=location.coordinate
                        complationHandler(coordinates)
                        
                    }
                    else{
                        
                        // handle no location found
                        complationHandler(nil)
                    }
                    
                }
            }
            else{
                
                complationHandler(nil)
            }
        }
        
    }
    
    private  func getPlaceDisplyTime(placeDictionary: [String:Any])->UInt{
        
        var displyTime:UInt=0
        if  let lifeSpanDictionary =  checkForNullKey(param:placeDictionary["life-span"] as Any) as? [String:String?],
            let begin=self.checkForNullKey(param:lifeSpanDictionary["begin"] as Any) as? String{
            
            let timeParts = begin.split(separator: "-")
            if(timeParts.count>0){
                
                if let beginInt=Int(timeParts[0]) , beginInt-Constants.MusicPlace.lifeSpanFrom>0{
                    
                    displyTime=UInt(beginInt-Constants.MusicPlace.lifeSpanFrom)
                }
            }
            else{
                
                if let beginInt=Int(begin),beginInt-Constants.MusicPlace.lifeSpanFrom>0{
                    
                    displyTime=UInt(beginInt-Constants.MusicPlace.lifeSpanFrom)
                }
            }
        }
        
        return displyTime
        
    }
    /*This method check for null keys,in case a dictionry does not contain a certain key
     this method returns nil for value of that key,
     if the key exsit then it returns the actual value of that key */
    private  func checkForNullKey(param:Any)->Any?{
        
        if case Optional<Any>.some(let val) = param{
            return (val)
        }
        
        return nil
    }
}


// MARK:- Expose Private Functions for unit test
#if DEBUG
extension PaginSearchManager {
    public func exposePrivateGetPlaceDisplyTime(placeDictionary: [String:Any]) -> UInt {
        return self.getPlaceDisplyTime(placeDictionary: placeDictionary)
    }
    
    public func exposePrivateGetPlaceCoordinates(placeDictionary: [String:Any],complationHandler:@escaping(CLLocationCoordinate2D?)->Void) {
        return self.getPlaceCoordinates(placeDictionary: placeDictionary,complationHandler:complationHandler)
    }
    
    
}
#endif
