import 'package:app_test_attendance/presentation/widgets/card_information_attendance.dart';
import 'package:app_test_attendance/utils/shared_pref.dart';
import 'package:app_test_attendance/utils/util_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:one_clock/one_clock.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final auth = LocalAuthentication();
  String authorized = " not authorized";

  String? _currentAddress;
  Position? _currentPosition;
  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      if (position.isMocked) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You use fake gps!',
              ),
            ),
          );
        }
      } else {
        _getAddressFromLatLng(position);
      }
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable the services',
            ),
          ),
        );
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.country}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.blue.shade600,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: SizedBox(
                          height: 20,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  'assets/avatar_male1.png',
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Arnan Abdiel Theopilus',
                                    style: TextStyle(
                                      fontSize: 20,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Management Development Spesialist IT',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: ColoredBox(color: Colors.purple),
                  ),
                ],
              ),
              Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: 300,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 2),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          DigitalClock(
                            isLive: true,
                            datetime: DateTime.now(),
                            textScaleFactor: 1.5,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            UtilHelper.formatDateNow(),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (SharedPref().clockIn.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sudah melakukan presensi',
                                    ),
                                  ),
                                );
                              } else {
                                final bool canAuthenticateWithBiometrics =
                                    await auth.canCheckBiometrics;
                                final bool canAuthenticate =
                                    canAuthenticateWithBiometrics ||
                                        await auth.isDeviceSupported();
                                final List<BiometricType> availableBiometrics =
                                    await auth.getAvailableBiometrics();
                                if (canAuthenticateWithBiometrics ||
                                    canAuthenticate ||
                                    availableBiometrics
                                        .contains(BiometricType.fingerprint)) {
                                  await _authenticate();
                                  if (authorized == "Authorized success") {
                                    if (SharedPref().clockIn.isEmpty) {
                                      SharedPref().clockIn =
                                          DateTime.now().toString();
                                      setState(() {});
                                    } else if (SharedPref().clockOut.isEmpty) {
                                      SharedPref().clockOut =
                                          DateTime.now().toString();
                                      setState(() {});
                                    }
                                  }
                                }
                              }
                            },
                            child: Container(
                              width: 160,
                              height: 160,
                              margin: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: <Color>[
                                    Colors.blue.shade400,
                                    Colors.purple.shade300
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Check In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(6),
                              ),
                              color: Colors.grey.shade300,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 20),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 240,
                                  child: Text(
                                    _currentAddress.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text: 'Lokasi tidak tepat? ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Perbarui lokasi?',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await _getCurrentPosition();
                                    },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey.shade400, thickness: 0.5),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CardInformationAttendance(
                                title: 'Check In',
                                icon: Icons.more_time_rounded,
                                time: SharedPref().clockIn.isEmpty
                                    ? '--:--'
                                    : UtilHelper.formatDateTime(
                                        UtilHelper.parseDateTime(
                                            SharedPref().clockIn),
                                      ),
                              ),
                              CardInformationAttendance(
                                title: 'Check Out',
                                icon: Icons.timer_off_outlined,
                                time: SharedPref().clockOut.isEmpty
                                    ? '--:--'
                                    : UtilHelper.formatDateTime(
                                        UtilHelper.parseDateTime(
                                          SharedPref().clockOut,
                                        ),
                                      ),
                              ),
                              CardInformationAttendance(
                                title: 'Total hrs',
                                icon: Icons.timelapse_sharp,
                                time: SharedPref().clockOut.isEmpty ||
                                        SharedPref().clockOut.isEmpty
                                    ? '--'
                                    : UtilHelper.getTotalHours(
                                        SharedPref().clockIn,
                                        SharedPref().clockOut,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              SharedPref().clearCache();
                              setState(() {});
                            },
                            child: const Text('Clear Cache'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: "Scan your finger to attendance",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      authorized =
          authenticated ? "Authorized success" : "Failed to authenticate";
      debugPrint(authorized);
    });
  }
}
