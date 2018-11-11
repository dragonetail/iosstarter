import UIKit
import Photos

class Album {
    var id: String
    var collectionId: [String]?
    var assetCollectionType: PHAssetCollectionType?
    var assetCollectionSubtype: PHAssetCollectionSubtype?
    let title: String
    //let collection: PHAssetCollection?
    var sections = [ImageSection]()
    var count: Int = 0

//    open var localizedLocationNames: [String] { get }
//
//
//    // Fetch asset collections of a single type matching the provided local identifiers (type is inferred from the local identifiers)
//    open class func fetchAssetCollections(withLocalIdentifiers identifiers: [String], options: PHFetchOptions?) -> PHFetchResult<PHAssetCollection>

    convenience init() {
        self.init(collection: nil)
    }

    init(collection: PHAssetCollection?) {
        self.id = UUID.init().uuidString
        self.collectionId = collection?.localizedLocationNames
        self.assetCollectionType = collection?.assetCollectionType
        self.assetCollectionSubtype = collection?.assetCollectionSubtype
        self.title = collection?.localizedTitle ?? "-"
    }

    func reload() {
        sections = [ImageSection]()
        count = 0

        guard let collectionId = collectionId else {
            return
        }

        var result: PHFetchResult<PHAssetCollection>? = nil
        var collection: PHAssetCollection? = nil
        if collectionId.count > 0 {
            result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: collectionId, options: nil)
        }else{
            result = PHAssetCollection.fetchAssetCollections(with: assetCollectionType!, subtype: assetCollectionSubtype!, options: nil)
        }
        
        if result!.count == 0 {
            return
        }
        if result!.count > 1 {
            fatalError("不可思议的相册数量。")
        }
        
        collection = result!.firstObject

        let itemsFetchResult = PHAsset.fetchAssets(in: collection!, options: Utils.fetchOptions())
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                let groupedDate = asset.creationDate?.groupedDateString() ?? ""
                var foundSection = ImageSection(groupedDate: groupedDate)
                var foundIndex: Int?
                for (index, section) in self.sections.enumerated() {
                    if section.groupedDate == groupedDate {
                        foundSection = section
                        foundIndex = index
                    }
                }

                let image = Image(asset: asset)
//                photo.assetID = asset.localIdentifier
//
//                if asset.duration > 0 {
//                    photo.type = .video
//                }

                foundSection.images.append(image)
                self.count = self.count + 1
                foundSection.count = foundSection.count + 1

                if foundIndex == nil {
                    self.sections.append(foundSection)
                }
            }
        })
    }
}
extension Album {
    func getImage(_ indexPath: IndexPath) -> Image {
        let section = sections[indexPath.section]
        let image = section.images[indexPath.row]

        return image
    }

    func previous(_ indexPath: IndexPath?) -> IndexPath? {
        guard let indexPath = indexPath else { return nil }

        var sessionIndex = indexPath.section
        var rowIndex = indexPath.row


        rowIndex = rowIndex - 1;
        if rowIndex < 0 {
            sessionIndex = sessionIndex - 1
            if sessionIndex < 0 {
                sessionIndex = sections.count - 1
            }

            let section = sections[sessionIndex]
            rowIndex = section.count - 1
        }
        return IndexPath(row: rowIndex, section: sessionIndex)
    }

    func next(_ indexPath: IndexPath?) -> IndexPath? {
        guard let indexPath = indexPath else { return nil }

        var sessionIndex = indexPath.section
        var rowIndex = indexPath.row
        let section = sections[sessionIndex]

        rowIndex = rowIndex + 1;
        if rowIndex >= section.count {
            sessionIndex = sessionIndex + 1
            rowIndex = 0

            if sessionIndex >= sections.count {
                sessionIndex = 0
            }
        }
        return IndexPath(row: rowIndex, section: sessionIndex)
    }


    func indexPathForIndex(_ index: Int) -> IndexPath? {
        var count = 0
        for section in 0 ..< self.sections.count {
            let rows = sections[section].count
            if index >= count && index < count + rows {
                let foundRow = index - count
                return IndexPath(row: foundRow, section: section)
            }
            count += rows
        }

        return nil
    }

}


extension Date {

    static var aaa: String = ""

    static var shortDateFormatter: DateFormatter = {
        //Ref: http://nsdateformatter.com/
        //guard let formatString = DateFormatter.dateFormat(fromTemplate: "MMMdEEEE", options: 0, locale: Locale(identifier: "zh_CN"))
        guard let formatString = DateFormatter.dateFormat(fromTemplate: "MMMdEEEE", options: 0, locale: Locale.current)
            else { fatalError() }
        //print(formatString)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formatString

        return dateFormatter
    }()

    static var fullDateFormatter: DateFormatter = {
        //Ref: http://nsdateformatter.com/
        //guard let formatString = DateFormatter.dateFormat(fromTemplate: "MMMdEEEE", options: 0, locale: Locale(identifier: "zh_CN"))
        guard let formatString = DateFormatter.dateFormat(fromTemplate: "MMMdyyyyEEEE", options: 0, locale: Locale.current)
            else { fatalError() }
        //print(formatString)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formatString

        return dateFormatter
    }()

    func groupedDateString() -> String {
        let now = Date()
        let calendar = Calendar.current
        let curYear = calendar.component(.year, from: now)
        let year = calendar.component(.year, from: self)

        if year == curYear {
            return Date.shortDateFormatter.string(from: self)
        } else {
            return Date.fullDateFormatter.string(from: self)
        }
    }
}
