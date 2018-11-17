import UIKit
import Photos
import RealmSwift

class Album: Object {
    @objc dynamic var collectionId: String = ""
    @objc dynamic var assetCollectionType: PHAssetCollectionType = PHAssetCollectionType.album
    @objc dynamic var assetCollectionSubtype: PHAssetCollectionSubtype = PHAssetCollectionSubtype.any
    @objc dynamic var title: String = ""
    let sections = List<ImageSection>()
    @objc var count: Int = 0

    override static func primaryKey() -> String? {
        return "collectionId"
    }
    
    func save() {
        let realm = RealmManager.shared.realm
        
        try! realm.write {
            realm.add(self, update: true)
        }
    }
    
    func exist() -> Bool{
        let realm = RealmManager.shared.realm
        
        //let predicate = NSPredicate(format: "collectionId = %@", self.collectionId)
        let results = realm.objects(Album.self).filter("collectionId = %@", self.collectionId)
        
        return results.count > 0
    }
    
    static func findAll() -> [Album]{
        let realm = RealmManager.shared.realm
        
        let results = realm.objects(Album.self)
        var albums: [Album] = []
        for album in results {
            albums.append(album)
        }
        
        return albums
    }
    
    static func build(collection: PHAssetCollection)-> Album {
        let album :Album = Album()
        //album.id = UUID.init().uuidString
        album.collectionId = collection.localIdentifier
        album.assetCollectionType = collection.assetCollectionType
        album.assetCollectionSubtype = collection.assetCollectionSubtype
        print("PHAssetCollection: ", album.collectionId, album.assetCollectionType.rawValue, album.assetCollectionSubtype.rawValue)
        album.title = collection.localizedTitle ?? "-"
        album.count = 0
        
        return album
    }
    
     func isSame(_ other: Album)-> Bool {
        return self.collectionId == other.collectionId
    }
    

    func reload() {
        count = 0

        let result: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionId], options: nil)

        if result.count == 0 {
            return
        }
        if result.count > 1 {
            fatalError("不可思议的相册数量。")
        }

        let collection: PHAssetCollection = result.firstObject!

        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                let groupedDate = asset.creationDate?.groupedDateString() ?? ""
                var foundSection = ImageSection.build(groupedDate: groupedDate)
                var foundIndex: Int?
                for (index, section) in self.sections.enumerated() {
                    if section.groupedDate == groupedDate {
                        foundSection = section
                        foundIndex = index
                        break
                    }
                }

                let image = Image.build(asset: asset)
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

                if self.count % 20 == 0 {
                    //通知UI刷新列表
                    DispatchQueue.main.async {
                        AlbumManager.shared.albumLoadingDelegate?.albumLoading(self)
                    }
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
