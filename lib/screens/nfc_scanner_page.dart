import 'dart:io';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/screens/bewerages_page/bewerages_page.dart';
import 'package:tech_festival/widgets/toast.dart';

class NfcScannerPage extends StatefulWidget {
  const NfcScannerPage({super.key});

  @override
  State<NfcScannerPage> createState() => _NfcScannerPageState();
}

class _NfcScannerPageState extends State<NfcScannerPage> {
  bool _nfcSessionStarted = false;
  bool? _isAvailable;

  String? nfcSerialNumber;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isAvailable = await _checkNfc();

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _isAvailable == null
                  ? const CircularProgressIndicator(
                      size: 48,
                    )
                  : _isAvailable == false
                      ? const Text('Please enable NFC from settings.')
                      : PrimaryButton(
                          onPressed: _nfcSessionStarted
                              ? _stopNfcSession
                              : _startNfcSession,
                          density: ButtonDensity.icon,
                          child: Text(
                              _nfcSessionStarted ? 'Stop NFC' : 'Scan NFC'),
                        ).p(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkNfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    debugPrint('isAvailable $isAvailable');
    return isAvailable;
  }

  void _startNfcSession() async {
    try {
      NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          nfcSerialNumber = '';
          if (Platform.isAndroid) {
            NfcAAndroid? androidTag = NfcAAndroid.from(tag);

            final uidHex = androidTag?.tag.id
                .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
                .join(':');
            nfcSerialNumber = uidHex;
            showToast(
              context: context,
              showDuration: const Duration(seconds: 1),
              builder: (context, overlay) {
                return buildToast(
                  context,
                  overlay,
                  title: 'Амжилттай',
                  subtitle: uidHex ?? 'Empty',
                );
              },
              location: ToastLocation.topCenter,
            );
          }

          if (Platform.isIOS) {
            var iosTag = MiFareIos.from(tag);

            final uidHex = iosTag?.identifier
                .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
                .join(':');
            nfcSerialNumber = uidHex;
            if (iosTag != null) {
              debugPrint('iOS NDEF additionalData: $uidHex');
            } else {
              debugPrint('iOS tag is not NDEF');
            }

            showToast(
              context: context,
              showDuration: const Duration(seconds: 1),
              builder: (context, overlay) {
                return buildToast(
                  context,
                  overlay,
                  title: 'Амжилттай',
                  subtitle: uidHex.toString(),
                );
              },
              location: ToastLocation.topCenter,
            );
          }
          _stopNfcSession();
          debugPrint('serial number $nfcSerialNumber');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BeweragesPage(
                tag: nfcSerialNumber!,
              ),
            ),
          );
        },
        onSessionErrorIos: (p0) async {
          showToast(
            context: context,
            builder: (context, overlay) {
              return buildToast(
                context,
                overlay,
                title: 'Алдаа гарлаа',
                subtitle: p0.message,
              );
            },
            location: ToastLocation.topCenter,
          );
          debugPrint('onSessonErrorIos ${p0.code} ${p0.message}');
          _stopNfcSession();
        },
      );
      setState(() {
        _nfcSessionStarted = !_nfcSessionStarted;
      });
    } catch (e) {
      setState(() {
        _nfcSessionStarted = false;
      });
      debugPrint(e.toString());
    }
  }

  void _stopNfcSession() async {
    await NfcManager.instance.stopSession();
    setState(() {
      _nfcSessionStarted = !_nfcSessionStarted;
    });
  }
}
