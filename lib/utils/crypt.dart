import 'dart:convert';

import 'package:pointycastle/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

RsaKeyHelper helper = RsaKeyHelper();
Codec<String, String> b64 = utf8.fuse(base64);

class KeyPair {
  KeyPair(this._publicKey, this._privateKey);

  final dynamic _publicKey;
  final dynamic _privateKey;

  PublicKey get publicKey {
    if (_publicKey.runtimeType == String) {
      return b64StringToPublicKey(_publicKey);
    }
    return _publicKey;
  }

  PrivateKey get privateKey {
    if (_privateKey.runtimeType == String) {
      return b64StringToPrivateKey(_privateKey);
    }
    return _privateKey;
  }

  String get b64PublicKey {
    return publicKeyToB64String(publicKey);
  }

  String get b64PrivateKey {
    return privateKeyToB64String(privateKey);
  }
}

Future<KeyPair> getRSAKeyPair() async {
  final AsymmetricKeyPair<PublicKey, PrivateKey> keys =
      await helper.computeRSAKeyPair(helper.getSecureRandom());
  return KeyPair(keys.publicKey, keys.privateKey);
}

String publicKeyToB64String(PublicKey key) {
  return b64.encode(helper.encodePublicKeyToPemPKCS1(key));
}

String privateKeyToB64String(PrivateKey key) {
  return b64.encode(helper.encodePrivateKeyToPemPKCS1(key));
}

PublicKey b64StringToPublicKey(String b64PublicKey) {
  final String publicKey = b64.decode(b64PublicKey);
  return helper.parsePublicKeyFromPem(publicKey);
}

PrivateKey b64StringToPrivateKey(String b64PrivateKey) {
  final String privateKey = b64.decode(b64PrivateKey);
  return helper.parsePrivateKeyFromPem(privateKey);
}

String decryptString(String b64Str, PrivateKey key) {
  final String cipherText = b64.decode(b64Str);
  return decrypt(cipherText, key);
}
