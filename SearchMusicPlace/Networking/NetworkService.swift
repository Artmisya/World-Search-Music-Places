//
//  NetworkService.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

class NetworkService{
    
    typealias networkServiceComplationHandler = (NetworkServiceReply) -> Void
    
    private var session: URLSession = URLSession()
    
    init(){
        
        let sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
    func request(url:URL,complationHandler: @escaping networkServiceComplationHandler){
        
        print ("->>request:",url.absoluteString)
        
        let dataTask=self.session.dataTask(with:url){ data, response, error in
            
            guard error == nil else{
                
                // inform  view controller about the error
                let reply=NetworkServiceReply(data:nil, error: error, url: url)
                complationHandler(reply)
                return
                
            }
            //check response
            guard let httpResponse = response as? HTTPURLResponse else {
                
                let error = NSError(domain: Constants.DomainError.serverError, code: 0, userInfo: [NSLocalizedDescriptionKey : Constants.ErrorMessage.serverError])
                
                // inform  view controller about the error
                let reply=NetworkServiceReply(data:nil, error: error, url: url)
                complationHandler(reply)
                
                return
            }
            //check response's status code
            guard (200...299).contains(httpResponse.statusCode) else{
                
                let error = NSError(domain: Constants.DomainError.httpError, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])
               
                // inform  view controller about the error
                let reply=NetworkServiceReply(data:nil, error: error, url: url)
                complationHandler(reply)
                return
                
            }
            if let data = data {
                
                let reply=NetworkServiceReply(data:data, error: nil, url: url)
                complationHandler(reply)
                
            }
            
        }
        dataTask.resume()
    }
    
}
