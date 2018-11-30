import UIKit
import Eureka

class BackupSettingsFormViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "备份"

        form
            +++ Section(footer: "自动备份需要后台运行权限。")
        <<< PushRow<String>() {
            $0.title = "自动备份"
            $0.options = ["仅WiFi下自动备份", "移动网络下也自动备份", "手动备份"]
            $0.selectorTitle = "自动备份"
            $0.value = $0.options?.first
        }

            +++ Section(footer: "推荐原图备份，云端和本地保存缩略图，加速显示，可根据需要手工或自动加载原图显示。注意，云端保存缩略图会多占用约5%的空间，但会加快浏览速度，提升使用体验。云端高质量备份会节省约40%的空间，能最大程度保持画质不减。")
        <<< PushRow<String>() {
            $0.title = "图片备份质量"
            $0.options = ["原图", "高质量"]
            $0.selectorTitle = "图片备份质量"
            $0.value = $0.options?.first
        }
        <<< SwitchRow() {
            $0.title = "云端保存缩略图"
            $0.value = true
        }
        <<< SwitchRow() {
            $0.title = "本地使用缩略图节省空间"
            $0.value = true
        }
        <<< SwitchRow() {
            $0.title = "大图预览自动加载原图"
            $0.value = true
        }

            +++ Section(footer: "未备份照片和视频不会自动删除。")
        <<< SwitchRow("AutoErasure") {
            $0.title = "自动删除已备份照片和视频"
            $0.value = false
        }
        <<< StepperRow() {
            $0.title = "保留最近照片和视频天数"
            $0.value = 90
            $0.disabled = Eureka.Condition.function(["AutoErasure"], { (form) -> Bool in
                let row: SwitchRow! = form.rowBy(tag: "AutoErasure")
                return row.value ?? false
            })
        }.cellSetup({ (cell, row) in
            cell.stepper.minimumValue = 30
            cell.stepper.maximumValue = 365 * 3
            cell.stepper.stepValue = 10

            row.displayValueFor = { value in
                guard let value = value else { return nil }
                return String(Int(value))
            }
        })


            +++ Section(footer: "照片优先下载缩略图。")
        <<< SwitchRow() {
            $0.title = "自动下载云端其他设备照片"
            $0.value = false
        }

        <<< SwitchRow() {
            $0.title = "自动下载云端其他设备视频"
            $0.value = false
        }
    }
}



