import UIKit
import Eureka

class MemberSettingsFormViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "会员"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil) //#selector(addTapped)
        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItems = [add, play]
        
        
        form +++
            
            Section() {
                $0.header = HeaderFooterView<ProfileHeaderView>(.class)
            }
            
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
}



