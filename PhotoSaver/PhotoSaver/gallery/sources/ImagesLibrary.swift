import UIKit
import Photos

/// 获取本机图片库
class ImagesLibrary {
    
    var albums: [Album] = []
    
    init() {
    }
    
    /// 重新加载图片库
    func reload(_ completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.reloadSync()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    fileprivate func reloadSync() {
        let types: [PHAssetCollectionType] = [.smartAlbum, .album, .moment]
        
        var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }
        
        albums = []
        
        for result in albumsFetchResults {
            result.enumerateObjects({ (collection, _, _) in
                let album = Album(collection: collection)
                album.reload()
                
                //if !album.items.isEmpty {
                    self.albums.append(album)
                //}
            })
        }
        
        // Move Camera Roll first
        if let index = albums.index(where: { $0.collection?.assetCollectionSubtype == .smartAlbumUserLibrary }) {
            albums.g_moveToFirst(index)
        }
    }
}
