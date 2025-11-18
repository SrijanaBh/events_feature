import 'package:html/parser.dart' as html;

List<String> parseHtmlList(String htmlString) {
  final document = html.parse(htmlString);
  final items = document.getElementsByTagName("li");

  return items.map((e) => e.text.trim()).toList();
}
