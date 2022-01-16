import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:interview/screens/weather.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _mobileNumberController = TextEditingController();

  final _otpController = TextEditingController();

  var _showOtpInput = false;
  var _isLoading=false;

  String verId = "";
  AuthCredential? _myAuthCredential;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Demo"),backgroundColor: Colors.teal,),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _mobileNumberController,
                decoration: const InputDecoration(
                  hintText: "Enter Mobile Number",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal,width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal,width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _showOtpInput?TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  hintText: "Enter OTP",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal,width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal,width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ):const SizedBox(),
              const SizedBox(height: 12),
              _isLoading?const CircularProgressIndicator(color: Colors.teal,):Center(
                child: SizedBox(
                  width: 280,
                  child: ElevatedButton(
                    onPressed: () {
                      var mobileNumber = _mobileNumberController.text.toString().trim();
                      var otp = _otpController.text.toString().trim();

                      if (mobileNumber.length<10|| !RegExp(r"[^a-zA-Z]",
                          caseSensitive: false)
                          .hasMatch(mobileNumber)){
                        Get.snackbar(
                          "Invalid Mobile Number",
                          "Enter Valid Mobile Number",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.teal,
                        );
                        return;
                      }

                      _showOtpInput?authenticate("+91"+mobileNumber,otp):sendOtp("+91"+mobileNumber);

                      setState(() {
                        _showOtpInput=true;
                      });
                    },
                    child: Text(
                      _showOtpInput?"Continue":"Send OTP",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(Colors.teal),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 12),
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

  sendOtp(mobileNumber) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
      phoneNumber: mobileNumber,
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: (v) {},
      verificationCompleted: (AuthCredential credential) async {
        // setState(() {
        _myAuthCredential = credential;
        // });
      },
      verificationFailed: (FirebaseAuthException exception) {
        print("EXCEPTION");
        print(exception.message);
      },
      codeSent: (String verificationId, [int? forceResendingToken]) async {
        verId = verificationId;
      },
      //codeAutoRetrievalTimeout: null
    );
  }

  authenticate(mobileNumber,enteredCode) async {
    setState(() {
      _isLoading=true;
    });
    var userLogin = await loginUser(mobileNumber,enteredCode);
    setState(() {
      _isLoading=false;
    });
    if(userLogin){
      Get.snackbar(
        "Authentication Successful",
        "Welcome",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
      );
      Get.offAll(const WeatherInfo(),transition: Transition.rightToLeftWithFade);
    }
    else{
      Get.snackbar(
        "Error Occurred",
        "Please try Again",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
      );
    }
  }

  Future<bool> loginUser(String mobileNumber, String enteredCode) async {
    // verifyMobileNumber(mobileNumber);

    AuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verId, smsCode: enteredCode);

    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final authCredential =
      await _auth.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        print("USER LOGGED IN");
        return true;
      } else {
        print("USER NOT LOGGED IN");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-verification-code") {}
      return false;
    }
  }

}
