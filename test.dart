import 'dart:io';
import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

main(List<String> args) {
  var client = new HttpClient(context: null);
  var time = new DateTime.now();
  client
      .openUrl('get', new Uri.http('www.baidu.com', '/'))
      .then((req) => req.close())
      .then((resp) => resp.transform(utf8.decoder).join().then((str) {
            Document dom = parse(str);
            var title = dom.querySelector('title').text;
            print(title);

            print(
                "共用时： ${new DateTime.now().difference(time).inMilliseconds}ms");
          }));
}

// var f = new File("./file.json");
// f.readAsString().then((jsonString) {
//   var json = jsonDecode(jsonString) as Map<String, String>;
//   json.forEach((a, b) => print("$a: $b"));
// });

// print('helle ${math.pow(2, 5)}');
