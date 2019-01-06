import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let localPhotoGalleryController = PhotoGalleryController()
        localPhotoGalleryController.title = "Gallery.Images.Title".extLocalize(fallback: "本地相册")
        localPhotoGalleryController.tabBarItem = UITabBarItem(title: localPhotoGalleryController.title, image: UIImage(named: "album"), tag: 0)


        let cloudPhotoViewController = PhotoGalleryController()
        cloudPhotoViewController.title = "Gallery.Images.Title".extLocalize(fallback: "云相册")
        cloudPhotoViewController.tabBarItem = UITabBarItem(title: cloudPhotoViewController.title, image: UIImage(named: "cloud"), tag: 0)


        let transferViewController = PhotoGalleryController()
        transferViewController.title = "Gallery.Images.Title".extLocalize(fallback: "云传输")
        transferViewController.tabBarItem = UITabBarItem(title: transferViewController.title, image: UIImage(named: "cloud-transfer"), tag: 0)

        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        profileViewController.title = "Gallery.Images.Title".extLocalize(fallback: "我")
        profileViewController.tabBarItem = UITabBarItem(title: profileViewController.title, image: UIImage(named: "profile"), tag: 0)

        let tabBarList = [ localPhotoGalleryController, profileViewController, cloudPhotoViewController, transferViewController]


        viewControllers = tabBarList
    }
}
