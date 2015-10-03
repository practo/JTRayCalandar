Pod::Spec.new do |s|
  s.name             = "JTCalendar+practo"
  s.version          = "2.1.4"
  s.summary          = "customizable calendar view for iOS from Practo."
  s.homepage         = "https://github.com/practo/JTCalendar"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "Orta" => "kalyani.p@practo.com"}
  s.source           = { :git => "https://github.com/practo/JTCalendar.git", :tag => s.version }
  s.social_media_url = 'https://practo.com'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'JTCalendar/**/*'

  s.frameworks = 'UIKit', 'Foundation'
  s.module_name = 'Practo_Calendar'
end
