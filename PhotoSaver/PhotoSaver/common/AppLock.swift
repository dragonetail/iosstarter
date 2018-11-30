import GesturePassword

let appLock = AppLock.shared

class AppLock {

    static let shared = AppLock()

    private init() {
        LockCenter.passwordKeySuffix = "photoSaver"

        //        LockCenter.usingKeychain = true
        //        LockCenter.lineWidth = 2
        //        LockCenter.lineWarnColor = .blue
    }

    func set(controller: UIViewController, success: ((String) -> ())? = nil) {
        if hasPassword {
            log.debug("密码已设置")
            log.debug("🍀🍀🍀 \(password) 🍀🍀🍀")
            success?(password)
        } else {
            showSetPattern(in: controller).successHandle = {
                LockCenter.set($0)
                success?(self.password)
            }
        }
    }

    func verify(controller: UIViewController, success: (() -> ())? = nil, forget: (() -> ())? = nil, overrunTimes: (() -> ())? = nil) {
        guard hasPassword else {
            log.debug("❌❌❌ 还没有设置密码 ❌❌❌")
            return
        }

        log.debug("密码已设置")
        log.debug("🍀🍀🍀 \(password) 🍀🍀🍀")
        
        if errorTimes <= 0 {
            log.debug("密码尝试已超限")
            overrunTimes?()
            return
        }
        
        showVerifyPattern(in: controller).successHandle {
            $0.dismiss()
            success?()
        }.overTimesHandle {
            LockCenter.removePassword()
            $0.dismiss()
            overrunTimes?()
            //assertionFailure("你必须做错误超限后的处理")
        }.forgetHandle {
            $0.dismiss()
            forget?()
            //assertionFailure("忘记密码，请做相应处理")
        }
    }

    func modify(controller: UIViewController, success: (() -> ())? = nil, forget: (() -> ())? = nil, overrunTimes: (() -> ())? = nil) {
        guard hasPassword else {
            log.debug("❌❌❌ 还没有设置密码 ❌❌❌")
            return
        }

        log.debug("密码已设置")
        log.debug("🍀🍀🍀 \(password) 🍀🍀🍀")
        
        if errorTimes <= 0 {
            log.debug("密码尝试已超限")
            overrunTimes?()
            return
        }
        
        showModifyPattern(in: controller).forgetHandle { _ in
            forget?()
        }.overTimesHandle { _ in
            overrunTimes?()
        }.resetSuccessHandle {
            log.debug("🍀🍀🍀 \($0) 🍀🍀🍀")
            success?()
        }
    }

    var hasPassword: Bool {
        return LockCenter.hasPassword()
    }

    var password: String {
        return LockCenter.password() ?? ""
    }
    
    var errorTimes: Int {
        return LockCenter.errorTimes()
    }

    func removePassword() {
        LockCenter.removePassword()
    }
}
