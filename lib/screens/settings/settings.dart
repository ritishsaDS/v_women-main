import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:vietnamese/common/Api.dart';
import 'package:vietnamese/common/constants.dart';
import 'package:vietnamese/common/size_config.dart';
import 'package:vietnamese/components/bottom.dart';
import 'package:http/http.dart' as http;
import 'package:vietnamese/components/common_navigation.dart';
import 'package:vietnamese/screens/Login/login.dart';
import 'package:vietnamese/screens/notes/alerts/period_ended.dart';
import 'package:vietnamese/screens/settings/PinAndRegister/pin_register_screen.dart';
import 'package:vietnamese/screens/settings/alerts/cycle_length.dart';
import 'package:vietnamese/screens/settings/components/genral_list_tile.dart';
import 'package:vietnamese/screens/settings/components/privacy_policy.dart';

import 'alerts/period_length.dart';
import 'components/pregnent_tile.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isLoading = false;
  String token;
  bool isError;
  var mensturllength;
  var perioddate;
  String startdate = "28";
  String enddate = "20";
  String formattedDate;
  @override
  void initState() {
    getSettings();
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    formattedDate = formatter.format(now);
    print(formattedDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                child: isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: SizeConfig.screenHeight / 2,
                          ),
                          Center(
                            child: CircularProgressIndicator(
                              backgroundColor: kPrimaryColor,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          BottomTabs(5, true),
                          HeightBox(
                            getProportionateScreenHeight(20),
                          ),
                          GenralListTile(
                            title: 'Period Length',
                            tileType: TileType.subtext,
                            subtitle: '($startdate Days)',
                            onTap: () async {
                              perioddate = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CycleLenghtAlert());
                              print(perioddate);
                              setState(() {
                                if (perioddate == null) {
                                  startdate = "28";
                                } else {
                                  startdate = perioddate;
                                }
                              });
                              print("BCSJJJnnjnj");
                            },
                          ),
                          GenralListTile(
                            title: 'Menstrual Period',
                            tileType: TileType.subtext,
                            subtitle: '($enddate Days)',
                            onTap: () async {
                              mensturllength = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      PeriodLenghtAlert());
                              setState(() {
                                print(mensturllength);
                                if (mensturllength == null) {
                                  enddate = "20";
                                } else {
                                  enddate = mensturllength;
                                }
                              });
                            },
                          ),
                          PregnentTile(
                              is_pregnency: settingfromserver["data"]
                                  ['is_pregnency']),
                          GenralListTile(
                              title: 'Back up And Restore', onTap: null),
                          GenralListTile(
                            title: 'Pin And Register',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PinRegisterScreen(),
                              ),
                            ),
                          ),
                          GenralListTile(title: 'Report Bug', onTap: null),
                          GenralListTile(
                              title: 'Suggest Features', onTap: null),
                          GenralListTile(title: 'Share', onTap: null),
                          GenralListTile(
                              title: 'Update Settings',
                              onTap: () {
                                updateSetting();
                              }),
                          GenralListTile(
                              title: 'Erase Personal Data',
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.clear();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              }),
                          GenralListTile(
                            title: 'Privacy Policy',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivacyPolicy(),
                              ),
                            ),
                          ),
                          GenralListTile(
                              title: 'Logout',
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString("email", null);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              }),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dynamic settingfromserver = new List();
  Future<void> getSettings() async {
    isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    print(token);
    try {
      final response = await http.post(getSetting, headers: {
        'Authorization': 'Bearer $token',
      });
      print(response.statusCode.toString());
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        settingfromserver = responseJson;
        print(settingfromserver);

        setState(() {
          isError = false;
          isLoading = false;
          print('setstate');
        });
      } else {
        print("bjkb" + response.statusCode.toString());

        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("uhdfuhdfuh");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> updateSetting() async {
    isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    print(token);
    try {
      final response = await http.post(updatesetings, headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        "is_pregnency": "yes",
        "period_length": perioddate,
        "menstural_period": mensturllength
      });
      print(response.statusCode.toString());
      print(perioddate.toString());
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        settingfromserver = responseJson;
        print(settingfromserver);

        setState(() {
          isError = false;
          isLoading = false;
          print('setstate');
        });
      } else {
        print("bjkb" + response.statusCode.toString());

        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("uhdfuhdfuh");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }
}
