import 'package:native_synchronization_temp/mailbox.dart';

import 'message.dart';
import 'process_in_isolate.dart';

extension MailBoxMessage on Mailbox {
  Future<void> postMessage(Message message) async {
    var tryPut = true;
    while (tryPut) {
      try {
        tryPut = false;
        // _logMessage('attempting to put message in mailbox $message');
        put(message.content);
        // _logMessage('attempting to put message in mailbox - success');
        // ignore: avoid_catching_errors
      } on StateError catch (e) {
        if (!isFull()) {
          isolateLogger(() => 'mailbox is full sleeping for a bit');
          tryPut = true;

          /// yeild and give the mailbox reader a chance to empty
          /// the mailbox.
          await Future.delayed(const Duration(seconds: 3), () {});
          isolateLogger(() => 'Mailbox: postMessage, retrying after sleep.');
        } else {
          isolateLogger(() => 'StateError on postMesage $e');
        }
      }
    }
  }
}
