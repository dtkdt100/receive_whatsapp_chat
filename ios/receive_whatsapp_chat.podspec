#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint receive_whatsapp_chat.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'receive_whatsapp_chat'
  s.version          = '0.1.9'
  s.summary          = 'Receive exported chats from WhatsApp.'
  s.description      = <<-DESC
A flutter plugin that enables flutter apps to receive exported chats from WhatsApp.
                       DESC
  s.homepage         = 'https://github.com/dtkdt100/receive_whatsapp_chat'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Dolev Franco'
  s.source           = { :path => '.' }
  s.source_files = 'receive_whatsapp_chat/Sources/receive_whatsapp_chat/**/*.{h,m}'
  s.public_header_files = 'receive_whatsapp_chat/Sources/receive_whatsapp_chat/include/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
