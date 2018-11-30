import UIKit
import FLEX
import Eureka

class ProfileViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.title = "我"
        self.navigationItem.title = ""

        form

            +++ Section() {
                $0.header = HeaderFooterView<ProfileHeaderView>(HeaderFooterProvider.callback({ () -> ProfileHeaderView in
                    let view = ProfileHeaderView()
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                    view.addGestureRecognizer(tap)
                    view.isUserInteractionEnabled = true
                    
                    return view
                }))
        }

            +++ Section(header: "会员空间与备份设置", footer: "")
        <<< ButtonRow("会员") {
            $0.title = $0.tag
            $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return MemberSettingsFormViewController()
            }, onDismiss: { vc in
                let _ = vc.navigationController?.popViewController(animated: true)
            })
        }

        <<< ButtonRow("备份") {
            $0.title = $0.tag
            $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return BackupSettingsFormViewController()
            }, onDismiss: { vc in
                let _ = vc.navigationController?.popViewController(animated: true)
            })
        }

            +++ Section(header: "安全与操作设置", footer: "")
        <<< ButtonRow("安全") {
            $0.title = $0.tag
            $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return SecuritySettingsFormViewController()
            }, onDismiss: { vc in
                let _ = vc.navigationController?.popViewController(animated: true)
            })
        }
        <<< ButtonRow("设置") { row in
            row.title = row.tag
            row.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return SystemSettingsFormViewController()
            }, onDismiss: { vc in
                let _ = vc.navigationController?.popViewController(animated: true)
            })
        }

            +++ Section() {
                $0.footer = HeaderFooterView<ProfileFooterView>(.class)
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "退出登录"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.showAlert()
        }


            +++ Section()
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "FLEX工具箱"
        }
            .onCellSelection { (cell, row) in
                FLEXManager.shared().showExplorer()
        }

    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.show(ProfileSettingsFormViewController(), sender: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }


    func showAlert() {
        let alertController = UIAlertController(title: "OnCellSelection", message: "Button Row Action", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
    }

}

