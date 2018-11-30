import Foundation
import Photos

struct FileUtils {
    static func saveImage(_ image: UIImage?, _ filepathAppending: String) {
        guard let image = image else {
            return
        }
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filepathAppending)
        let imageData = image.jpegData(compressionQuality: 1.0)
        let result = fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        if !result {
            log.warning("创建图片文件失败: \(filepathAppending)")
        }
    }

    static func loadImage(_ filepathAppending: String?, placeHolder: String = "profile_place_holder", complete: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let filepathAppending = filepathAppending else {
                let image = UIImage.init(named: placeHolder)!
                DispatchQueue.main.async {
                    complete(image)
                }
                return
            }

            let fileManager = FileManager.default
            // Here using getDirectoryPath method to get the Directory path
            let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(filepathAppending)
            if fileManager.fileExists(atPath: imagePath) {
                let image = UIImage(contentsOfFile: imagePath)!
                DispatchQueue.main.async {
                    complete(image)
                }
            } else {
                log.warning("没有找到图片文件: \(filepathAppending)")
                let image = UIImage.init(named: placeHolder)!
                DispatchQueue.main.async {
                    complete(image)
                }
            }
        }
    }



    static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func createDirectory(_ path: String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(path)
        if !fileManager.fileExists(atPath: paths) {
            do {
                try fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log.warning("创建目录失败: \(path), \(error)")
            }
        } else {
            log.info("创建目录成功: \(path)")
        }
    }

//    static func saveImageToDocumentDirectory() {
//        let fileManager = FileManager.default
//        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("apple.jpg")
//        let image = UIImage(named: "apple.jpg")
//        let imageData = UIImageJPEGRepresentation(image!, 0.5)
//        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
//    }
//
//    static func getImage(imageName : String)-> UIImage{
//        let fileManager = FileManager.default
//        // Here using getDirectoryPath method to get the Directory path
//        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
//        if fileManager.fileExists(atPath: imagePath){
//            return UIImage(contentsOfFile: imagePath)!
//        }else{
//            print("No Image available")
//            return UIImage.init(named: "placeholder.png")! // Return placeholder image here
//        }
//    }

    static func deleteDirectory(directoryName: String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directoryName)
        if fileManager.fileExists(atPath: paths) {
            try! fileManager.removeItem(atPath: paths)
        } else {
            log.warning("删除的目录不存在: \(directoryName)")
        }
    }

}
