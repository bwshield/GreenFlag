//
//  VenueMapViewController.swift
//  GreenFlag
//
//  Created by B Shield on 1/23/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import MapKit


class VenueMapViewController: UIViewController {
    
    private var region : MKCoordinateRegion?
    private var center : CLLocationCoordinate2D?
    private var venueName : String?
    private let coreDataBastard = CoreDataBastard.sharedBastard
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentationControl: UISegmentedControl!
    @IBOutlet weak var mapTrafficSwitch: UISwitch!
    
    func setMapInfo(center: CLLocationCoordinate2D?, region: MKCoordinateRegion?, name: String?) {
        self.center = center
        self.region = region
        self.venueName = name
        setMap()
    }
    private func setMap() {
        if mapView != nil {
            if center != nil {
                mapView.setCenter(center!, animated: true)
                if region != nil {
                    mapView.setRegion(region!, animated: true)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let mapTypeAttribute = coreDataBastard.getUserAttribute(attribute: "maptype")
        if mapTypeAttribute != nil {
            switch mapTypeAttribute?.value {
            case "standard":
                mapTypeSegmentationControl.selectedSegmentIndex = 0
                mapView.mapType = MKMapType.standard
            case "satellite":
                mapTypeSegmentationControl.selectedSegmentIndex = 1
                mapView.mapType = MKMapType.satellite
            default:
                mapTypeSegmentationControl.selectedSegmentIndex = 2
                mapView.mapType = MKMapType.hybrid
            }
        } else {
            mapTypeSegmentationControl.selectedSegmentIndex = 2
            mapView.mapType = MKMapType.hybrid
            coreDataBastard.setUserAttribute(attribute: "maptype", value: "hybrid")
        }
        let mapTrafficAttribute = coreDataBastard.getUserAttribute(attribute: "maptraffic")
        if mapTypeAttribute != nil {
            switch mapTrafficAttribute?.value {
            case "1":
                mapTrafficSwitch.setOn(true, animated: true)
                mapView.showsTraffic = true
            default:
                mapTrafficSwitch.setOn(false, animated: true)
                mapView.showsTraffic = false
            }
        } else {
            mapTrafficSwitch.setOn(true, animated: true)
            mapView.showsTraffic = true
            coreDataBastard.setUserAttribute(attribute: "maptraffic", value: "1")
        }
        mapView.showsPointsOfInterest = true
        mapView.showsCompass = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setMap()
    }

    @IBAction func mapTypeChanged(_ sender: Any) {
        var mapTypeValue = ""
        switch mapTypeSegmentationControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = MKMapType.standard
            mapTypeValue = "standard"
        case 1:
            mapView.mapType = MKMapType.satellite
            mapTypeValue = "satellite"
        default:
            mapView.mapType = MKMapType.hybrid
            mapTypeValue = "hybrid"
        }
        coreDataBastard.setUserAttribute(attribute: "maptype", value: mapTypeValue)
    }
    
    @IBAction func mapTrafficSwitchChanged(_ sender: Any) {
        var mapTrafficValue = ""
        switch mapTrafficSwitch.isOn {
        case true:
            mapView.showsTraffic = true
            mapTrafficValue = "1"
        default:
            mapView.showsTraffic = false
            mapTrafficValue = "0"
        }
        coreDataBastard.setUserAttribute(attribute: "maptraffic", value: mapTrafficValue)
    }
    
    @IBAction func openInMapsButtonPushed(_ sender: Any) {
        let placemark = MKPlacemark(coordinate: center!)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: center!),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region!.span),
            MKLaunchOptionsMapTypeKey:  mapView.mapType.rawValue,
            MKLaunchOptionsShowsTrafficKey: mapView.showsTraffic
            ] as [String : Any]
        mapItem.name = venueName
        mapItem.openInMaps(launchOptions: options)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

