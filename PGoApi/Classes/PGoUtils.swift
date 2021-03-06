//
//  PGoUtils.swift
//  pgoapi
//
//  Created by PokemonGoSucks on 2016-08-03.
//
//

import Foundation
import CoreLocation


public class PGoLocationUtils {
    public enum unit {
        case Kilometers, Miles, Meters, Feet
    }
    
    public enum bearingUnits {
        case Degree, Radian
    }
    
    public init () {}
    
    public struct PGoCoordinate {
        public var latitude: Double?
        public var longitude: Double?
        public var altitude: Double?
        public var distance: Double?
        public var displacement: Double?
    }
    
    public func reverseGeocode(location: String, completionHandler: (PGoLocationUtils.PGoCoordinate?) -> ()) {
        /*
         
         Example func for completionHandler: func receivedGeocode(results:PGoLocationUtils.Coordinates?)
         
        */
        
        var result: PGoCoordinate?
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placeData: [CLPlacemark]?, error: NSError?) -> Void in
            if (placeData?.count > 0) {
                result = PGoCoordinate(latitude: (placeData![0].location?.coordinate.latitude)!, longitude: (placeData![0].location?.coordinate.longitude)!, altitude: placeData![0].location?.altitude, distance: 0, displacement: 0)
                completionHandler(result)
            }
        })
    }
    
    public func getDistanceBetweenPoints(startLatitude:Double, startLongitude:Double, endLatitude:Double, endLongitude: Double, unit: PGoLocationUtils.unit? = .Meters) -> Double {
        
        let start = CLLocation.init(latitude: startLatitude, longitude: startLongitude)
        let end = CLLocation.init(latitude: endLatitude, longitude: endLongitude)
        var distance = start.distanceFromLocation(end)
        
        if unit == .Miles {
            distance = distance/1609.344
        } else if unit == .Kilometers {
            distance = distance/1000
        } else if unit == .Feet {
            distance = distance * 3.28084
        }
        return distance
    }
    
    public func moveDistanceToPoint(startLatitude:Double, startLongitude:Double, endLatitude:Double, endLongitude: Double, distance: Double, unitOfDistance: PGoLocationUtils.unit? = .Meters) -> PGoLocationUtils.PGoCoordinate {
        let maxDistance = getDistanceBetweenPoints(startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude)
        
        var distanceConverted = distance
        if unitOfDistance == .Miles {
            distanceConverted = distance * 1609.344
        } else if unitOfDistance == .Kilometers {
            distanceConverted = distance * 1000
        } else if unitOfDistance == .Feet {
            distanceConverted = distance / 3.28084
        }
        
        var distanceMove = distanceConverted/maxDistance
        
        if distanceMove > 1 {
            distanceMove = 1
        }
        
        return PGoCoordinate(latitude: startLatitude + ((endLatitude - startLatitude) * distanceMove), longitude: startLongitude + ((endLongitude - startLongitude) * distanceMove), altitude: 0, distance: maxDistance, displacement: distanceMove * maxDistance)
    }
    
    public func moveDistanceWithBearing(startLatitude:Double, startLongitude:Double, bearing: Double, distance: Double, bearingUnits: PGoLocationUtils.bearingUnits? = .Radian, unitOfDistance: PGoLocationUtils.unit? = .Meters) -> PGoLocationUtils.PGoCoordinate {
        
        var distanceConverted = distance
        if unitOfDistance == .Miles {
            distanceConverted = distance * 1609.344
        } else if unitOfDistance == .Kilometers {
            distanceConverted = distance * 1000
        } else if unitOfDistance == .Feet {
            distanceConverted = distance / 3.28084
        }
        
        var bearingConverted = bearing
        if bearingUnits == .Degree {
            bearingConverted = bearing * M_PI / 180.0
        }
        
        let distanceRadian = distanceConverted / (6372797.6)
        
        let lat = startLatitude * M_PI / 180
        let long = startLongitude * M_PI / 180
        
        let latitude = (asin(sin(lat) * cos(distanceRadian) + cos(lat) * sin(distanceRadian) * cos(bearingConverted))) * 180 / M_PI
        let longitude = (long + atan2(sin(bearingConverted) * sin(distanceRadian) * cos(lat), cos(distanceRadian) - sin(lat) * sin(latitude))) * 180 / M_PI
        
        return PGoCoordinate(latitude: latitude, longitude: longitude, altitude: 0, distance: 0, displacement: 0)
    }
}
