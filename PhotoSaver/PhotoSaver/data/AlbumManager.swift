import UIKit
import Photos
import GRDB

protocol AlbumsLoadingDelegate: class {
//    func albumsFirstLoaded(_ albumManager: AlbumManager)
    func albumsLoaded(_ albumManager: AlbumManager)
}
//protocol AlbumLoadingDelegate: class {
//    func albumLoading(_ albumManager: AlbumManager, album: Album)
//    func albumLoaded(_ albumManager: AlbumManager, album: Album)
//}

/**
    获取本机图片库
*/
class AlbumManager {
    static let shared = AlbumManager()

    var albums: [Album] = []
    var total: Int = 0
    weak var albumsLoadingDelegate: AlbumsLoadingDelegate?
    //weak var albumLoadingDelegate: AlbumLoadingDelegate?

    private init() {
    }

    /// 重新加载图片库
    func load() throws {
        log.info("即将准备用户主相册数据(第一次运行时有效)。")
        loadAndPrepareSmartAlbumUserLibrary()

        log.info("即将加载DB数据到内存。")
        loadAllFromDBToMemory({ imageModelsByAssetId in
            //通知UI刷新列表
            DispatchQueue.main.async {
                self.albumsLoadingDelegate?.albumsLoaded(self)
            }
            
            log.info("即将同步设备数据到DB。")
            self.syncAllCollections(imageModelsByAssetId, complete: {
                log.info("即将再次加载DB数据更新到内存。")
                self.loadAllFromDBToMemory({ imageModelsByAssetId in
                    //通知UI刷新列表
                    DispatchQueue.main.async {
                        self.albumsLoadingDelegate?.albumsLoaded(self)
                    }
                })
            })
        })
    }

    fileprivate func loadAndPrepareSmartAlbumUserLibrary() {
        do {
            let startTime = CACurrentMediaTime()
            try dbConn.write { db in
                let smartAlbumUserLibrary: AlbumModel? = try AlbumModel.getSmartAlbumUserLibrary(db)
                let hasImages = try AlbumModel.hasImages(db, smartAlbumUserLibrary: smartAlbumUserLibrary)

                try loadSmartAlbumUserLibraryToDB(db, smartAlbumUserLibrary, hasImages)
            }
            log.debug("准备用户主相册数据耗时：\(lround((CACurrentMediaTime() - startTime) * 1000))ms")
        } catch {
            log.warning("准备用户主相册数据失败：\(error)")
        }
    }

    fileprivate func loadAllFromDBToMemory(_ complete: @escaping (Dictionary<String, ImageModel>) -> Void) {
        DispatchQueue.global(qos: .default).async {
            //DispatchQueue.global(qos: .userInitiated).async {
            do {
                let startTime = CACurrentMediaTime()
                let imageModelsByAssetId: Dictionary<String, ImageModel> = try dbConn.read { db in
                    try self.loadAllFromDBToMemory(db)
                }

                log.debug("加载DB数据(\(self.albums.count), \(self.total))到内存耗时：\(lround((CACurrentMediaTime() - startTime) * 1000))ms")

                complete(imageModelsByAssetId)
            } catch {
                log.warning("加载DB数据到内存失败：\(error)")
            }
        }
    }

    fileprivate func syncAllCollections(_ imageModelsByAssetId: Dictionary<String, ImageModel>, complete: @escaping () -> Void) {
        DispatchQueue.global(qos: .default).async {
            do {
                let startTime = CACurrentMediaTime()
                try dbConn.write { db in
                    self.syncAllCollections(db, imageModelsByAssetId)
                }
                log.debug("同步设备数据到DB耗时：\(lround((CACurrentMediaTime() - startTime) * 1000))ms")

                complete()
            } catch {
                log.warning("同步设备数据到DB失败：\(error)")
            }
        }
    }

    fileprivate func syncAllCollections(_ db: Database, _ imageModelsByAssetId: Dictionary<String, ImageModel>) {
        //查找所有的相薄
        //let types: [PHAssetCollectionType] = [.smartAlbum, .album, .moment]
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]

