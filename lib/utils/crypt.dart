import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:steel_crypt/steel_crypt.dart';

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

String decryptRSA(String b64Msg, PrivateKey privateKey) {
  final Uint8List msg = base64.decode(b64Msg);
  final OAEPEncoding cipher = OAEPEncoding(RSAEngine());
  cipher.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  return String.fromCharCodes(cipher.process(msg));
}

String decryptAes(String b64Msg, String key) {
  final Uint8List msg = base64.decode(b64Msg);
  final AesCrypt aes = AesCrypt(key: key, padding: PaddingAES.none);
  return aes.gcm.decrypt(
      enc: base64.encode(msg.sublist(12, msg.length)),
      iv: base64.encode(msg.sublist(0, 12)));
}
