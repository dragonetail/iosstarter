import UIKit
import PureLayout
import Eureka
import SwiftBaseBootstrap
import ImageIOSwift_F2
import MapKit
import CoreLocation

class SummaryInfoView: BaseViewWithAutolayout {
    lazy var filenameLabel: UIPaddedLabel = {
        let label = UIPaddedLabel().autoLayout("filenameLabel")
        label.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    lazy var fileSizeLabel: UIPaddedLabel = {
        let label = UIPaddedLabel().autoLayout("fileSizeLabel")
        label.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        label.textColor = UIColor.black
        label.textAlignment = .right
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    lazy var dateLabel: UIPaddedLabel = {
        let label = UIPaddedLabel().autoLayout("dateLabel")
        label.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    lazy var makerDeviceLabel: UIPaddedLabel = {
        let label = UIPaddedLabel().autoLayout("makerDeviceLabel")
        label.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        label.textColor = UIColor.black
        label.textAlignment = .right
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    lazy var addressLabel: UIPaddedLabel = {
        let label = UIPaddedLabel().autoLayout("addressLabel")
        label.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    lazy var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero).autoLayout("mapView")
        mapView.layer.borderWidth = 0.5
        mapView.layer.borderColor = UIColor.lightGray.cgColor
        mapView.clipsToBounds = true

        mapView.delegate = self

        return mapView
    }()

    var image: Image? {
        didSet {
            guard let image = image else {
                filenameLabel.text = "-"
                fileSizeLabel.text = "-"
                makerDeviceLabel.text = "-"
                dateLabel.text = "-"
                addressLabel.text = "-"
                return
            }

            filenameLabel.text = image.filename

            var filesizeStr = ""
            if let _ = image.metadata?.pixelWidth {
                filesizeStr = filesizeStr + "\(image.metadata?.pixelWidth ?? 0)x\(image.metadata?.pixelHeight ?? 0)"
            }
            filesizeStr = filesizeStr + " (" + image.dataSizeStr + ")"
            fileSizeLabel.text = filesizeStr

            makerDeviceLabel.text = (image.metadata?.imageProperties?.codableValue["{TIFF}"]?.dict?["Model"]?.string) ?? "-"

            dateLabel.text = image.creationDate?.extFullDatetime ?? "-"

            setupLocationMap(image.metadata?.location)
        }
    }

    override func setupAndComposeView() {
        _ = self.autoLayout("SummaryInfoView")
        self.backgroundColor = UIColor.clear

        [filenameLabel, fileSizeLabel, makerDeviceLabel, dateLabel, addressLabel, mapView].forEach({ (view) in
            self.addSubview(view)
        })
    }

    // invoked only once
    override func setupConstraints() {
        filenameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        filenameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 0)

        fileSizeLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        fileSizeLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        fileSizeLabel.autoPinEdge(.left, to: .right, of: filenameLabel, withOffset: 10)

        let lineSpace: CGFloat = 5
        dateLabel.autoPinEdge(.top, to: .bottom, of: filenameLabel, withOffset: lineSpace)
        dateLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 0)

        makerDeviceLabel.autoPinEdge(.top, to: .bottom, of: filenameLabel, withOffset: lineSpace)
        makerDeviceLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        makerDeviceLabel.autoPinEdge(.left, to: .right, of: dateLabel, withOffset: 10)

        addressLabel.autoPinEdge(.top, to: .bottom, of: dateLabel, withOffset: lineSpace)
        addressLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        addressLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 0)

        mapView.autoPinEdge(.top, to: .bottom, of: addressLabel, withOffset: lineSpace - 3)
        mapView.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        mapView.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        mapView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
    }

    fileprivate func setupLocationMap(_ imageLocation: ImageMetadataLocation?) {
        var centerLocation: CLLocation = CLLocation(latitude: 38.94213074118226, longitude: 115.98084916088865) //白洋淀
        if let imageLocation = imageLocation {
            let latDelta = 0.2
            let longDelta = 0.2
            let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            centerLocation = CLLocation(latitude: imageLocation.latitude, longitude: imageLocation.longitude)
            let currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: centerLocation.coordinate,
                                                                       span: currentLocationSpan)
            mapView.setRegion(currentRegion, animated: true)

            CLGeocoder().reverseGeocodeLocation(centerLocation, completionHandler: {
                [weak self, weak mapView] (placemarks: [CLPlacemark]?, error: Error?) -> Void in
                if let _ = error {
                    self?.addressLabel.text = "地址解析失败"
                    return
                }

                if let p = placemarks?[0] {
                    //print(p) //输出反编码信息
                    var address = ""
                    address.append("\(p.country ?? "")") //国家
                    address.append("\(p.administrativeArea ?? "")") //省份
                    address.append("\(p.subAdministrativeArea ?? "")")//其他行政区域信息（自治区等）
                    address.append("\(p.locality ?? "")") //城市
                    address.append("\(p.subLocality ?? "")") //区划
                    address.append("\(p.thoroughfare ?? "")") //街道
                    //address.append("\(p.subThoroughfare ?? "")") //门牌
                    address.append("\(p.name ?? "")") //地名
                    //address.append("\(p.isoCountryCode ?? "")") //国家编码
                    //address.append("\(p.postalCode ?? "")") //邮编
                    //address.append("\(p.areasOfInterest ?? "")") //关联的或利益相关的地标

                    self?.addressLabel.text = address

                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = centerLocation.coordinate
                    pointAnnotation.title = p.name ?? address
                    mapView?.annotations.forEach({ (annotation) in
                        mapView?.removeAnnotation(annotation)
                    })
                    mapView?.addAnnotation(pointAnnotation)
                    mapView?.selectAnnotation(pointAnnotation, animated: true)
                } else {
                    self?.addressLabel.text = "地址解析无结果"
                }
            })
        } else {
            addressLabel.text = "无位置信息"
            let latDelta = 0.5
            let longDelta = 0.5
            let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: centerLocation.coordinate,
                                                                       span: currentLocationSpan)
            mapView.setRegion(currentRegion, animated: true)
            //let pointAnnotation = MKPointAnnotation()
            //pointAnnotation.coordinate = centerLocation.coordinate
            //pointAnnotation.title = "中国雄安 白洋淀"
            //mapView.addAnnotation(pointAnnotation)
            //mapView.selectAnnotation(pointAnnotation, animated: true)
        }
    }
}

extension SummaryInfoView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuserId = "mapPinView"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "mapPinView") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.pinTintColor = UIColor.green
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            pinView?.annotation = annotation
        }

        return pinView
    }
}
