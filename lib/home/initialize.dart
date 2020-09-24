import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/services/push_notification.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

import 'appPage.dart';

class Initialize extends StatefulWidget {
  final bool isNewLogin;
  Initialize(this.isNewLogin);

  @override
  _InitializeState createState() => _InitializeState();
}

class _InitializeState extends State<Initialize> {
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    OTPAuth.initializeInfo().then((value) {
      setState(() {
        initialized = true;
        PushNotification.registerNotification();
      });
    });
    if (widget.isNewLogin)
      Future.delayed(Duration(seconds: 1)).then((value) {
        showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Column(
                          children: [
                            Image(
                              image:
                                  AssetImage("images/saksham_homeopathy.jpeg"),
                              height: 150,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: SingleChildScrollView(
                                  child: Text(
                                    '''Welcome to Saksham Homoeopathy app. If you are looking for an expert advice regarding your health or want to go for a quality Homoeopathic treatment ,you have arrived at right place.\n\n"Holistic,Scientitific Safe" is our motto.\nHomoeopathy is a proven nano Harmless Medicine for mind and body and is based on Nature’s law of healing.\nIt improves your immunity,the innate defence mechanism and gives you power to fight with pathogens. Our clinic comes out with  more than 95% success rate in improving quality of life of our patients. We are grateful to you for you arrived here. We are here to serve you with the safest, most scientific way of managing and treating diseases.\nHomoeopathy is the only method in the world where each and every medicine is proved on human beings and exact change in feelings of mind and body is recorded.''',
                                    style: TextStyle(
                                        color: AppColorPallete.textColor,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      });
  }

  @override
  Widget build(BuildContext context) {
    return initialized ? AppPage() : ConnectingPage();
  }
}
