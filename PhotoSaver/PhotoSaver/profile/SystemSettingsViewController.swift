import UIKit
import Eureka

class SystemSettingsFormViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "设置"

        form

            +++ Section()
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "帮助与反馈"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.showAlert()
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "向朋友推荐"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.showAlert()
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "关于"
        }
            .onCellSelection { [weak self] (cell, row) in
                self?.showAlert()
        }
        <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "检查更新"
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

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil {
            print("Back Button pressed.")
        }

    }

//    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
//        (self.navigationController as? CommonNavigationViewController)?.onDismissCallback?(self)
//    }

}



