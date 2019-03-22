//  Copyright © 2017 cis195. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let isValid : Bool
    
    init(title: String, coordinate: CLLocationCoordinate2D, isValid: Bool, subtitle: String?) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.isValid = isValid
        super.init()
    }
}
