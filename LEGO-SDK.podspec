Pod::Spec.new do |s|
  s.name         = "LEGO-SDK"
  s.version      = "0.3.0"
  s.summary      = "LEGO-SDK is bridge via WebView and Native."
  s.description  = <<-DESC
                      LEGO-SDK is bridge via WebView and Native.
                      SDK Provides lots of APIs.
                   DESC
  s.homepage     = "http://code.yy.com/LEGO-SDK/LEGO-SDK-OC"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "PonyCui" => "cuis@vip.qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "http://code.yy.com/LEGO-SDK/LEGO-SDK-OC.git" }
  s.requires_arc = true
  s.subspec 'Core' do |core|
    core.source_files = 'SDK/Core/*.{h,m}', 'SDK/WebView/UIWebView/*.{h,m}', 'SDK/WebView/WKWebView/*.{h,m}'
    core.weak_framework = 'WebKit'
  end
  s.subspec 'AutoInject' do |auto|
    auto.source_files = 'SDK/WebView/AutoInject/*.{h,m}'
    auto.dependency 'LEGO-SDK/Core'
  end
  s.subspec 'API' do |api|
    api.dependency 'LEGO-SDK/Core'
    api.subspec 'Native' do |native|
      native.subspec 'Call' do |module|
        module.source_files = 'SDK/Modules/Native/Call/*.{h,m}'
      end
      native.subspec 'Check' do |module|
        module.source_files = 'SDK/Modules/Native/Check/*.{h,m}'
      end
      native.subspec 'DataModel' do |module|
        module.source_files = 'SDK/Modules/Native/DataModel/*.{h,m}'
      end
      native.subspec 'Device' do |module|
        module.source_files = 'SDK/Modules/Native/Device/*.{h,m}'
      end
      native.subspec 'FileManager' do |module|
        module.source_files = 'SDK/Modules/Native/FileManager/*.{h,m}'
      end
      native.subspec 'HTTPRequest' do |module|
        module.source_files = 'SDK/Modules/Native/HTTPRequest/*.{h,m}'
      end
      native.subspec 'Notification' do |module|
        module.source_files = 'SDK/Modules/Native/Notification/*.{h,m}'
      end
      native.subspec 'OpenURL' do |module|
        module.source_files = 'SDK/Modules/Native/OpenURL/*.{h,m}'
      end
      native.subspec 'Pasteboard' do |module|
        module.source_files = 'SDK/Modules/Native/Pasteboard/*.{h,m}'
      end
      native.subspec 'UserDefaults' do |module|
        module.source_files = 'SDK/Modules/Native/UserDefaults/*.{h,m}'
      end
    end
    api.subspec 'UI' do |ui|
      ui.subspec 'ActionSheet' do |module|
        module.source_files = 'SDK/Modules/UI/ActionSheet/*.{h,m}'
      end
      ui.subspec 'AlertView' do |module|
        module.source_files = 'SDK/Modules/UI/AlertView/*.{h,m}'
      end
      ui.subspec 'AppFrame' do |module|
        module.source_files = 'SDK/Modules/UI/AppFrame/*.{h,m}'
        module.dependency 'LEGO-SDK/API/UI/ViewController'
      end
      ui.subspec 'Bounce' do |module|
        module.source_files = 'SDK/Modules/UI/Bounce/*.{h,m}'
      end
      ui.subspec 'ImagePreviewer' do |module|
        module.source_files = 'SDK/Modules/UI/ImagePreviewer/*.{h,m}'
      end
      ui.subspec 'IndicatorView' do |module|
        module.source_files = 'SDK/Modules/UI/IndicatorView/*.{h,m}'
      end
      ui.subspec 'ModalController' do |module|
        module.source_files = 'SDK/Modules/UI/ModalController/*.{h,m}'
        module.dependency 'LEGO-SDK/API/UI/ViewController'
      end
      ui.subspec 'NavigationBar' do |module|
        module.source_files = 'SDK/Modules/UI/NavigationBar/*.{h,m}'
      end
      ui.subspec 'NavigationController' do |module|
        module.source_files = 'SDK/Modules/UI/NavigationController/*.{h,m}'
        module.dependency 'LEGO-SDK/API/UI/ViewController'
      end
      ui.subspec 'NavigationItem' do |module|
        module.source_files = 'SDK/Modules/UI/NavigationItem/*.{h,m}'
      end
      ui.subspec 'ProgressView' do |module|
        module.source_files = 'SDK/Modules/UI/ProgressView/*.{h,m}'
      end
      ui.subspec 'Refresh' do |module|
        module.source_files = 'SDK/Modules/UI/Refresh/*.{h,m}'
      end
      ui.subspec 'StatusBar' do |module|
        module.source_files = 'SDK/Modules/UI/StatusBar/*.{h,m}'
      end
      ui.subspec 'ViewController' do |module|
        module.source_files = 'SDK/Modules/UI/ViewController/*.{h,m}'
      end
    end
    api.subspec 'WebView' do |webview|
      webview.subspec 'Pack' do |pack|
        module.source_files = 'SDK/Modules/WebView/Pack/*.{h,m}'
        module.dependency 'GCDWebServer'
        module.dependency 'SSZipArchive'
        module.dependency 'CocoaSecurity'
      end 
    end
  end
end
