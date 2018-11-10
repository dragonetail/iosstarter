import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //CyaneaOctopus.setGlobalThemeUsingPrimaryColor(FlatMint, withSecondaryColor: FlatBlue,  andContentStyle: .contrast)
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        if authorizationStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    self.startup()
                } else {
                    self.alertAuthorizationStatus()
                }
            })
        } else if authorizationStatus == .authorized {
            self.startup()
        } else {
            self.alertAuthorizationStatus()
        }

        return true
    }

    private func startup() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.window = UIWindow(frame: UIScreen.main.bounds)
            if let window = self.window {
                window.backgroundColor = UIColor.white

                let tabBarController = TabBarController()
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        })
    }

    private func alertAuthorizationStatus() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.window = UIWindow(frame: UIScreen.main.bounds)
            if let window = self.window {
                let alertController = UIAlertController(title: "提示", message: "没有获取用户访问相册的授权。", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "知道了", style: .default, handler: {
                    action in
                    //noop
                }))
                
                window.rootViewController = NoPhotoAuthorizationController()
                window.makeKeyAndVisible()
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        //eventBus.unbindAll()
    }
}
