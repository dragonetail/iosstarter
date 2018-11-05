import UIKit
import Photos

class Album {

    let title: String
    let collection: PHAssetCollection?
    var sections = [ImageSection]()
    var count: Int = 0

    convenience init() {
        self.init(collection: nil)
    }
    
    init(collection: PHAssetCollection?) {
        self.collection = collection
        self.title = collection?.localizedTitle ?? "-"
    }

    func reload() {
        sections = [ImageSection]()
        count = 0

        guard let collection = self.collection else {
            return
        }

        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
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

    func groupedDateString() -> String {
        let noTimeDate = Calendar.current.startOfDay(for: self)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let groupedDateString = dateFormatter.string(from: noTimeDate)

        return groupedDateString
    }
}
