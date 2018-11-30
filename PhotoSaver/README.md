#  <#Title#>


## TODO
1. 图片内容数据库序列化，使用Realm（https://realm.io/docs/swift/latest）
    https://developer.apple.com/icloud/documentation/data-storage/index.html
    https://github.com/realm/realm-cocoa
2. 


https://github.com/Akhilendra/photosAppiOS
https://www.youtube.com/watch?v=QS2mWk3fAWc
基础的Collection和Viewer实现

在线图标
https://icons8.cn/icon/set/cloud/ios

my-image.png     // for non-retina displays (Ex: 30x30 dpi)
my-image@2x.png  // for retina displays (Ex: 60x60 dpi)
my-image@3x.png  // for retina displays(plus editions) (Ex: 90x90 dpi)


https://appicon.co/#app-icon
http://appiconmaker.co/

实现Profile页面
实现云端页面
实现上传页面






ios APP监控
https://github.com/zixun/GodEye/blob/master/README_CN.md
https://github.com/Flipboard/FLEX

好库
https://github.com/xmartlabs?utf8=%E2%9C%93&q=&type=&language=swift


微信关联：
  https://open.weixin.qq.com/cgi-bin/appdetail?t=manage/detail&type=app&lang=zh_CN&token=8adccca0bba5e53eb3b9fee43cef52897c8cd4bc&appid=wx0c0aec22867494da
  dragonetail...

会员服务：
1、无限云空间、无限云安全
     阿里云主打99.9999云存储提供核心云存储，安全高效，无限空间；腾讯云、华为云、七牛云等多家云供应商提供交叉备份存储，空间、安全再升级。
2、多重加密，多重保障
    工业级非对称加密技术，独享云端加密机制和安全存储方案（RSA证书，用户ID加密后生成用户全局共享秘钥，针对一个文件生成一个临时秘钥，临时秘钥用共享秘钥加密后存储到文件文件头，用RSA加密过临时秘钥后作为秘钥加密文件正文，同时使用RSA实现用户认证增强）
3、自动备份
    连接WiFi自动备份照片
4、云端回收站
    长达30天删除照片保护（已删除照片占用用户空间，可自己设置，最低1天）
5、原图保存于空间压缩
    提供云端原图保留和缩略图生成（原图和缩略图分别占用空间）
6、即用即付、分段计价
    1G以内，30天免费试用，费率0元/G/天
    5G以内，会员费率0.06元/G/天（1元/G/月）（3元/3G/月）
    20G以内，会员费率0.03元/G/天（0.6元/G/月）（12元/20G/月）
    100G以上，会员费率0.015元/G/天（0.2元/G/月）（20元/100G/月）
    阿里云：     0.12元/GB/月    0.08元/GB/月    0.033/GB/月 （未含其他流量和处理费用）
    华为云：    0.0990元/GB/月    0.0800元/GB/月    0.0330元/GB/月

    500T * 0.12元/GB/月 = 60 000元
    每用户10G算，500 000 / 10 = 50000用户
    5万用户 * 5G平均 = 250000G * 0.5元/G月 = 12.5万，存储溢利约10万

    腾讯相册管家
    钻石套餐 50元 50G /月
    白金套餐 20元 20G /月
    VIP套餐 10元 3G /月  3000张照片


Profile画面：

    头像、昵称、容量、VIP会员类型
    自动备份（仅Wifi下自动备份、移动网络也自动备份、不自动备份）
    最近删除
    优惠券
    备份下载历史
    
    图片备份质量（原图，备份较慢，耗费流量；高质量（推荐）备份更快、画质不减）
    
    绑定安全手机号
    会员服务
    
    安全：
        相册锁
        手势密码
        导出导入安全证书
        隐私照片
        
    空间设置
        自动删除照片和视频
        保留最近照片和视频天数： 30天
        自动压缩本地照片和视频，上传原件在云端
        自动下载云端其他设备照片
        自动下载云端其他设备视频
    
    帮助与反馈
    向朋友推荐
    关于
    检查更新
    退出登录
    
    主要功能： 上传并压缩本地的图片，下载云端其他设备的图片到本地，原图在云端
    
    
    
    
