import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

// Initialize secure storage
const secureStorage = FlutterSecureStorage();

// Key storage key identifier
const String encryptionKeyStorageKey = 'aes_encryption_key';

// Predefined key for demonstration (16 bytes for AES-128)
const String predefinedKey = 'dGhpc2lzYXNhZmVrZXkxMjM0NQ=='; // Base64 encoded "thisisasafekey12345"

Future<void> storeKey(String key) async {
  await secureStorage.write(key: encryptionKeyStorageKey, value: key);
}

Future<String?> retrieveKey() async {
  return await secureStorage.read(key: encryptionKeyStorageKey);
}

Future<String> generateAndStoreKey() async {
  final key = Key.fromSecureRandom(16); // 16 bytes for AES-128
  final keyString = base64UrlEncode(key.bytes);

  // Store the key in secure storage
  await storeKey(keyString);
  return keyString;
}

String encrypt(String plainText, String base64Key) {
  final key = Key(base64Url.decode(base64Key));
  final iv = IV.fromLength(16); // Initialization vector with 16 bytes
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

String decrypt(String encryptedText, String base64Key) {
  final key = Key(base64Url.decode(base64Key));
  final iv = IV.fromLength(16); // Must use the same IV as encryption
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
  return decrypted;
}
