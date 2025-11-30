import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  // Check if NFC is available
  Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  // --- READ UID ONLY (The robust method) ---
  void startSession({
    required Function(String) onTagRead,
    required Function(String) onError,
  }) {
    NfcManager.instance
        .startSession(
          // We look for everything, but we only care about the ID
          pollingOptions: {
            NfcPollingOption.iso14443,
            NfcPollingOption.iso15693,
            NfcPollingOption.iso18092,
          },
          onDiscovered: (NfcTag tag) async {
            try {
              // Just get the Physical UID (Serial Number)
              final tagData = Map<String, dynamic>.from(tag.data as Map);
              String? tagId = _extractTagId(tagData);

              if (tagId != null) {
                // Success! We found the ID (e.g. 04:AE:32:11)
                onTagRead(tagId);
                NfcManager.instance.stopSession();
              } else {
                NfcManager.instance.stopSession();
                onError("Could not read Card ID");
              }
            } catch (e) {
              NfcManager.instance.stopSession();
              onError(e.toString());
            }
          },
        )
        .catchError((e) {
          onError(e.toString());
        });
  }

  void stopSession() {
    NfcManager.instance.stopSession();
  }

  // --- HELPER: Extract the Serial Number ---
  String? _extractTagId(Map<String, dynamic> data) {
    List<int>? idBytes;

    // Check all standard standards for the ID field
    if (data.containsKey('nfcA')) {
      idBytes = List<int>.from(data['nfcA']['identifier']);
    } else if (data.containsKey('mifareClassic')) {
      idBytes = List<int>.from(data['mifareClassic']['identifier']);
    } else if (data.containsKey('isodep')) {
      idBytes = List<int>.from(data['isodep']['identifier']);
    } else if (data.containsKey('mifare')) {
      idBytes = List<int>.from(data['mifare']['identifier']);
    } else if (data.containsKey('nfcB')) {
      idBytes = List<int>.from(data['nfcB']['identifier']);
    } else if (data.containsKey('nfcF')) {
      idBytes = List<int>.from(data['nfcF']['identifier']);
    } else if (data.containsKey('nfcV')) {
      idBytes = List<int>.from(data['nfcV']['identifier']);
    }

    if (idBytes == null) return null;

    // Convert numbers to Hex String (e.g., A1:B2:C3:D4)
    return idBytes
        .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }
}
