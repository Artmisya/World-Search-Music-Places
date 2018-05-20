//
//  MusicPlace.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class MusicPlace: NSObject, MKAnnotation {
    
    let id:String
    let locationName: String?
    var coordinate: CLLocationCoordinate2D
    private var displyTime:UInt
    
    var subtitle: String? {
        return locationName
    }
    var title: String? {
        return locationName
    }
    var markerTintColor: UIColor  {
        switch displyTime {
            
            case 3:
                return Constants.MusicPlace.PinColor.threeSecondToDisappear
            case 2:
                return Constants.MusicPlace.PinColor.twoSecondToDisappear
            case 1:
                return Constants.MusicPlace.PinColor.oneSecondToDisappear
            default:
                return .red
        }
    }
    
    init?(id:String,locationName: String?, coordinates: CLLocationCoordinate2D?,displyTime:UInt){
        
        if (coordinates != nil && displyTime>0 ){
            
            self.locationName = locationName
            self.coordinate = coordinates!
            self.displyTime = displyTime
            self.id = id
            
            super.init()
            
        }
        else{
            return nil
        }
        
    }
    
    func isDisplayTimeOver()->Bool{
        
        if displyTime==0{
            
            return true
        }
        return false
    }
    
    func isTimeToBlink()->Bool{
        
        if displyTime<4{
            
            return true
        }
        return false
    }
    
    func deductDisplyTime(){
        
         displyTime -= 1
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
}
