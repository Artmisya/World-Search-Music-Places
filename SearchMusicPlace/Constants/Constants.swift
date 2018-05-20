//
//  Constants.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    /*according to MusicBrainz webservice documentation the rate limit for a source IP is: 1 request per second.
     for more information please visit: https://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting */
    struct MusicBrainz{
        static let WebServiceRateLimit:Double=1.0
        
        
    }
    
    struct MusicPlace{
        static let lifeSpanFrom:Int=1990
        struct PinColor{
            
            static let threeSecondToDisappear:UIColor = UIColor(red: 255.0/255, green: 127.0/255, blue: 127.0/255, alpha: 1.0)
            static let twoSecondToDisappear:UIColor = UIColor(red: 255.0/255, green: 204.0/255, blue: 204.0/255, alpha: 1.0)
            static let oneSecondToDisappear:UIColor = UIColor(red: 255.0/255, green: 239.0/255, blue: 239.0/255, alpha:1.0)
            
        }
    }
    
    struct SearchManagerConfiguration{
        static let defualtPaginLimit:UInt=20
        
        enum Mode: Int {
            case adaptive=1
            case fixed=2
        }
        
    }
    
    struct ApiUrl{
        static let searchPlaceUrl:String="http://musicbrainz.org/ws/2/place/"
    }
    
    struct ErrorMessage{
        static let badUrl:String="Bad Url"
        static let serverError:String="Server Error"
        static let jsonError:String="Dictionary does not contain places key."
        static let parsePlaceError:String="Problem parsing place Dictionary."
        static let unknownError="Whoops, something went wrong!"
        static let noSearchResult:String="There is no results that match your search."
        
        
    }
    
    struct DomainError{
        static let serverError:String="ServerError"
        static let httpError:String="HttpError"
        static let jsonError:String="jsonError"
    }
}
