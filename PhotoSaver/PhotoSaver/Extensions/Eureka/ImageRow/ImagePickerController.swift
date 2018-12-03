import Eureka
import Foundation
import Photos

/// Selector Controller used to pick an image
open class ImagePickerController: UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// The row that pushed or presented this controller
    public var row: RowOf<UIImage>!

    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?

    open override func viewDidLoad() {
        super.viewDidLoad()
        allowsEditing = (row as? ImageRow)?.allowEditor ?? false
        delegate = self
    }

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //(row as? ImageRow)?.imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        //(row as? ImageRow)?.imageURL = info[.referenceURL] as? URL
        let asset = info[.phAsset] as? PHAsset
        (row as? ImageRow)?.imageLocalIdentifier = asset?.localIdentifier
        //        print((row as? ImageRow)?.imageURL )
        //        print( info[.mediaURL]  )
        //        print( info[.imageURL]  )
        //        print(asset?.location)
        //        print(asset?.localIdentifier)

        row.value = info[(row as? ImageRow)?.useEditedImage ?? false ? UIImagePickerController.InfoKey.editedImage : UIImagePickerController.InfoKey.originalImage] as? UIImage
        (row as? ImageRow)?.userPickerInfo = info
        onDismissCallback?(self)
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onDismissCallback?(self)
    }
}

