import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/core/utils/secure_storage.dart';
import 'package:tech_festival/core/utils/shared_pref.dart';
import 'package:tech_festival/screens/auth/login_page.dart';
import 'package:tech_festival/screens/bewerages_page/bewerages_page.dart';
import 'package:tech_festival/screens/nfc_scanner/bloc/nfc_scanner_bloc.dart';
import 'package:tech_festival/screens/nfc_scanner/bloc/nfc_scanner_event.dart';
import 'package:tech_festival/screens/nfc_scanner/bloc/nfc_scanner_state.dart';
import 'package:tech_festival/widgets/toast.dart';

class NfcScannerPage extends StatefulWidget {
  const NfcScannerPage({super.key});

  @override
  State<NfcScannerPage> createState() => _NfcScannerPageState();
}

class _NfcScannerPageState extends State<NfcScannerPage> {
  final NfcScannerBloc _bloc = NfcScannerBloc();
  bool _nfcSessionStarted = false;
  bool? _isAvailable;

  String? nfcSerialNumber;

  bool _isAdmin = false;

  bool _nfcProccessing = false;
  bool _isRegisterScanning = false;

  @override
  void initState() {
    _isAdmin = SharedPref.getRoleCode() == 'admin';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isAvailable = await _checkNfc();

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NfcScannerBloc>(
      create: (_) => _bloc,
      child: BlocListener<NfcScannerBloc, NfcScannerState>(
        listener: _listener,
        child: BlocBuilder<NfcScannerBloc, NfcScannerState>(
          builder: _builder,
        ),
      ),
    );
  }

  void _listener(BuildContext context, NfcScannerState state) {
    if (state is NfcRegisterSuccess) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return buildToast(
            context,
            overlay,
            title: 'Амжилттай',
            subtitle: 'Tag амжилттай бүртгэлээ',
          );
        },
        location: ToastLocation.topCenter,
      );
      _stopNfcSession();
    } else if (state is NfcRegisterError) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return buildToast(
            context,
            overlay,
            title: 'Алдаа гарлаа',
            subtitle: state.message,
          );
        },
        location: ToastLocation.topCenter,
      );
      _stopNfcSession();
    }
  }

  Widget _builder(BuildContext context, NfcScannerState state) {
    return Scaffold(
      child: state is NfcRegisterLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  size: 48,
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Gap(16),
                  _isAvailable == null
                      ? const CircularProgressIndicator(
                          size: 48,
                        )
                      : _isAvailable == false
                          ? const Text('Please enable NFC from settings.')
                          : Column(
                              children: [
                                if (!_isRegisterScanning || !_nfcSessionStarted)
                                  PrimaryButton(
                                    onPressed: () {
                                      _isRegisterScanning = false;
                                      _nfcSessionStarted
                                          ? _stopNfcSession()
                                          : _startNfcSession(isRegister: false);
                                    },
                                    density: ButtonDensity.icon,
                                    child: Text(_nfcSessionStarted
                                        ? 'Stop scan NFC'
                                        : 'Start scan NFC'),
                                  ).p(),
                                if (_isAdmin) const Gap(16),
                                if (_isAdmin && _isRegisterScanning ||
                                    !_nfcSessionStarted)
                                  PrimaryButton(
                                    onPressed: () {
                                      _isRegisterScanning = true;
                                      _nfcSessionStarted
                                          ? _stopNfcSession()
                                          : _startNfcSession(isRegister: true);
                                    },
                                    density: ButtonDensity.icon,
                                    child: Text(_nfcSessionStarted
                                        ? 'Stop scanning NFC'
                                        : 'Register NFC'),
                                  ).p(),
                                const Gap(16),
                              ],
                            ),
                  PrimaryButton(
                    onPressed: () {
                      SecStorage().delete(key: SecStorageKeys.accessToken);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    density: ButtonDensity.icon,
                    child: const Text('Log out'),
                  ).p(),
                ],
              ),
            ),
    );
  }

  Future<bool> _checkNfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    debugPrint('isAvailable $isAvailable');
    return isAvailable;
  }

  void _startNfcSession({bool isRegister = false}) async {
    try {
      NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          if (_nfcProccessing) {
            return;
          }
          nfcSerialNumber = '';
          if (Platform.isAndroid) {
            NfcAAndroid? androidTag = NfcAAndroid.from(tag);

            final uidHex = androidTag?.tag.id
                .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
                .join(':');
            nfcSerialNumber = uidHex;
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
            _stopNfcSession();
          }

          showToast(
            context: context,
            showDuration: const Duration(seconds: 1),
            builder: (context, overlay) {
              return buildToast(
                context,
                overlay,
                title: 'Амжилттай',
                subtitle: nfcSerialNumber.toString(),
              );
            },
            location: ToastLocation.topCenter,
          );

          if (isRegister) {
            _writeToTag(tag);
            _bloc.add(RegisterNfc(serialNumber: nfcSerialNumber ?? ''));
            return;
          }
          debugPrint('serial number $nfcSerialNumber');
          if (nfcSerialNumber != null) {
            _nfcProccessing = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BeweragesPage(
                  tag: nfcSerialNumber!,
                ),
              ),
            ).then((_) {
              _nfcProccessing = false;
            });
          }
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
      await NfcManager.instance.stopSession();
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

  void _writeToTag(NfcTag tag) async {
    try {
      NdefAndroid? ndefTag = NdefAndroid.from(tag);

      if (ndefTag?.isWritable == false) {
        return;
      }

      final ndefMessage = NdefMessage(
        records: [
          NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList(utf8.encode('T')),
            identifier: Uint8List(0),
            payload: _createTextRecordPayload('techpack', languageCode: 'en'),
          ),
        ],
      );

      await ndefTag?.writeNdefMessage(ndefMessage);
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  Uint8List _createTextRecordPayload(String text,
      {String languageCode = 'en'}) {
    final languageCodeBytes = utf8.encode(languageCode);
    final textBytes = utf8.encode(text);

    // Status byte: bit7 = 0 means UTF-8, lower 6 bits = length of language code
    final status = languageCodeBytes.length & 0x3F;

    final payloadBytes = <int>[status, ...languageCodeBytes, ...textBytes];
    return Uint8List.fromList(payloadBytes);
  }
}
