import 'dart:convert';
import 'dart:io';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

const info = 'http://www.weather.com.cn/weather/';
const suffix = '.shtml';

const city = "哈尔滨";

///
///
///
///
main(List<String> args) {
  var client = new HttpClient();
  client
      .getUrl(Uri.parse('http://toy1.weather.com.cn/search?cityname=' + city))
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
          WeatherData w = parseData(dataString);
          print(city + '天气： ');
          w.w1d.forEach((w) => print(w));
          w.w7d.forEach((f) => f.forEach((f) => print(f)));
          w.w23d.forEach((f) => f.forEach((f) => print(f)));
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
  List<List<String>> w7d;
  List<List<String>> w23d;
}

WeatherData parseData(String ds) {
  var weatherData = jsonDecode(ds), weather = new WeatherData();

  weather.w1d = new List<String>();
  weather.w7d = new List<List<String>>();
  weather.w23d = new List<List<String>>();

  (weatherData['1d'] as List<String>).forEach((s) {
    var sa = s.split(',');
    sa.removeAt(1);
    sa.removeLast();
    weather.w1d.add(sa.join(' '));
  });
  (weatherData['7d'] as List<List<String>>).forEach((s) {
    var sarray = new List<String>();
    s.forEach((s) {
      var sa = s.split(',');
      sa.removeAt(1);
      sa.removeLast();
      sarray.add(sa.join(' '));
    });
    weather.w7d.add(sarray);
  });
  (weatherData['23d'] as List<List<String>>).forEach((s) {
    var sarray = new List<String>();
    s.forEach((s) {
      var sa = s.split(',');
      sa.removeAt(1);
      sa.removeLast();
      sarray.add(sa.join(' '));
    });
    weather.w23d.add(sarray);
  });

  // print(weather.w1d);
  // print(weather.w7d);
  // print(weather.w23d);
  return weather;
}
