//
//  PlacePinView.swift
//  SearchMusicPlace
//
//  Created by Saeedeh on 15/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import MapKit

class PlacePinView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? MusicPlace else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = artwork.markerTintColor
        }
    }
}
