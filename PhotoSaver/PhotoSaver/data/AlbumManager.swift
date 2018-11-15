import UIKit
import Photos


protocol AlbumsLoadingDelegate: class {
    func albumsLoading(_ albumManager: AlbumManager)
    func albumsLoaded(_ albumManager: AlbumManager)
}
protocol AlbumLoadingDelegate: class {
    func albumLoading(_ album: Album)
    func albumLoaded(_ album: Album)
}

/**
    获取本机图片库
*/
class AlbumManager {
    static let shared = AlbumManager()

    var albums: [Album] = []
    var albumOfSmartAlbumUserLibrary: Album
    weak var albumsLoadingDelegate: AlbumsLoadingDelegate?
    weak var albumLoadingDelegate: AlbumLoadingDelegate?

    private init() {
        let result: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        if result.count != 1 {
            fatalError("不可思议的用户相册数量。")
        }
        
        let collection: PHAssetCollection = result.firstObject!
        self.albumOfSmartAlbumUserLibrary = Album(collection: collection)
    }

    /// 重新加载图片库
    func reload() {
        //加载用户主相册
        DispatchQueue.global(qos: .userInitiated).async {
            self.albumOfSmartAlbumUserLibrary.reload()
        }

        //加载其他相册
        DispatchQueue.global(qos: .default).async {
            let startTime = CACurrentMediaTime()
            self.loadAllCollectionsAndInit()
            let endTime = CACurrentMediaTime()
            print("Escaped seconds of Loading Albums: ", (endTime - startTime) * 1000)
        }
    }


    fileprivate func loadAllCollectionsAndInit() {
        albums = []

        loadAllCollections()

        //通知UI刷新列表
        DispatchQueue.main.async {
            self.albumsLoadingDelegate?.albumsLoading(self)
        }


        self.albums.forEach { (album: Album) in
            album.reload()

            //通知UI刷新列表
            DispatchQueue.main.async {
                self.albumLoadingDelegate?.albumLoaded(album)
            }
        }

        self.albums.sort { (left, right) -> Bool in
            return left.count > right.count
        }
        
        self.albums.insert(albumOfSmartAlbumUserLibrary, at: 0)

        //通知UI刷新列表
        DispatchQueue.main.async {
            self.albumsLoadingDelegate?.albumsLoaded(self)
        }
    }


    fileprivate func loadAllCollections() {
        //查找所有的相薄
        //let types: [PHAssetCollectionType] = [.smartAlbum, .album, .moment]
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]

        var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }

        for result in albumsFetchResults {
            result.enumerateObjects({ (collection, _, _) in
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    return
                }
                let album = Album(collection: collection)
                self.albums.append(album)
            })
        }
    }

//    fileprivate func changeSmartAlbumUserLibraryToFirst() {
//        // Move Camera Roll first
//        if let index = albums.index(where: { $0.assetCollectionSubtype == .smartAlbumUserLibrary }) {
//            //_moveToFirst(index)
//            let smartAlbumUserLibrary = albums[index]
//            albums.remove(at: index)
//            albums.insert(smartAlbumUserLibrary, at: 0)
//        }
//    }

}
//enum PHAssetCollectionType : Int {
//    case Album //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
//    case SmartAlbum //经由相机得来的相册
//    case Moment //Photos 为我们自动生成的时间分组的相册
//}
//
//enum PHAssetCollectionSubtype : Int {
//    case AlbumRegular //用户在 Photos 中创建的相册，也就是我所谓的逻辑相册
//    case AlbumSyncedEvent //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步过来的事件。然而，在iTunes 12 以及iOS 9.0 beta4上，选用该类型没法获取同步的事件相册，而必须使用AlbumSyncedAlbum。
//    case AlbumSyncedFaces //使用 iTunes 从 Photos 照片库或者 iPhoto 照片库同步的人物相册。
//    case AlbumSyncedAlbum //做了 AlbumSyncedEvent 应该做的事
//    case AlbumImported //从相机或是外部存储导入的相册，完全没有这方面的使用经验，没法验证。
//    case AlbumMyPhotoStream //用户的 iCloud 照片流
//    case AlbumCloudShared //用户使用 iCloud 共享的相册
//    case SmartAlbumGeneric //文档解释为非特殊类型的相册，主要包括从 iPhoto 同步过来的相册。由于本人的 iPhoto 已被 Photos 替代，无法验证。不过，在我的 iPad mini 上是无法获取的，而下面类型的相册，尽管没有包含照片或视频，但能够获取到。
//    case SmartAlbumPanoramas //相机拍摄的全景照片
//    case SmartAlbumVideos //相机拍摄的视频
//    case SmartAlbumFavorites //收藏文件夹
//    case SmartAlbumTimelapses //延时视频文件夹，同时也会出现在视频文件夹中
//    case SmartAlbumAllHidden //包含隐藏照片或视频的文件夹
//    case SmartAlbumRecentlyAdded //相机近期拍摄的照片或视频
//    case SmartAlbumBursts //连拍模式拍摄的照片，在 iPad mini 上按住快门不放就可以了，但是照片依然没有存放在这个文件夹下，而是在相机相册里。
//    case SmartAlbumSlomoVideos //Slomo 是 slow motion 的缩写，高速摄影慢动作解析，在该模式下，iOS 设备以120帧拍摄。不过我的 iPad mini 不支持，没法验证。
//    case SmartAlbumUserLibrary //这个命名最神奇了，就是相机相册，所有相机拍摄的照片或视频都会出现在该相册中，而且使用其他应用保存的照片也会出现在这里。
//    case Any //包含所有类型
//}


