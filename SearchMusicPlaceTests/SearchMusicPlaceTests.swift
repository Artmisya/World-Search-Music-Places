//
//  SearchMusicPlaceTests.swift
//  SearchMusicPlaceTests
//
//  Created by Saeedeh on 14/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import XCTest
import MapKit

@testable import SearchMusicPlace

class SearchMusicPlaceTests: XCTestCase {
    
    
    var networkServiceUnderTest:NetworkService!
    
    var paginSearchManagerUnderTest:PaginSearchManager!
    var eFinishSearchDelegate : XCTestExpectation!
    var searchExpectedResult:PaginSearchManagerReply!
    
    let urlStringUnderTest="http://musicbrainz.org/ws/2/place/?query=C&limit=20&offset=0&fmt=json"
    let unreachableUrlStringUnderTest="http://doesnotexsitserver.org/ws/2/place/?query=C&limit=20&offset=0&fmt=json"
    let notChachedUrlStrinUnderTest="http://musicbrainz.org/ws/2/place/?query=notCached&limit=20&offset=0&fmt=json"
    
    override func setUp() {
        super.setUp()
        
        networkServiceUnderTest=NetworkService()
        
        paginSearchManagerUnderTest=PaginSearchManager()
        paginSearchManagerUnderTest.delegate=self
        
    }
    
    override func tearDown() {
    
        networkServiceUnderTest=nil
        paginSearchManagerUnderTest=nil
        super.tearDown()
    }
    func testNetworkService(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:urlStringUnderTest)!
        
