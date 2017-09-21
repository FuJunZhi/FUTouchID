Pod::Spec.new do |s|
    s.name         = "FUTouchID"
    s.version      = "1.0.0"
    s.summary      = "FUTouchID"
    s.homepage     = "https://github.com/FuJunZhi/FUTouchID"
    s.license      = "MIT"
    s.authors      = {"fujunzhi" => "185476975@qq.com"}
    s.platform     = :ios, "7.0"
    s.source       = {:git => "https://github.com/FuJunZhi/FUTouchID.git", :tag => s.version}
    s.source_files = "FUTouchID/*.{h,m}"
    s.frameworks = "UIKit", "Foundation"
    s.requires_arc = true
end