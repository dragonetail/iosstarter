import UIKit
import Photos

class Album {

    let collection: PHAssetCollection
    var sections = [ImageSection]()
    var count: Int = 0
//    var items: [Image] = []

    // MARK: - Initialization

    init(collection: PHAssetCollection) {
        self.collection = collection
    }

    func reload() {
        sections = [ImageSection]()
        count = 0
//        items = []

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

    func getImage(_ indexPath: IndexPath) -> Image {
        let section = sections[indexPath.section]
        let image = section.images[indexPath.row]

        return image
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
