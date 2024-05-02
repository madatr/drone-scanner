import 'dart:developer';

import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  Future<int> test() async {
    try {
      var ec = getP256();
      var privKey = PrivateKey.fromHex(ec,
          "D4F99A25F16565794AE0CE9BB43E2ACC6A344589462F135CD7FE6F30DE255F7B");
      var pubKey = PublicKey.fromHex(ec,
          "04402BBCACCA0497C5E4E9D98BE9619E21504490BEF00775DB5ED126E53BAE9AD787828C725732FFB7D05222EE9357CB7B826CD717C43DBA31EF9E4684D09D0F5C");
      var payload = "KU ZeroTrust UTM";
      var hashHex =
          "6054DD364D2EBECD46D62498BF993F0ABF1A38DF5305382986C530310F76C877";
      var signatureHex =
          "C31CD4E3A0EA3D9C307144B81FE32F453A945A56AD0E9731DA1C40F4E76891AA691BFB4BF256A181A61626BEF89FB83D186B73DFED84D372E2D96E5903CD4533";
      var hexPublickKey =
          "402BBCACCA0497C5E4E9D98BE9619E21504490BEF00775DB5ED126E53BAE9AD787828C725732FFB7D05222EE9357CB7B826CD717C43DBA31EF9E4684D09D0F5C";

      log("ESP private key: " + privKey.toHex());
      log("ESP public key: " + pubKey.toHex());
      log("Drt public key hex: " + privKey.publicKey.toHex());
      log("Drt public key compressed: " + privKey.publicKey.toCompressedHex());

      var hash = List<int>.generate(hashHex.length ~/ 2,
          (i) => int.parse(hashHex.substring(i * 2, i * 2 + 2), radix: 16));

      log("Trying to verify");
      var signature = Signature.fromCompactHex(signatureHex);

      bool vres = verify(pubKey, hash, signature);

      log(vres ? "Verified" : "Not verified");
    } catch (e) {
      log("ERROR: ${e.toString()}");
      return 1;
    }

    return 0;
  }

  void tester() async {
    // Simulating some asynchronous task
    setState(() {
      _isLoading = true;
    });

    var res = await test();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Button with Progress Indicator"),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  tester();
                },
                child: Text('Run Tester'),
              ),
      ),
    );
  }
}
