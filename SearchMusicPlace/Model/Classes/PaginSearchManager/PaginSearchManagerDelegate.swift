//
//  PaginSearchManagerDelegate.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
protocol PaginSearchManagerDelegate: class {
    
    /**The didRecieveDataUpdate delegate can be use in case we want to provide user with some progress information while a search is in progress. however I didnot call this delegate in PaginSearchManager class at all **/
    func didRecieveDataUpdate(reply:PaginSearchManagerProgressReply)
    func didFinishSearch(reply:PaginSearchManagerReply)
}
