import UIKit
import Photos
import GRDB
import XCGLogger

// The shared database queue
var dbConn: DatabaseQueue!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        log.info("日志启动。")
        
        //CyaneaOctopus.setGlobalThemeUsingPrimaryColor(FlatMint, withSecondaryColor: FlatBlue,  andContentStyle: .contrast)
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        if authorizationStatus == .notDetermined {
            log.info("访问照片未授权。")
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    log.info("访问照片成功授权。")
                    self.startup(application)
                } else {
                    log.info("访问照片拒绝授权。")
                    self.alertAuthorizationStatus()
                }
            })
        } else if authorizationStatus == .authorized {
            self.startup(application)
        } else {
            log.info("访问照片授权状态非正常。")
            self.alertAuthorizationStatus()
        }

        return true
    }

    private func startup(_ application: UIApplication) {
        try! setupDatabase(application)

        ProfileManager.shared.load()
        
        DispatchQueue.main.async(execute: { () -> Void in
            try! AlbumManager.shared.load()
        })

        DispatchQueue.main.async(execute: { () -> Void in
            self.window = UIWindow(frame: UIScreen.main.bounds)
            if let window = self.window {
                window.backgroundColor = UIColor.white

                let tabBarController = TabBarController()
//                let navigationController = UINavigationController(rootViewController: tabBarController)
//                navigationController.isNavigationBarHidden = true
//                window.rootViewController = navigationController
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        })
    }

    private func setupDatabase(_ application: UIApplication) throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        dbConn = try AppDatabase.openDatabaseQueue(databaseURL.path)

        // Be a nice iOS citizen, and don't consume too much memory
        // See https://github.com/groue/GRDB.swift/#memory-management
        dbConn.setupMemoryManagement(in: application)
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
