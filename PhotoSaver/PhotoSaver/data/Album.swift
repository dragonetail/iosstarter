import UIKit
import Photos

class Album {
    var id: String
    var collectionId: String
    var collectionType: PHAssetCollectionType
    var collectionSubtype: PHAssetCollectionSubtype
    let title: String

    var sections = [ImageSection]()
    var count: Int = 0

    init(_ albumModel: AlbumModel) {
        self.id = albumModel.id
        self.collectionId = albumModel.collectionId
        self.collectionType = albumModel.collectionType
        self.collectionSubtype = albumModel.collectionSubtype
        self.title = albumModel.title
    }
    
//    init(_ collection: PHAssetCollection) {
//        self.id = UUID.init().uuidString
//        self.collectionId = collection.localIdentifier
//        self.collectionType = collection.assetCollectionType
//        self.collectionSubtype = collection.assetCollectionSubtype
//        print("PHAssetCollection: ", self.collectionId, self.collectionType.rawValue, self.collectionSubtype.rawValue)
//        self.title = collection.localizedTitle ?? "-"
//    }
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
