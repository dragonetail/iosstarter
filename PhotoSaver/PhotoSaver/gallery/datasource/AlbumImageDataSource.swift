
import Foundation

struct AlbumImageDataSource: ImageViewDataSource, PhotoGalleryViewDataSource {
    private let album: Album
    private let _initialIndexPath: IndexPath
    private let isCyclic: Bool //循环模式: 前后插入一个Dummy的区和一个元素

    init(_ album: Album, _ _initialIndexPath: IndexPath = IndexPath(row: 0, section: 0), _ isCyclic: Bool = false) {
        self.album = album
        self._initialIndexPath = _initialIndexPath
        self.isCyclic = isCyclic
    }

    func forkOneCyclic(_ _initialIndexPath: IndexPath) -> AlbumImageDataSource {
        return AlbumImageDataSource(album, _initialIndexPath, true)
    }

    func totalCount() -> Int {
        return self.album.count
    }

    func numberOfSections() -> Int {
        if(!self.isCyclic) {
            return album.sections.count
        }

        //循环模式: 前后插入一个Dummy的区和一个元素
        if self.album.count == 1 { //只有一个元素不需要
            return 1
        }

        //循环模式设置，前后插入一个Dummy的区和一个元素，因此总数加2
        return self.album.sections.count + 2

    }
    func numberOfSection(_ section: Int) -> Int {
        if(!self.isCyclic) {
            return self.album.sections[section].count
        }

        if self.album.count == 1 { //只有一个元素不需要
            return 1
        }

        //循环模式设置，前后插入一个Dummy的区和一个元素，判断是否为插入的Dummy区
        if section == 0 || section == self.album.sections.count + 1 {
            return 1
        }

        return album.sections[section - 1].count
    }
    func titleOfSection(_ section: Int) -> String {
        if(!self.isCyclic) {
            return self.album.sections[section].title
        }

        if self.album.count == 1 { //只有一个元素不需要
            return self.album.sections[section].title
        }

        //循环模式设置，前后插入一个Dummy的区和一个元素，判断是否为插入的Dummy区
        if section == 0 {
            return self.album.sections[self.album.sections.count - 1].title
        }
        if section == self.album.sections.count + 1 {
            return self.album.sections[0].title
        }

        return album.sections[section - 1].title
    }
    func initialIndexPath() -> IndexPath {
        if(!self.isCyclic) {
            return self._initialIndexPath
        }

        if self.album.count > 1 {
            //循环模式设置，如果多于一个元素，处理Dummy区
            return IndexPath(row: self._initialIndexPath.row, section: self._initialIndexPath.section + 1)
        } else {
            return self._initialIndexPath
        }
    }
    func image(_ indexPath: IndexPath) -> Image {
        let targetIndexPath = originalIndexPath(indexPath)

        return self.album.getImage(targetIndexPath)
    }
    
    func lastIndexPath() -> IndexPath {
        if(!self.isCyclic) {
            return IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: self.album.sections.count - 1)
        }


        return IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: album.sections.count)
    }
    
    func originalIndexPath(_ indexPath: IndexPath) -> IndexPath {
        if(!self.isCyclic) {
            return indexPath
        }
        
        //Infinite Cyclic Logic, The first and last section are dummy
        let section = indexPath.section
        //真实相册数据中的坐标
        var originalIndexPath = indexPath
        if self.album.count > 1 { //只有一个元素不需要
            if section == 0 {
                //循环模式设置，头Dummy区，内容为最后一个图片
                originalIndexPath = IndexPath(row: album.sections[album.sections.count - 1].count - 1, section: self.album.sections.count - 1)
            } else if section == self.album.sections.count + 1 {
                //循环模式设置，尾Dummy区，内容为第一个图片
                originalIndexPath = IndexPath(row: 0, section: 0)
            } else {
                originalIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            }
        }
        return originalIndexPath
    }
}

