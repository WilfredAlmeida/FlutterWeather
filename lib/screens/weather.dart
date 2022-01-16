import 'dart:convert';
import 'dart:math' as math;

import "package:flutter/material.dart";
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({Key? key}) : super(key: key);

  @override
  _WeatherInfoState createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {

  static const API_KEY = "8cbce2bf9c96ba7df25eb3bdcd9c5e87";
  final _cityController = TextEditingController();
  var _showLoading=false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Demo"),backgroundColor: Colors.teal,),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  hintText: "Enter City Name",
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
              ),
              const SizedBox(height: 12),
              _showLoading?const CircularProgressIndicator(color: Colors.teal):Center(
                child: SizedBox(
                  width: 280,
                  child: ElevatedButton(
                    onPressed: () async{
                      setState(() {
                        _showLoading=true;
                      });
                      var cityName=_cityController.text.toString().trim();
                      if(cityName.isEmpty){
                        Get.snackbar(
                          "City Name Empty",
                          "Please Enter City Name",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.teal,
                        );
                        return;
                      }

                      var url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$API_KEY");

                      var response = await http.get(url);
                      final res=json.decode(response.body);
                      final answer = parseWeather(res);

                      showDialog(context: context, builder: (ctx){
                        return AlertDialog(
                          title: const Text("Weather"),
                          content: SingleChildScrollView(child:Text(answer)),
                          actions: [
                        TextButton(
                        child: const Text("OK"),
                        onPressed: () {Navigator.of(context).pop();},
                        ),
                          ],
                        );
                      });

                      setState(() {
                        _showLoading=false;
                      });
                    },
                    child: const Text(
                      "Check Weather",
                      style: TextStyle(
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
  String parseWeather(json) {
    var final_String = "";
    if (json["cod"] == 200) {
      var lat = json["coord"]["lat"];
      var lon = json["coord"]["lon"];

      var weather = json["weather"][0]["description"];

      var temp = json["main"]["temp"];

      var feels_like = json["main"]["feels_like"];

      var max_temp = json["main"]["temp_max"];

      var min_temp = json["main"]["temp_min"];

      var pressure = json["main"]["pressure"];

      var humidity = json["main"]["humidity"];

      var visibility = json["visibility"];

      var wind_speed = json["wind"]["speed"];

      var cloudiness = json["clouds"]["all"];

      var calculation_time = DateTime(json["dt"] * 1000).toUtc().toString();

      var sunrise_time = DateTime(json["sys"]["sunrise"] * 1000).toUtc().toString();
      var sunset_time = DateTime(json["sys"]["sunset"] * 1000).toUtc().toString();

      var city = json["name"];
      var country = json["sys"]["country"];

      final_String += """City Name: ${city} \n
Country: ${country} \n
Latitude: ${lat} \n
Longitude: ${lon} \n
Weather: ${weather} \n
Temperature: ${temp.toString()+"°K"}\n
Feels Like Temperature: ${feels_like.toString()+"°K"} \n
Minimum Temperature: ${min_temp.toString()+"°K"} \n
Minimum Temperature: ${max_temp.toString()+"°K"} \n
Pressure: ${pressure} \n
Humidity: ${humidity.toString()+"%"} \n
Visibility: ${visibility} \n
Wind Speed: ${wind_speed}\n
Cloudiness: ${cloudiness}% \n
    """;

    } else {
    final_String += "Invaild City";
    // console.log(final_String);
    }

    return final_String;
  }
}
