## 0.1.9

### Fixes

* Fix apps failing to build: replace the broken `uri_to_file_new` dependency with a built-in Android method
* Forward the read permission for the shared chat explicitly (required from Android 18)
* Recognize WhatsApp's newer `export_chat_folder` Android uri in `isWhatsAppChatUrl`
* iOS: accept shared chat paths without the `file://` scheme (`receive_sharing_intent` strips it)
* iOS: don't percent-decode the already-decoded path (failed on chat names containing `%`)
* Fix a crash on very short messages (only the leading U+200E mark is stripped now)
* Attachment lines that start with U+200E now get a `dateTime`
* A line that fails to parse is skipped instead of failing the whole chat
* Throw a `FormatException` instead of a `RangeError` for unrecognized chat formats

### Platform

* Add Swift Package Manager support on iOS (CocoaPods still supported)
* Remove legacy Kotlin Gradle configuration (Android plugin is Java-only)

### Logging

* Add debug-only error logging (prefixed `[receive_whatsapp_chat]`) for failed shares, unzip, missing chat file and unparsed chat formats; chat content is masked in logs
* Stop logging chat names and shared content

### Other

* Fix static analysis issues
* Redesigned example app with a sample chat, chat stats and a message view
* Example iOS Share Extension now uses `RSIShareViewController` from `receive_sharing_intent`
* README: simpler, up-to-date setup instructions

## 0.1.8

* Reformat dart files

## 0.1.7

* Version update (dart sdk, flutter sdk, kotlin, gradle)
* Example update
* Dependencies update

## 0.1.5

* Fix bug with media export on Android (newer WhatsApp version)
* Remove support for "export chat with media" because of the change in the WhatsApp export format.  
  Will be added again in the future.

## 0.1.4

* Version update (dart sdk, flutter sdk, kotlin, gradle)

## 0.1.2

* Add the option to export chat with media (currently only images and Android only)
* Bug fixed

## 0.1.1

* Added iOS support!
* Added indexesPerMember in ChatContent

## 0.0.13

* Support for Portuguese language

## 0.0.12

* Recognize now also the dates 12.2.22 and not only 12.2.2022

## 0.0.11

* Added the == operator to all moudels
* Fix messages per person issues

## 0.0.10

* Support for different languages

## 0.0.9

* Recognize now also the dates 12.2.2022 and not only 12/2/2022

## 0.0.8

* Recognize now also the time 9:46 and not only 09:46

## 0.0.7

* Bug fixed

## 0.0.5

* Fix date issues

## 0.0.4

* Fix cutting off messages after colon

## 0.0.3

* Support Android 12

## 0.0.2

* Increase score on pub.dev

## 0.0.1

* Initial commit
