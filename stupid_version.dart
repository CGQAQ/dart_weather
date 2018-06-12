import 'dart:io';
import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

const info = 'http://www.weather.com.cn/weather/';
const suffix = '.shtml';

main(List<String> args) {
  var client = new HttpClient();
  client
      .getUrl(Uri.parse('http://toy1.weather.com.cn/search?cityname=哈尔滨'))
      .then((req) => req.close())
      .then((res) {
    res.transform(utf8.decoder).join().then((result) {
      //var json = jsonDecode(result);
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
          var r = dom
              .getElementsByClassName('t clearfix')[0]
              .querySelectorAll('li');
          parseData(r).forEach((d) {
            print(d.date);
            print(d.weather);
            print(d.temperature);
            print(d.wind);
            print(d.sunrise);
            print(d.sunset);
          });
          // print(r.runtimeType);
        });
      });
    });
  });
}

class WeatherData {
  int index;
  String date;
  String weather;
  Map temperature;
  Map wind;
  String sunrise;
  String sunset;
}

///<h1>13日（周三）</h1>
///<big class="png40 d01"></big>
///<big class="png40 n01"></big>
///<p title="多云" class="wea">多云</p>
///<p class="tem">
///<span>26℃</span>/<i>13℃</i>
///</p>
///<p class="win">
///<em>
///<span title="东风" class="E"></span>
///<span title="南风" class="S"></span>
///</em>
///<i><3级</i>
///</p>
List<WeatherData> parseData(List<Element> elementList) {
  List<WeatherData> list = new List<WeatherData>();
  int index = 0;
  elementList.forEach((e) {
    var data = new WeatherData(),
        highTem =
            e.getElementsByClassName('tem').first.querySelector('span').text,
        lowTem = e.getElementsByClassName('tem').first.querySelector('i').text,
        tem = new Map(),
        wind = new Map(),
        directions = e
            .getElementsByClassName('win')
            .first
            .querySelector('em')
            .querySelectorAll('span'),
        direction1 = directions[0].text,
        direction2 = directions[1].text,
        level = e.querySelector('i').text,
        sunrise = e
            .getElementsByClassName('sun sunUp')
            .first
            .querySelector('span')
            .text,
        sunset = e.getElementsByClassName('sun sunDown').first.firstChild.text;

    data.index = index;
    data.date = e.querySelector('h1').text;
    data.weather = e.getElementsByClassName('wea').first.text;
    tem['high'] = highTem;
    tem['low'] = lowTem;
    data.temperature = tem;
    wind['direction'] = direction1 + '转' + direction2;
    wind['level'] = level;
    data.wind = wind;
    data.sunrise = sunrise;
    data.sunset = sunset;
    list.add(data);

    index++;
  });

  return list;
}
