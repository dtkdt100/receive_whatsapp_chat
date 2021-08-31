/// The Share type of the received file (if someone export to the app something that it is not whatsapp chat).
/// A whatsapp chat will be marked as [ShareType.typeFile]
class ShareType {
  static const ShareType typePlainText = ShareType._internal("text/plain");
  static const ShareType typeImage = ShareType._internal("image/*");
  static const ShareType typeFile = ShareType._internal("*/*");

  static List<ShareType> values() {
    List<ShareType> values = <ShareType>[];
    values.add(typePlainText);
    values.add(typeImage);
    values.add(typeFile);
    return values;
  }

  final String _type;

  const ShareType._internal(this._type);

  static ShareType fromMimeType(String mimeType) {
    for (ShareType shareType in values()) {
      if (shareType.toString() == mimeType) {
        return shareType;
      }
    }
    return typeFile;
  }

  @override
  String toString() {
    return _type;
  }
}
