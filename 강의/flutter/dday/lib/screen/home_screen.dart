import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffa1dc),
      body: SafeArea(
        bottom: false,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          child: Column(
            children: [
              _Top(
                selectedDate: selectedDate,
                onPressed: onHeartPressed,
              ),

              /// 이미지
              _Bottom(),
            ],
          ),
        ),
      ),
    );
  }

  void onHeartPressed() {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            color: Colors.white,
            height: 300,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              dateOrder: DatePickerDateOrder.ymd,
              initialDateTime: selectedDate,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (DateTime date) {
                print(date);
                setState(() {
                  selectedDate = date;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class _Top extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPressed;

  const _Top({
    required this.selectedDate,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        child: Column(
          children: [
            Text(
              'U&I',
              style: textTheme.displayLarge,
            ),
            Text(
              '우리 처음 만난 날',
              style: textTheme.bodyLarge,
            ),
            Text(
              '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
              style: textTheme.bodyMedium,
            ),
            IconButton(
              onPressed: onPressed,
              icon: Icon(Icons.favorite),
              iconSize: 60,
              color: Colors.yellow,
            ),
            Text(
              'D+${now.difference(selectedDate).inDays + 1}',
              style: textTheme.displayMedium,
            )
          ],
        ),
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Image.asset(
          'asset/img/middle_image.png',
        ),
      ),
    );
  }
}
