//
//  MusicPlace.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import MapKit

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
            
        case 5:
            return Constants.MusicPlace.PinColor.fiveSecondToDisappear
        case 4:
            return Constants.MusicPlace.PinColor.fourSecondToDisappear
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
        
        if displyTime<6{
            
            return true
        }
        return false
    }
    
    func deductDisplyTime(){
        
         displyTime -= 1
    }
    
}