        networkServiceUnderTest.request(url: url) { (reply) in
            
            XCTAssertNil(reply.error, "Expected nil but received \(String(describing: reply.error))")
            XCTAssertNotNil(reply.data, "Expected data but received nil")
            XCTAssertTrue(reply.url.absoluteString==url.absoluteString, "Expected equal but received reply.url:\(reply.url.absoluteString), request url:\(url.absoluteString)")
            e.fulfill()
            
        }
        waitForExpectations(timeout: 15.0, handler: nil)
        
    }
    
    func testNetworkServiceWithUnreachableServer(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:unreachableUrlStringUnderTest)!
        
        networkServiceUnderTest.request(url: url) { (reply) in
            
            XCTAssertNotNil(reply.error, "Expected error but received nil")
            XCTAssertNil(reply.data, "Expected nil but received \(String(describing: reply.data))")
            XCTAssertTrue(reply.url.absoluteString==url.absoluteString, "Expected equal but received reply.url:\(reply.url.absoluteString), request url:\(url.absoluteString)")
            e.fulfill()
            
        }
        waitForExpectations(timeout: 15.0, handler: nil)
        
    }
    
    /**turn OFF your internet connection to perform this test**/
    func testNetworkServiceWithNoInternetConnection(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:notChachedUrlStrinUnderTest)!
        
        networkServiceUnderTest.request(url: url) { (reply) in
            
            XCTAssertNotNil(reply.error, "Expected error but received nil")
            XCTAssertNil(reply.data, "Expected nil but received \(String(describing: reply.data))")
            XCTAssertTrue(reply.url.absoluteString==url.absoluteString, "Expected equal but received reply.url:\(reply.url.absoluteString), request url:\(url.absoluteString)")
            e.fulfill()
            
        }
        waitForExpectations(timeout: 30.0, handler: nil)
        
    }
    
    func testPagingSearchManagerGetPlaceCoordinates(){
        
        let e = expectation(description: "complition handler invoked")
        
        //test for when coordinates key exist in the input
        let inputString="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"life-span\": {\"begin\" : \"1994\",\"ended\" : \"<null>\"}, \"address\": \"August Bournonvilles Passage 8, 1055, Copenhagen\", \"coordinates\": {\"latitude\" : \"55.679367\",\"longitude\" : \"12.58635\"}, \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString){
            
            paginSearchManagerUnderTest.exposePrivateGetPlaceCoordinates(placeDictionary:inputArray){ coordinates in
                
                e.fulfill()
                XCTAssertNotNil(coordinates,"Expected coordinates object but received nil")
                XCTAssertTrue(coordinates?.latitude==55.679367, "Expected 55.679367  but received \(String(describing: coordinates?.latitude))")
                XCTAssertTrue(coordinates?.longitude==12.58635, "Expected 12.58635 but received \(String(describing: coordinates?.longitude))")
                
            }
            
        }
        else{
            
            e.fulfill()
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
        
        //test for when coordinates key does not exist in the input but address key exsit
        let e2 = expectation(description: "complition handler invoked")
        
        let inputString2="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"life-span\": {\"begin\" : \"1994\",\"ended\" : \"<null>\"}, \"address\": \"August Bournonvilles Passage 8, 1055, Copenhagen\", \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString2){
            
            paginSearchManagerUnderTest.exposePrivateGetPlaceCoordinates(placeDictionary:inputArray){ coordinates in
                
                e2.fulfill()
                XCTAssertNotNil(coordinates,"Expected coordinates object but received nil")
                
            }
            
        }
        else{
            
            e2.fulfill()
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
        
        //test for when both coordinates and address keys does not exist in the input
        let e3 = expectation(description: "complition handler invoked")
        
        let inputString3="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"life-span\": {\"begin\" : \"1994\",\"ended\" : \"<null>\"}, \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString3){
            
            paginSearchManagerUnderTest.exposePrivateGetPlaceCoordinates(placeDictionary:inputArray){ coordinates in
                
                e3.fulfill()
                XCTAssertNil(coordinates,"Expected nil but received coordinates object")
                
            }
            
        }
        else{
            
            e3.fulfill()
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    
    func testPagingSearchManagerGetPlaceDisplyTime(){
        
        //test for when life-span->begin keys exist in the input and it is after 1990 (format is yyyy)
        let inputString="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"life-span\": {\"begin\" : \"1994\",\"ended\" : \"<null>\"}, \"address\": \"August Bournonvilles Passage 8, 1055, Copenhagen\", \"coordinates\": {\"latitude\" : \"55.679367\",\"longitude\" : \"12.58635\"}, \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString){
            
            let displyTime=paginSearchManagerUnderTest.exposePrivateGetPlaceDisplyTime(placeDictionary: inputArray)
            XCTAssertTrue(displyTime==4, "Expected displyTime==4  but received \(String(describing: displyTime))")
            
        }
        else{
            
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
        //test for when life-span->begin keys exist in the input and it is after 1990 (format is yyyy-mm-dd)
        let inputString2="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"life-span\": {\"begin\" : \"1994-07-07\",\"ended\" : \"<null>\"}, \"address\": \"August Bournonvilles Passage 8, 1055, Copenhagen\", \"coordinates\": {\"latitude\" : \"55.679367\",\"longitude\" : \"12.58635\"}, \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString2){
            
            let displyTime=paginSearchManagerUnderTest.exposePrivateGetPlaceDisplyTime(placeDictionary: inputArray)
            XCTAssertTrue(displyTime==4, "Expected displyTime==4  but received \(String(describing: displyTime))")
            
        }
        else{
            
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
        //test for when life-span->begin keys exist in the input but it is before 1990 (format is yyyy)
        let inputString3="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"life-span\": {\"begin\" : \"1984\",\"ended\" : \"<null>\"}, \"address\": \"August Bournonvilles Passage 8, 1055, Copenhagen\", \"coordinates\": {\"latitude\" : \"55.679367\",\"longitude\" : \"12.58635\"}, \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString3){
            
            let displyTime=paginSearchManagerUnderTest.exposePrivateGetPlaceDisplyTime(placeDictionary: inputArray)
            XCTAssertTrue(displyTime==0, "Expected displyTime==0  but received \(String(describing: displyTime))")
            
        }
        else{
            
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
        
        //test for when life-span->begin keys does not exist in the input
        let inputString4="{\"name\": \"Det Kongelige Teater\", \"score\": \"64\", \"id\": \"d3503e87-17e2-48ab-a90b-ff9280662ffb\", \"address\": \"August Bournonvilles Passage 8, 1055, Copenhagen\", \"coordinates\": {\"latitude\" : \"55.679367\",\"longitude\" : \"12.58635\"}, \"type\": \"Venue\", \"area\": {\"id\" : \"e0e3c82a-aea8-48d3-beda-9e587db0b969\",\"name\" : \"Copenhagen\",\"sort-name\" : \"Copenhagen\"}}"
        
        if let inputArray=fromJSON(string: inputString4){
            
            let displyTime=paginSearchManagerUnderTest.exposePrivateGetPlaceDisplyTime(placeDictionary: inputArray)
            XCTAssertTrue(displyTime==0, "Expected displyTime==0  but received \(String(describing: displyTime))")
            
        }
        else{
            
            XCTAssert(false,"wrong json format \(inputString)")
        }
        
    }
    
    func testPagingTestManagerAdaptiveMode(){
        
        let query="\"Copenhagen\""
        // for query of "copenhagen" we expected to receive totall number of 18 results
        let expectedResultNumbers=18
        
        // fill the expected data array with 18 sample places,
        let sampleCoordinates=CLLocationCoordinate2D(latitude:55.679, longitude:12.575)
        let sampleMusicPlace=MusicPlace(id: "testId", locationName: "testing", coordinates: sampleCoordinates, displyTime: 10)
        let expectedData=[MusicPlace](repeating: sampleMusicPlace!, count:expectedResultNumbers)
        
        //fill the the searchExpectedResult with expected data and error
        searchExpectedResult=PaginSearchManagerReply(data: expectedData, error: nil, searchQuery: query)
        
        // call search :
        eFinishSearchDelegate = expectation(description: "FinishSearchDelegate  handler invoked")
        // set mode to adaptive
        paginSearchManagerUnderTest.mode=Constants.SearchManagerConfiguration.Mode.adaptive
        paginSearchManagerUnderTest.search(searchQuery:query)
        waitForExpectations(timeout: 500.0, handler: nil)
    }
    func testPagingTestManagerFixedMode(){
        
        let query="\"Copenhagen\""
        // for query of "copenhagen" we expected to receive totall number of 18 results
        let expectedResultNumbers=18
        
        // fill the expected data array with 18 sample places,
        let sampleCoordinates=CLLocationCoordinate2D(latitude:55.679, longitude:12.575)
        let sampleMusicPlace=MusicPlace(id: "testId", locationName: "testing", coordinates: sampleCoordinates, displyTime: 10)
        let expectedData=[MusicPlace](repeating: sampleMusicPlace!, count:expectedResultNumbers)
        
        //fill the the searchExpectedResult with expected data and error
        searchExpectedResult=PaginSearchManagerReply(data: expectedData, error: nil, searchQuery: query)
        
        // call search :
        eFinishSearchDelegate = expectation(description: "FinishSearchDelegate  handler invoked")
        // set mode to fixed
        paginSearchManagerUnderTest.mode=Constants.SearchManagerConfiguration.Mode.fixed
        paginSearchManagerUnderTest.search(searchQuery:query)
        waitForExpectations(timeout: 500.0, handler: nil)
    }
    func testPagingTestManagerWithNoResult(){
        
        let query="\"nosuchthing\""
        // for query of "nosuchthing" we expected to receive 0 results
        
        // fill the expected data array an empty array
        let expectedData=[MusicPlace]()
        //fill the the searchExpectedResult with expected data and error
        searchExpectedResult=PaginSearchManagerReply(data: expectedData, error: nil, searchQuery: query)
        
        // call search :
        eFinishSearchDelegate = expectation(description: "FinishSearchDelegate  handler invoked")
        paginSearchManagerUnderTest.search(searchQuery:query)
        waitForExpectations(timeout: 30.0, handler: nil)
    }
    
    /**turn OFF your internet connection to perform this test**/
    func testPagingTestManagerWithError(){
        
        let query="\"Copenhagen\""
        
        // for query of "Copenhagen" we expected to receive 0 results when internet connection is OFF
        // fill the expected results array an empty array
        let expectedData=[MusicPlace]()
        
        // we expect to get a "notConnectedToInternet" error
        let expectedError = NSError(domain: NSURLErrorDomain, code: URLError.Code.notConnectedToInternet.rawValue, userInfo: [NSLocalizedDescriptionKey :"The Internet connection appears to be offline."])
        
        //fill the the searchExpectedResult with expected data and error
        searchExpectedResult=PaginSearchManagerReply(data: expectedData, error: expectedError, searchQuery: query)
        
        // call search :
        eFinishSearchDelegate = expectation(description: "FinishSearchDelegate  handler invoked")
        paginSearchManagerUnderTest.search(searchQuery:query)
        waitForExpectations(timeout: 30.0, handler: nil)
    }
    
    private  func fromJSON(string: String) -> [String: Any]? {
        let data = string.data(using: .utf8)!
        
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            return jsonObject
            
        }
        catch {
            
            return nil
        }
    }
}

