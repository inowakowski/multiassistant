import 'package:http/http.dart' as http;

Future<String> checkServers(String localUrl, String externalUrl) async {
  try {
    var response = await http.get(Uri.parse(localUrl));

    if (response.statusCode == 200) {
      return "Connected by local url";
    }
  } catch (e) {
    var response = await http.get(Uri.parse(externalUrl));

    if (response.statusCode == 200) {
      return "Connected by external url";
    } else {
      return "Not connected";
    }
  }

  return "Not connected";
}
