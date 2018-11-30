import UIKit
import Eureka

class ProfileSettingsFormViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "个人信息"

        let profileManager = ProfileManager.shared
        let profile = ProfileManager.shared.profile

        form

            +++ Section("基本信息")

        <<< ImageRow() { row in
            row.title = "头像"
            row.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
            row.allowEditor = true
            row.clearAction = .yes(style: UIAlertAction.Style.destructive)
            let startTime = CACurrentMediaTime()
            FileUtils.loadImage(profile.profilePhoto) { uiImage in
                row.value = uiImage
                row.updateCell()
                log.debug("加载图片：\(lround((CACurrentMediaTime() - startTime) * 1000))ms")
            }
        }.onChange({ (row) in
            profile.profilePhoto = "images/profile.jpg"
            profileManager.markChanged()

            FileUtils.saveImage(row.value, profile.profilePhoto)

            //通知主设置页更新头像
            eventBus.triggerProfileChanged()
        })

        <<< TextRow() { row in
            row.title = "昵称"
            row.placeholder = "微笑卡卡西"
            row.value = profile.nickname
        }.onChange({ (row) in
            profile.nickname = row.value
            profileManager.markChanged()

            //通知主设置页更新昵称
            eventBus.triggerProfileChanged()
        })

        <<< PickerInputRow<String>("性别") { row in
            row.title = "性别"
            row.options = ["男", "女"]
            row.value = profile.gender
        }.onChange({ (row) in
            profile.gender = row.value!
            profileManager.markChanged()
        })

            +++ Section("账号信息")
        <<< PhoneRow() { row in
            row.title = "手机号码"
            row.placeholder = "19912345678"
            row.value = profile.mobile
        }.onChange({ (row) in
            profile.mobile = row.value
            profileManager.markChanged()
        })

        <<< LabelRow () {
            $0.title = "微信绑定"
            $0.value = "未绑定"
        }.onCellSelection { [weak self] (cell, row) in
            self?.showAlert()
            //Model弹出窗口，根据结果更新当前Row
            row.value = "已绑定（微笑卡卡西）"
            //row.reload() // or row.updateCell()
        }
        <<< LabelRow () {
            $0.title = "支付宝绑定"
            $0.value = "未绑定"
        }.onCellSelection { [weak self] (cell, row) in
            self?.showAlert()
            //Model弹出窗口，根据结果更新当前Row
            row.value = "已绑定（微笑卡卡西）"
            //row.reload() // or row.updateCell()
        }

            +++ Section()
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "更换手机号"
            row.disabled = true
        }
    }


    func showAlert() {
        let alertController = UIAlertController(title: "OnCellSelection", message: "Button Row Action", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil {
            ProfileManager.shared.save()
        }
    }
}



