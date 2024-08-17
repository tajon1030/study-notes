import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraPosition initialPosition =
      CameraPosition(target: LatLng(37.5493, 127.0818), zoom: 15);
  late final GoogleMapController controller;
  bool choolCheckDone = false;
  bool canChoolcheck = false;
  final double okDistance = 100;

  checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      throw Exception('위치 기능을 활성화 해주세요');
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();
    // 기본거부상태 denied
    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();
    }
    if (checkedPermission != LocationPermission.always &&
        checkedPermission != LocationPermission.whileInUse) {
      throw Exception('위치 권한을 허가 해주세요');
    }
  }

  @override
  void initState() {
    super.initState();
    // 스트림에서 앱을 실행하고 종료될때까지 계속 값을 받을거기때문에 initState에서 한번만 리슨해줌
    Geolocator.getPositionStream().listen((event) {
      final start = LatLng(37.5493, 127.0818);
      final end = LatLng(event.latitude, event.longitude);
      final distance = Geolocator.distanceBetween(
          start.latitude, start.longitude, end.latitude, end.longitude);

      setState(() {
        if (distance > okDistance) {
          canChoolcheck = false;
        } else {
          canChoolcheck = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '오늘도 출근',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: myLocationPressed,
              icon: Icon(Icons.my_location),
              color: Colors.blue,
            )
          ],
        ),
        body: FutureBuilder(
          future: checkPermission(), // 어떤함수를 실행하고싶은지
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // future의 결과를 받을수있는곳 snapshot
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return Column(children: [
              Expanded(
                  flex: 2,
                  child: _GoogleMap(
                    initialCameraLocation: initialPosition,
                    onMapCreated: (GoogleMapController controller) {
                      this.controller = controller;
                    },
                    radius: okDistance,
                    canChoolCheck: canChoolcheck,
                  )),
              Expanded(
                child: _BottomChoolCheckButton(
                  canChoolCheck: canChoolcheck,
                  choolCheckDone: choolCheckDone,
                  choolCheckPressed: choolCheckPressed,
                ),
              )
            ]);
          },
        ));
  }

  choolCheckPressed() async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('출근하기'),
            content: Text('출근을 하시겠습니까?'),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    // dialog는 하나의 페이지로 인식을해서 pop을하면 dialog를 지울 수 있음
                  },
                  child: Text('취소')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('출근하기'),
              ),
            ],
          );
        });

    if (result) {
      setState(() {
        choolCheckDone = true;
      });
    }
  }

  myLocationPressed() async {
    final location = await Geolocator.getCurrentPosition();
    controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)));
  }
}

class _GoogleMap extends StatelessWidget {
  final CameraPosition initialCameraLocation;
  final MapCreatedCallback onMapCreated;
  final bool canChoolCheck;
  final double radius;

  const _GoogleMap({
    required this.initialCameraLocation,
    required this.onMapCreated,
    required this.canChoolCheck,
    required this.radius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraLocation,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onMapCreated: onMapCreated,
      markers: {
        Marker(
          markerId: MarkerId('123'),
          position: LatLng(37.5493, 127.0818),
        )
      },
      circles: {
        Circle(
          circleId: CircleId('inDistance'),
          center: LatLng(37.5493, 127.0818),
          radius: radius,
          fillColor: canChoolCheck
              ? Colors.blue.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
          strokeColor: canChoolCheck ? Colors.blue : Colors.red,
          strokeWidth: 1,
        )
      },
    );
  }
}

class _BottomChoolCheckButton extends StatelessWidget {
  final bool choolCheckDone;
  final bool canChoolCheck;
  final VoidCallback choolCheckPressed;

  const _BottomChoolCheckButton({
    required this.canChoolCheck,
    required this.choolCheckDone,
    required this.choolCheckPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          choolCheckDone ? Icons.check : Icons.timelapse_outlined,
          color: choolCheckDone ? Colors.green : Colors.blue,
        ),
        SizedBox(
          height: 16,
        ),
        if (!choolCheckDone && canChoolCheck)
          OutlinedButton(
            onPressed: choolCheckPressed,
            child: Text('출근하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          )
      ],
    );
  }
}
