# Search Music Places (self-practice) 
# Version 1.0

# Overview
This is a single view app that allow users to insert a search keyword for places used for performing or producing music. The output would be places as pins on a map.
# Requirements:
- Use MusicBrainz API
- Places returned per request should be limited, but all places must be displayed on map. For example there 100 places for search term, but limit is 20, so we need 5 request to get all the places
- Displayed places should be open from 1990
- Every pin has a lifespan,after that time, it will have to be wiped out from the map
-  Lifespan is calculated like this: `open_year - 1990 = lifespan_in_seconds`. Example 2017 - 1990 = 27 seconds
- UI should be responsive during the entire process
- No third party libraries can be use

# Features:
- **Adaptive & Fixed Search Mode** 
According to MusicBrainz webservice documentation there is a rate limit to call a webservice for a source IP : `The rate at which your IP address is making requests is measured. If that rate is too high, all your requests will be declined (http 503) until the rate drops again. Currently that rate is (on average) 1 request per second.For example: if your requests are coming in at 4 requests per second, we don't honour 25% of them and decline the other 75% - we decline 100% of them, until the rate drops to 1 per second or lower.`For more information please visit: https://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting 

    According to this rule, the app needs to make at least 1 second delay between each request to MusicBrainz API .That means if a search query result fall into 300 pages , the app needs at least 300 seconds to call MusicBrainz API to get all 300 peages (1 request per second) which cause a long waiting time for the enduser. In order to overcome this problem two searching modes are implemented in the PagingSearchManager class: 
    - **1-Adaptive** 
    - **2- Fixed** 
         
    In **Adaptive** mode the search manager will call the MusicBrainz webservice without considering any rate limit until it get denied by MusicBrainz server with a 503 service unavailable error. As soon as receiving this error the search manager will try to drops the rate to 1 request per second for the next 3 requests & then back to sending requests without considering any rate limit again.

    In **Fixed** mode however,  the search manager will call the MusicBrainz webservice according to the fixed rate limit suggested by MusicBrainz which is **1 request per second**. In compare to **adaptive** , **Fixed** mode is more simple to implement but will result in a more longer waiting time for end users. By default the search mode in PagingSearchManager class is set to **Adaptive**  however it can be change to **Fixed** mode like: 



            pagingSearchManager.mode=Constants.SearchManagerConfiguration.Mode.fixed

- **pin color changes according to lifespan** 
      Starting from **3 seconds** to be disappear from the map, the pin will start to blink and its color will start to slowly fade away in which the pin's color will change from red to pink, light pink and white until it finally disappear from the map.I have added this  extra  feature to make a more interesting UI for end users.


- **pin's click action** 
     When user click on a place (pin) on the map, the app redirects user to the iOS's map where user can navigate to that place.

- **Cancel Search** 
As soon as a new search get started a cancel button will appear next to the search bar  . In order to cancel the search  user can press this button.

- **Modify Search Query** 
      User can  change the search query while the previous search is still in progress. If user change the search term, the previous search will stop and a new search will start based on the new query inserted by user.

- **Progress Bar**
 The search time can get long for some search queries, for example if we search for "Copenhagen" the result will fall into 182 pages which means we need to make 182 request to get all results.A progress bar is added to the page in order to provide users with some progress information while a search is in progress.
# Limitations

- Some of Json data returned by  MusicBrainz API does not have **lifespan** key or the **coordinates** key.If a Json does not include a lifespan key the app simply ignore that place. Also if a Json does not have a coordinates key the app try to use **Geocoding** and  get the coordinates by using the place's **address**, however if both address and coordinate keys are missing in a json then there will be no way for app to show that place on a map, therefore the app ignore that place.


# Unit Tests
The application includes the following unit tests:
- testNetworkService
- testNetworkServiceWithUnreachableServer
- testNetworkServiceWithNoInternetConnection (In order to perform this test you need to **turn OFF** your internet connection )
- testPagingSearchManagerGetPlaceDisplyTime
- testPagingSearchManagerGetPlaceCoordinates
- testPagingTestManagerAdaptiveMode
- testPagingTestManagerFixedMode
- testPagingTestManagerWithNoResult
- testPagingTestManagerWithError(In order to perform this test you need to **turn OFF** your internet connection )

# Architecture Pattern

 This app is developed based on  [Model View Controller (MVC)](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html) architecture pattern recommended by Apple.

# Language & Frameworks 
This app has been developed by using the following frameworks and language
- Swift4 
-  As it was one of the app's requirements no third-party library is used in this app
 # How to run?
You need to have have **xcode 9.3** or higher. 