        var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }

        for result in albumsFetchResults {
            result.enumerateObjects({ (collection, _, _) in
                do {
                    if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                        return
                    }

                    let collectionId = collection.localIdentifier
                    if let albumModel = try AlbumModel.getBy(db, collectionId: collectionId) {
                        try self.loadAlbumToDB(db, albumModel, imageModelsByAssetId)
                    } else {
                        var albumModel = AlbumModel(id: UUID.init().uuidString,
                                                    collectionId: collectionId,
                                                    collectionType: collection.assetCollectionType,
                                                    collectionSubtype: collection.assetCollectionSubtype,
                                                    title: collection.localizedTitle ?? "-")
                        try albumModel.insert(db)
                        try self.loadAlbumToDB(db, albumModel, imageModelsByAssetId)
                    }
                } catch {
                    log.warning("保存数据到DB失败：\(error)")
                }
            })
        }
    }

    fileprivate func loadAllFromDBToMemory(_ db: Database) throws -> Dictionary<String, ImageModel> {
        var albums: [Album] = []
        var total: Int = 0
        
        let albumModels: [AlbumModel] = try AlbumModel.fetchAll(db)
        let imageModelArray: [ImageModel] = try ImageModel.fetchAll(db)
        let imageModels: Dictionary<String, ImageModel> =
            Dictionary(grouping: imageModelArray, by: { $0.id }).mapValues { $0.last! }

        try albumModels.forEach { (albumModel: AlbumModel) in
            let album: Album = Album(albumModel)
            albums.append(album)

            let sectionModels: [SectionModel] = try albumModel.sections.fetchAll(db)
            //Ref: numbers.filter { $0 % 2 == 0 }  or album.sections.first { $0.title == sectionModel.title}
            sectionModels.forEach { (sectionModel: SectionModel) in
                var foundSection = album.sections.first { $0.title == sectionModel.title }
                if foundSection == nil {
                    foundSection = ImageSection(sectionModel)
                    album.sections.append(foundSection!)
                }

                let imageModel: ImageModel? = imageModels[sectionModel.imageId]
                //let imageModel: ImageModel? = try sectionModel.image.fetchOne(db)
                if imageModel == nil {
                    log.warning("数据不一致，imageModel == nil")
                    return //skip current process
                }
                let image = Image(imageModel!)
                foundSection!.images.append(image)
                album.count = album.count + 1
                foundSection!.count = foundSection!.count + 1
                total = total + 1
            }
        }

        albums.sort { $0.count > $1.count }

        self.albums = albums
         self.total = total

        //特殊处理，为了加快后面同步操作
        let imageModelsByAssetId: Dictionary<String, ImageModel> =
            Dictionary(grouping: imageModelArray, by: { $0.assetId }).mapValues { $0.last! }
        return imageModelsByAssetId
    }


    fileprivate func loadSmartAlbumUserLibraryToDB(_ db: Database, _ smartAlbumUserLibrary: AlbumModel?, _ hasImages: Bool) throws {
        if hasImages {
            return
        }

        var smartAlbumUserLibrary: AlbumModel? = smartAlbumUserLibrary
        if smartAlbumUserLibrary == nil {
            let result: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)

            if result.count != 1 {
                log.severe("系统错误，发现多个用户主相册数据\(result.count)")
                fatalError("不可思议的用户相册数量。")
            }

            let collection: PHAssetCollection = result.firstObject!

            smartAlbumUserLibrary = AlbumModel(id: UUID.init().uuidString,
                                               collectionId: collection.localIdentifier,
                                               collectionType: collection.assetCollectionType,
                                               collectionSubtype: collection.assetCollectionSubtype,
                                               title: collection.localizedTitle ?? "-")
            try smartAlbumUserLibrary!.insert(db)
        }


        try loadAlbumToDB(db, smartAlbumUserLibrary!, Dictionary<String, ImageModel>(), true)
    }

    fileprivate func loadAlbumToDB(_ db: Database, _ album: AlbumModel, _ imageModelsByAssetId: Dictionary<String, ImageModel>, _ partedLoading: Bool = false) throws {
        var images = imageModelsByAssetId

        let result: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [album.collectionId], options: nil)

        if result.count == 0 {
            return
        }
        if result.count > 1 {
            log.severe("系统错误，根据相册Id查询d返回多个数据\(result.count)")
            fatalError("不可思议的相册数量。")
        }

        let collection: PHAssetCollection = result.firstObject!

        var count = 0
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
        itemsFetchResult.enumerateObjects({ (asset, index, stop) in
            do {
                if asset.mediaType == .image {
                    let groupedDate = asset.creationDate?.groupedDateString() ?? ""
                    let assetId = asset.localIdentifier
                    if let _ = images[assetId] {
                        //noop
                    } else {
                        let imageId = UUID.init().uuidString
                        var image = ImageModel(id: imageId, assetId: assetId, mediaType: .image)
                        try image.insert(db)
                        images[assetId] = image

                        var section = SectionModel(albumId: album.id, title: groupedDate, imageId: imageId)
                        try section.insert(db)
                    }

                    count = count + 1
                    //只有当APP第一次运行，数据库为空的时候，会第一次初始化用户主相册，只初始化部分相册的内容，加快APP的UI显示速度
                    if partedLoading && count % 40 == 0 {
                        stop.pointee = true
                    }
                }
            } catch {
                log.warning("保存数据到DB失败：\(error)")
            }
        })
    }

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


