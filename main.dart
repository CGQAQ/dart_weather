import 'dart:convert';
import 'dart:io';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

const info = 'http://www.weather.com.cn/weather/';
const suffix = '.shtml';

///
///
///
///
main(List<String> args) {
  var client = new HttpClient();
  client
      .getUrl(Uri.parse('http://toy1.weather.com.cn/search?cityname=哈尔滨'))
      .then((req) => req.close())
      .then((res) {
    res.transform(utf8.decoder).join().then((result) {
      var resultTrimed = result
          .replaceFirstMapped('(', (a) => '')
          .replaceFirstMapped(')', (a) => '');
      var resultJson = jsonDecode(resultTrimed) as List;
      var cityNum = resultJson.length > 0
          ? int.parse((resultJson[0] as Map)['ref'].split('~')[0])
          : 0;

      client
          .getUrl(Uri.parse(info + cityNum.toString() + suffix))
          .then((req) => req.close())
          .then((res) {
        res.transform(utf8.decoder).join().then((result) {
          Document dom = parse(result);
          var script = dom.querySelectorAll('script'), dataString = null;
          script.forEach((script) => script.innerHtml.contains('hour3data')
              ? dataString = script.innerHtml.split('=')[1]
              : null);
          parseData(dataString);
        });
      });
    });
  });
}

// class Data{
// 	String date;
// 	String weather;
// 	String temparature;
// 	String winddirection;
// 	String Wind
// }
class WeatherData {
  List<String> w1d;
}

WeatherData parseData(String ds) {
  var weatherData = jsonDecode(ds), weather = new WeatherData();

  (weatherData['1d'] as List<String>).forEach((s) => print(s));
  print(weatherData['1d']);
  return weather;
}
