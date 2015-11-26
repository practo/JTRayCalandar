Pod::Spec.new do |s|
  s.name             = "JTCalendar+practo"
  s.version          = "2.1.7"
  s.summary          = "customizable calendar view for iOS from Practo."
  s.homepage         = "https://github.com/practo/JTRayCalandar"
  s.license          = { :type => 'MIT' }
  s.author           = { "Orta" => "kalyani.p@practo.com"}
  s.source           = { :git => "https://github.com/practo/JTRayCalandar.git", :tag => s.version }
 s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'JTCalendar/**/*'
 s.screenshots   = ["https://raw.githubusercontent.com/jonathantribouharet/JTCalendar/master/Screens/example.gif"]
end