extension SearchMusicPlaceTests:PaginSearchManagerDelegate{
    
    func didFinishSearch(reply: PaginSearchManagerReply) {
        
        XCTAssertTrue(searchExpectedResult.searchQuery==reply.searchQuery, "Expected equal but received searchExpectedResult.searchQuery:\(searchExpectedResult.searchQuery), actuall reply.searchQuery:\(reply.searchQuery)")
        
        XCTAssertTrue(searchExpectedResult.data.count==reply.data.count, "Expected equal but received searchExpectedResult.data.count:\(searchExpectedResult.data.count), actuall reply.data.count:\(reply.data.count)")
        
        if let _=searchExpectedResult.error{
            
            XCTAssertNotNil(reply.error,"Expected error: \(String(describing: searchExpectedResult.error)) but received nil")
            
            XCTAssertTrue(searchExpectedResult.error?.localizedDescription==reply.error?.localizedDescription, "Expected equal but received searchExpectedResult.error:\(String(describing: searchExpectedResult.error)), actuall reply.error:\(String(describing: reply.error))")
        }
        else{
            
            XCTAssertNil(reply.error,"Expected nil but received error: \(String(describing: searchExpectedResult.error))")
            
        }
        
        eFinishSearchDelegate.fulfill()
        
    }
    
    func didRecieveDataUpdate(reply: PaginSearchManagerReply) {
        
    }
    
}
