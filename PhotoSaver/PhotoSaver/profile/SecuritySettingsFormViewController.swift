import UIKit
import Eureka

class SecuritySettingsFormViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "安全"

        form

            +++ Section(footer: "启用隐私相册，启用前需要密码验证；管理隐私相册；程序退出后自动关闭隐私相册启用选项。")
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "隐私相册"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.showAlert()
        }
            +++ Section("手势密码")
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "设置密码"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.setPassword()
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "验证密码"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.verifyPassword()
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "修改密码"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.modifyPassword()
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "删除密码"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.removePassword()
        }


            +++ Section(header: "安全证书管理",
                        footer: "安全证书用于您的数据加密、增强身份认证。您可以委托服务器保管您的安全证书，服务器将对您的证书进行加密保管保障安全，方便使用，详细请参考隐私政策；选择本地管理证书，服务器将不再保存您的证书，您需要妥善自行保管，建议导出证书进行第三方保存。")

        <<< ActionSheetRow<String>("安全证书管理") {
            $0.title = $0.tag
            $0.selectorTitle = "请选择安全证书的管理方式"
            $0.options = ["委托服务器管理", "自行管理"]
            $0.value = "委托服务器管理"
        }
            .onPresent { from, to in
                to.popoverPresentationController?.permittedArrowDirections = .up
        }

        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "安全证书导出"
            row.hidden = .function(["安全证书管理"], { form -> Bool in
                let row: RowOf<String>! = form.rowBy(tag: "安全证书管理")
                return row.value == "委托服务器管理"
            })
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.showAlert()
        }


    }


    func showAlert() {
        let alertController = UIAlertController(title: "OnCellSelection", message: "Button Row Action", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
    }

    func setPassword() {
        appLock.set(controller: self, success: { password in
            log.debug("OK")
        })
    }

    func verifyPassword() {
        appLock.verify(controller: self, success: {
            log.debug("OK")
        }, forget: {
            log.debug("forget")
        }, overrunTimes: {
            log.debug("overrunTimes")
        })
    }

    func modifyPassword() {
        appLock.modify(controller: self, success: {
            log.debug("OK")
        }, forget: {
            log.debug("forget")
        }, overrunTimes: {
            log.debug("overrunTimes")
        })
    }

    func removePassword() {
        appLock.removePassword()
    }
}



