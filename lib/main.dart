import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:sms/sms.dart";
import 'package:file_picker/file_picker.dart';

import './recipients.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController number = TextEditingController();
  TextEditingController messageEntered = TextEditingController();

  List<String> recipients = ['03088404460', '03230445347'];

  createAlertDialog(BuildContext context, String ttl, String msg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(ttl),
            content: Text(msg),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  void _sendSMS() {
    if (messageEntered.text.isEmpty || recipients.length == 0) {
      createAlertDialog(
          context, 'Error', 'Message or Recipients List can\'t be empty.');
      return;
    }
    for (var i = 0; i < recipients.length; i++) {
      SmsSender sender = new SmsSender();
      String address = recipients[i];

      SmsMessage message = new SmsMessage(address, messageEntered.text);
      sender.sendSms(message);
      message.onStateChanged.listen((state) {
        if (state == SmsMessageState.Sent) {
          print("SMS is sent!");
        } else if (state == SmsMessageState.Delivered) {
          print("SMS is delivered!");
        }
      });
    }

    setState(() {
      number = TextEditingController();
      messageEntered = TextEditingController();
      recipients = ['03088404460', '03230445347'];
    });
    createAlertDialog(context, 'Success', 'The messages have been delivered.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey.shade300,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(child: Text("SMS App")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                "Recipients",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 100.0,
                  decoration: BoxDecoration(
                    // color: Colors.blue,
                    border: Border.all(
                      // color: Colors.red,
                      width: 2.0,
                      style: BorderStyle.none,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20.0,
                        spreadRadius: 20.0,
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.grey,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: recipients.isEmpty ? Text('') : RecipientsList(recipients)),
            ),
            SizedBox(height: 40,),
            Row(

              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.82,
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    onSubmitted: (_) {
                      if (number.text.isNotEmpty) {
                        setState(() {
                          recipients.add(number.text);
                          number = TextEditingController();
                        });
                      }
                    },
                    controller: number,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,

                    //controller: firstNameTextController,
                    //validator: _validateFirstName,
                    maxLength: 11,
                    style: TextStyle(
                      color: Colors.black54,
                      //fontFamily: ScreensFontFamlty.FONT_FAMILTY
                    ),

                    decoration: InputDecoration(
                      counterText: "",
                      prefixIcon: Icon(
                        Icons.person,
                        size: 22,
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: const OutlineInputBorder(
                          borderSide: const BorderSide(
                              // color: Color.fromARGB(255, 232, 232, 232),
                              color: Colors.white,
                              width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                              // color: Color.fromARGB(255, 232, 232, 232),
                              color: Colors.white,
                              width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                              // color: Color.fromARGB(255, 232, 232, 232),
                              color: Colors.white,
                              width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      hintText: "Phone Number",
                      hintStyle: TextStyle(
                          color: Color(0xFF72868a), fontWeight: FontWeight.w500
                          //fontFamily: ScreensFontFamlty.FONT_FAMILTY
                          ),
                      filled: true,
                      fillColor: Colors.white,
                      // errorStyle: AppTypoGraphy.errorHintStyle
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (number.text.isNotEmpty) {
                      setState(() {
                        recipients.add(number.text);
                        number = TextEditingController();
                      });
                    }
                  },
                )
              ],
            ),
            Container(
              margin: MediaQuery.of(context).viewInsets,
              padding: EdgeInsets.all(10),
              child: TextField(
                maxLines: 5,
                onSubmitted: (_) => _sendSMS(),
                decoration: InputDecoration(
                  counterText: "",
                  // prefixIcon: Icon(
                  //   Icons.person,
                  //   size: 22,
                  //   color: Colors.black,
                  // ),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        // color: Color.fromARGB(255, 232, 232, 232),
                          color: Colors.white,
                          width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        // color: Color.fromARGB(255, 232, 232, 232),
                          color: Colors.white,
                          width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        // color: Color.fromARGB(255, 232, 232, 232),
                          color: Colors.white,
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  hintText: "Type Message ",
                  hintStyle: TextStyle(
                      color: Color(0xFF72868a), fontWeight: FontWeight.w500
                    //fontFamily: ScreensFontFamlty.FONT_FAMILTY
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  // errorStyle: AppTypoGraphy.errorHintStyle
                ),
                controller: messageEntered,
              ),




            ),
            SizedBox(height: 30,),
               RaisedButton(
                 color: Colors.black,
                child: Text("Send",style: TextStyle(color:Colors.white),),
                onPressed: _sendSMS,

            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () async {
      //     File file = await FilePicker.getFile(
      //       type: FileType.custom,
      //       allowedExtensions: ['csv'],
      //     );
      //     final input = file.openRead();
      //     final fields = await input
      //         .transform(utf8.decoder)
      //         .transform(new CsvToListConverter())
      //         .toList();
      //     for (var i = 0; i < fields.length; i++) {
      //       recipients.add(fields[i][0].toString());
      //     }
      //     setState(() {});
      //   },
      // ),
    );
  }
}
// TextField(
// maxLines: 5,
// onSubmitted: (_) => _sendSMS(),
// decoration: InputDecoration(
// border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
// labelText: "Message",
// ),
// controller: messageEntered,
// ),