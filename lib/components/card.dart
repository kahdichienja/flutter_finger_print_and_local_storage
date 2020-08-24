import 'package:flutter/material.dart';
import 'package:sign_in_flutter/config/strings.dart';
import '../config/colors.dart';
import '../config/size.dart';

class BankCard extends StatefulWidget {
  @override
  _BankCardState createState() => _BankCardState();
}

class _BankCardState extends State<BankCard> {
  String name = '';
  String cvc = '';
  String cardno = '';
  String exp = '';
  @override
  void initState() {

    super.initState();
    cards.forEach((e) => {
      cardno = e['cardno'],
      cvc= e['cvc'],
      name = e['name'],
      exp = e['exp']
      });
  }
  @override
  Widget build(BuildContext context) {
    var height = SizeConfig.getHeight(context);
    var width = SizeConfig.getWidth(context);
    double fontSize(double size) {
      return size * width / 414;
    }
    return Container(
      padding:EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 20),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Container(
                alignment: Alignment.topLeft,
                width: width / 2.5,
                child: Image.asset(
                  "assets/mastercardlogo.png",
                  fit: BoxFit.fill,
                )),
          ),
          Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height: height / 10,
                width: width / 1.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "**** **** **** ",
                          style: TextStyle(
                              fontSize: fontSize(20),
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '0894',
                          style: TextStyle(
                              fontSize: fontSize(30),
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Text(
                      "Visa Card".toUpperCase(),
                      style: TextStyle(
                          fontSize: fontSize(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    )
                  ],
                ),
              )),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              alignment: Alignment.topRight,
              width: width / 6,
              height: height / 16,
              child: Column(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text('Expire: $exp'.toUpperCase(),textAlign: TextAlign.center,),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  boxShadow: AppColors.neumorpShadow,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              alignment: Alignment.bottomRight,
              width: width / 6,
              height: height / 16,
              child: Column(
                children: <Widget>[
                  Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                    "CVC: $cvc ",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, ),
                  ),
                      ))
                ],
              ),
              decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  boxShadow: AppColors.neumorpShadow,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
