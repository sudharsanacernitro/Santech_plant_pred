import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ThingSpeakData extends StatefulWidget {
  @override
  _ThingSpeakDataState createState() => _ThingSpeakDataState();
}

class _ThingSpeakDataState extends State<ThingSpeakData> {
  final String channelID = "2876880"; // Your Channel ID
  final String apiKey = "7I3H9DRLYSZXILOD"; // Your Read API Key
  final Dio dio = Dio();

  List<dynamic> feeds = [];
  final List<String> labels = [
    "Soil Moisture",
    "Temp",
    "Humidity",
    "Ph",
    "Light",
    "Water Level",
    "N",
    "P",
    "K"
  ];

  Future<void> fetchData() async {
    final String url =
        "https://api.thingspeak.com/channels/$channelID/feeds.json?api_key=$apiKey";

    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        setState(() {
          feeds = response.data["feeds"];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ThingSpeak Data")),
      body: feeds.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: feeds.length,
              itemBuilder: (context, index) {
                String? field1 = feeds[index]['field1'];
                List<String> values = field1?.split(',') ?? [];
                print(field1);
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Entry ID: ${feeds[index]['entry_id']}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        ...List.generate(
                          values.length < labels.length ? values.length : labels.length,
                          (i) => Text("${labels[i]}: ${values[i]}"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
