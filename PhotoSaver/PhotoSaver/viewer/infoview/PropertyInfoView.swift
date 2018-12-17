import UIKit
import PureLayout
import Eureka
import SwiftBaseBootstrap
import ImageIOSwift_F2

class PropertyInfoView: BaseViewWithAutolayout {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView().autoLayout("scrollView")

        //scrollView.alwaysBounceVertical = true

        scrollView.addSubview(infoStackView)
        self.addSubview(scrollView)
        return scrollView
    }()
    var infoStackView: UIStackView = {
        let infoStackView = UIStackView().autoLayout("infoStackView")

        infoStackView.axis = .vertical
        infoStackView.alignment = .center
        infoStackView.distribution = .fill
        infoStackView.spacing = 5

        return infoStackView
    }()

    var image: Image? {
        didSet {
            setupAndComposeView()
        }
    }

    override func setupAndComposeView() {
        _ = self.autoLayout("PropertyInfoView")
        self.backgroundColor = UIColor.clear

        infoStackView.arrangedSubviews.forEach { (view) in
            infoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
            view.removeConstraints(view.constraints)
        }

        defer {
            self.setNeedsUpdateConstraints()
        }

        guard let image = image else {
            addAlterInfo()
            return
        }

        defer {
            addSection("附属信息")
            addInfo("文件名", image.filename, image.filename)
            addInfo("文件路径", image.filePath, image.filePath)
            addInfo("资源ID", "", image.assetId)
            addInfo("图片ID", "", image.id)
        }

        //TODO 文件格式
        var fileExtensionStr = ""
        if let fileExtension = image.fileExtension { fileExtensionStr = " [\(fileExtension.uppercased())]" }
        addInfo("类型", "", LocalizedStringHelper.localized(image.mediaType, image.mediaSubtype) + fileExtensionStr)
        addInfo("尺寸", image.metadata?.pixelWidth, "\(image.metadata?.pixelWidth ?? 0)x\(image.metadata?.pixelHeight ?? 0)")
        addInfo("大小", image.dataSize, (image.dataSize?.format() ?? "") + " (" + image.dataSizeStr + ")")
        addInfo("拍摄日期", image.creationDate, image.creationDate?.fullDatetime)
        addInfo("修改日期", image.modificationDate, image.modificationDate?.fullDatetime)
        addInfo("收藏", image.isFavorite ? "" : nil, image.isFavorite ? "已收藏" : "")
        addInfo("旋转", image.orientation, LocalizedStringHelper.localized(image.orientation))

        addInfo("来源", image.metadata?.assetSourceType, LocalizedStringHelper.localized(image.metadata?.assetSourceType))
        addInfo("设备来源", image.metadata?.device, image.metadata?.device)
        addInfo("播放类型", image.metadata?.playbackStyle, LocalizedStringHelper.localized(image.metadata?.playbackStyle))
        let duration = image.metadata?.duration ?? 0
        addInfo("播放时长", duration == 0 ? nil : duration, "\(duration)")

        guard let metadata = image.metadata else {
            return
        }

        if let location = metadata.location {
            addSection("位置信息")
            addInfo("经度", "", String(format: "%.2f", location.longitude))
            addInfo("经度", "", String(format: "%.2f", location.latitude))
            addInfo("高度", "", String(format: "%.1f 米", location.altitude))
            addInfo("水平精度", "", String(format: "%.2f", location.horizontalAccuracy))
            addInfo("垂直精度", "", String(format: "%.2f", location.verticalAccuracy))
            addInfo("角度", "", String(format: "%.1f 度", location.course))
            addInfo("速度", "", String(format: "%.1f 米/秒", location.speed))
            addInfo("时间", "", location.timestamp.fullDatetime)
        }

        guard let imageProperties = metadata.imageProperties else {
            return
        }
        let codableValue: [String: CodableProperty] = imageProperties.codableValue

        addSection("图像信息")
        addCodableProperty(codableValue, "色彩模式", "ColorModel")
        addCodableProperty(codableValue, "色彩配置", "ProfileName")
        addCodableProperty(codableValue, "深度", "Depth")
        addCodableProperty(codableValue, "DPI宽度", "DPIWidth")
        addCodableProperty(codableValue, "DPI高度", "DPIHeight")

        //https://zh.wikipedia.org/wiki/JPEG%E6%96%87%E4%BB%B6%E4%BA%A4%E6%8D%A2%E6%A0%BC%E5%BC%8F
        if let jfifCodableValue = codableValue["{JFIF}"]?.dict {
            addSection("JFIF信息")
            addCodableProperty(jfifCodableValue, "水平密度", "XDensity")
            addCodableProperty(jfifCodableValue, "垂直密度", "YDensity")
            addCodableProperty(jfifCodableValue, "密度单位", "DensityUnit") { rawValue in
                guard let rawValue = rawValue,
                    let intValue = Int((rawValue as? String) ?? "0")
                    else { return "" }

                return intValue == 2 ? "厘米" : intValue == 1 ? "英寸" : "无单位"
            }
            addCodableProperty(jfifCodableValue, "JFIF版本", "JFIFVersion") { rawValue in
                guard let rawValue = rawValue,
                    let arrayValue = rawValue as? [String]
                    else { return "" }
                return arrayValue.joined(separator: ".")
            }
        }

        //http://www.fileformat.info/format/tiff/corion.htm
        if let tiffCodableValue = codableValue["{TIFF}"]?.dict {
            addSection("TIFF信息")
            addCodableProperty(tiffCodableValue, "X分辨率", "XResolution")
            addCodableProperty(tiffCodableValue, "Y分辨率", "YResolution")
            addCodableProperty(tiffCodableValue, "分辨单位", "ResolutionUnit") { rawValue in
                guard let rawValue = rawValue,
                    let intValue = Int((rawValue as? String) ?? "0")
                    else { return "" }

                return intValue == 3 ? "厘米" : intValue == 2 ? "英寸" : "无单位"
            }
            addCodableProperty(tiffCodableValue, "拍摄设备", "Model")
            addCodableProperty(tiffCodableValue, "设备厂商", "Make")
            addCodableProperty(tiffCodableValue, "软件", "Software")
            //PhotometricInterpretation
        }

        //https://zh.wikipedia.org/wiki/EXIF
        //https://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/EXIF.html
        if let exifCodableValue = codableValue["{Exif}"]?.dict {
            addSection("Exif信息")
            addCodableProperty(exifCodableValue, "色彩空间", "ColorSpace") { rawValue in
                guard let rawValue = rawValue,
                    let intValue = Int((rawValue as? String) ?? "0")
                    else { return "" }

                let value = [1: "Gray Gamma 2.2", 2: "sRGB", 3: "Adobe RGB", 4: "ProPhoto RGB"][intValue] ?? "Unknown"
                return "\(value)"
            }
            addCodableProperty(exifCodableValue, "色彩方案", "ComponentsConfiguration") { rawValue in
                guard let rawValue = rawValue,
                    let arrayValue = rawValue as? [String]
                    else { return "" }
                return arrayValue.map({ ["1": "Y", "2": "Cb", "3": "Cr", "4": "R", "5": "G", "6": "B"][$0] ?? "" }).joined(separator: "") + " [" + arrayValue.joined(separator: ",") + "]"
            }
            addCodableProperty(exifCodableValue, "横像素数", "PixelYDimension")
            addCodableProperty(exifCodableValue, "纵像素数", "PixelXDimension")
            addCodableProperty(exifCodableValue, "ISO感光", "ISOSpeedRatings") { rawValue in
                guard let rawValue = rawValue,
                    let arrayValue = rawValue as? [String]
                    else { return "" }
                return arrayValue.joined(separator: " ")
            }
            addCodableProperty(exifCodableValue, "曝光时间", "ExposureTime") { rawValue in
                guard let rawValue = rawValue,
                    let strValue = rawValue as? String
                    else { return "" }

                return strValue + " 秒"
            }
            addCodableProperty(exifCodableValue, "拍照模式", "ExposureProgram") { rawValue in
                guard let rawValue = rawValue,
                    let intValue = Int((rawValue as? String) ?? "0")
                    else { return "" }

                let value = [1: "手动", 2: "自动", 3: "光圈自动", 4: "快门优先", 5: "慢速",
                             6: "高速", 7: "头像", 8: "风景", 9: "灯光"][intValue] ?? "未定义"
                return "\(value) [\(intValue)]"
            }
            addCodableProperty(exifCodableValue, "场景类型", "SceneCaptureType") { rawValue in
                guard let rawValue = rawValue,
                    let intValue = Int((rawValue as? String) ?? "0")
                    else { return "" }

                let value = [1: "风景", 2: "头像", 3: "夜晚"][intValue] ?? "标准"
                return "\(value) [\(intValue)]"
            }
            addCodableProperty(exifCodableValue, "Exif版本", "ExifVersion") { rawValue in
                guard let rawValue = rawValue,
                    let arrayValue = rawValue as? [String]
                    else { return "" }
                return arrayValue.joined(separator: ".")
            }
        }
    }

    // invoked only once
    override func setupConstraints() {
        scrollView.autoPinEdgesToSuperviewEdges()
        infoStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 13, left: 0, bottom: 25, right: 0))
        infoStackView.autoMatch(.width, to: .width, of: scrollView)
    }

    override func modifyConstraints() {
        infoStackView.arrangedSubviews.forEach { (view) in
            if let subStachView = view as? UIStackView {
                subStachView.autoPinEdge(toSuperviewEdge: .leading, withInset: 0)
                subStachView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)

                let views = subStachView.arrangedSubviews
                //views[0].autoMatch(.width, to: .width, of: subStachView, withMultiplier: 0.20)
                views[0].autoSetDimension(.width, toSize: 75)
                views[0].autoPinEdge(.leading, to: .leading, of: subStachView)

                views[1].autoPinEdge(.trailing, to: .trailing, of: subStachView)
            }
            if let subSingleLabel = view as? UIPaddedLabel {
                subSingleLabel.autoPinEdge(toSuperviewEdge: .leading)
                subSingleLabel.autoPinEdge(toSuperviewEdge: .trailing)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        //self.autoPrintConstraints()
        //self.infoStackView.autoPrintConstraints()
    }

    func addInfo(_ title: String, _ checkValue: Any?, _ value: String?) {
        if checkValue == nil {
            return
        }

        let titleLabel = UIPaddedLabel().autoLayout("titleLabel")
        titleLabel.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        titleLabel.text = "\(title)"
        titleLabel.textAlignment = .right
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.flatSkyBlueDarkColor()

        let valueLabel = UIPaddedLabel().autoLayout("valueLabel")
        valueLabel.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        valueLabel.text = "\(value ?? "")"
        valueLabel.textColor = UIColor.flatGrayDarkColor()
        valueLabel.textAlignment = .left
        valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = NSLineBreakMode.byCharWrapping

        let lineView = UIStackView(arrangedSubviews: [
            titleLabel,
            valueLabel,
        ]).autoLayout("lineView")
        lineView.axis = .horizontal
        lineView.spacing = 15
        lineView.alignment = .center
        lineView.distribution = .fill
        infoStackView.addArrangedSubview(lineView)
    }

    func addSection(_ title: String) {
        let titleLabel = UIPaddedLabel().autoLayout("alterInfo")
        titleLabel.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 10)
        titleLabel.text = " " + title
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.flatSkyBlueColor()
        titleLabel.backgroundColor = UIColor(red: 241 / 255.0, green: 243 / 255.0, blue: 244 / 255.0, alpha: 1.0)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)

        infoStackView.addArrangedSubview(titleLabel)
    }

    func addAlterInfo() {
        let titleLabel = UIPaddedLabel().autoLayout("alterInfo")
        titleLabel.padding = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        titleLabel.text = "no...image...."
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

        infoStackView.addArrangedSubview(titleLabel)
    }

    func addCodableProperty(_ codableValue: [String: CodableProperty], _ title: String, _ codableKey: String, valueMapping: ((Any?) -> String)? = nil) {
        guard let property = codableValue[codableKey] else {
            return
        }
        let propertyValue = getPropertyValue(property, valueMapping: valueMapping)
        addInfo(title, propertyValue, propertyValue)
    }

    func getPropertyValue(_ property: CodableProperty, valueMapping: ((Any?) -> String)? = nil) -> String {
        switch property.type {
        case "String":
            return valueMapping?(property.string) ?? property.string!
        case "Number":
            return valueMapping?(property.number) ?? property.number!
        case "Bool":
            return valueMapping?(property.bool) ?? (property.bool! ? "True" : "False")
        case "Array":
            let array = property.array?.map({ getPropertyValue($0) }) ?? []
            return valueMapping?(array) ?? "\(array)"
        case "Data":
            return valueMapping?(property.string) ?? property.string!
        case "Dictionary":
            return ""
        default:
            return ""
        }
    }
}
