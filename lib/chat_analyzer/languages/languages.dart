import 'dart:io';

/// When WhatsApp export a chat it will export the special messages in different languages.
/// I added support for those languages. If you have a language that is not supported,
/// please sent it to me and I will add it. Thanks!

class Languages {
  static const List<String> youDeletedThisMessage = [
    'You deleted this message', // English
    'מחקת את ההודעה הזו', // Hebrew
    'Вы удалили это сообщение', // Russian
    'Vous avez supprimé ce message', // French
    'Hai eliminato questo messaggio', // Italian
    'Você eliminou este mensagem', // Portuguese
    'Borraste este mensaje', // Spanish
    'Διαγράψατε αυτό το μήνυμα', // Greek
    'Ви видали це повідомлення', // Ukrainian
    'Sie haben diese Nachricht gelöscht', // German
    'أنت حذفت هذه الرسالة', // Arabic
  ];

  static const List<String> mediaOmitted = [
    '<Media omitted>', // English
    '<המדיה הוסרה>', // Hebrew
    '<המדיה לא נכללה>', // Hebrew
    '<Без медиафайлов>', // Russian
    '<Média manquante>', // French
    '<Media mancante>', // Italian
    '<Mídia omitida>', // Portuguese
    '<Media omitida>', // Spanish
    '<Αποχρεωτική παραλαβή μέσων>', // Greek
    '<Медіа відсутня>', // Ukrainian
    '<Medien fehlen>', // German
    '<ملفات مفقودة>', // Arabic
  ];

  static const List<String> thisMessageWasDeleted = [
    'This message was deleted', // English
    'הודעה זו נמחקה', // Hebrew
    'Данное сообщение удалено', // Russian
    'Ce message a été supprimé', // French
    'Questo messaggio è stato cancellato', // Italian
    'Este mensagem foi apagado', // Portuguese
    'Este mensagem foi apagado', // Spanish
    'Αυτό το μήνυμα διαγράφηκε', // Greek
    'Це повідомлення видалено', // Ukrainian
    'Diese Nachricht wurde gelöscht', // German
    'هذه الرسالة تم حذفها', // Arabic
  ];

  static bool hasMatchForAll(String text) {
    /// In iOS the spacial messages it a little bit different
    if (Platform.isIOS) {
      text = text.replaceAll('.', '');
      text = text.replaceRange(0, 1, '');
    }
    return hasMatch(text, youDeletedThisMessage) ||
        hasMatch(text, mediaOmitted) ||
        hasMatch(text, thisMessageWasDeleted);
  }

  static bool hasMatch(String text, List<String> list) {
    for (String item in list) {
      if (text == item) {
        return true;
      }
    }
    return false;
  }
}
