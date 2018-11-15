import UIKit
import Photos

class Album {

  let collection: PHAssetCollection
  var items: [Image] = []

  

  init(collection: PHAssetCollection) {
    self.collection = collection
  }

  func reload() {
    items = []
// MARK: - Initialization
    
    let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
    itemsFetchResult.enumerateObjects({ (asset, count, stop) in
      if asset.mediaType == .image {
        self.items.append(Image(asset: asset))
      }
    })
  }
}
