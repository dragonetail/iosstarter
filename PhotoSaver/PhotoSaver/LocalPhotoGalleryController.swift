import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit
import SVProgressHUD


class LocalPhotoGalleryController: GalleryController {
    let editor: VideoEditing = VideoEditor()

    override func viewDidLoad() {
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true

        super.viewDidLoad()
    }
    
    // MARK: - 继承动作
    override func didSelectImages(images: [Image]) {
        print("galleryController: didSelectImages")
    }
    override func didSelectVideo(video: Video) {
        print("galleryController: didSelectVideo")
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    let controller = AVPlayerViewController()
                    controller.player = AVPlayer(url: tempPath)
                    
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    override func requestLightbox(images: [Image]) {
        LightboxConfig.DeleteButton.enabled = true
        
        SVProgressHUD.show()
        Image.resolve(images: images, completion: { [weak self] resolvedImages in
            SVProgressHUD.dismiss()
            self?.showLightbox(images: resolvedImages.compactMap({ $0 }))
        })
    }
    
    
    func showLightbox(images: [UIImage]) {
        guard images.count > 0 else {
            return
        }
        
        let lightboxImages = images.map({ LightboxImage(image: $0) })
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        lightbox.dismissalDelegate = self
        
        self.present(lightbox, animated: true, completion: nil)
    }
}


// MARK: - LightboxControllerDismissalDelegate
extension LocalPhotoGalleryController: LightboxControllerDismissalDelegate {
    func lightboxControllerWillDismiss(_ controller: LightboxController) {

    }
}

