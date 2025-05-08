import 'package:objectbox/objectbox.dart';

/// Klasse welche die API-URL festlegt

String apiVersion = "fuhrpark";

@Entity()
class Api {

  @Id(assignable: true)
  int id;

  late String url;
  late String shortUrl;

  String localhostURL = "http://10.0.2.2:80";

  String get apiUrl  {
    return url;
  }

  set apiUrl(String value) {


    if(!value.contains(".") && !value.contains("erp")) {
      value = value + ".pfox.cloud";
    } else if(!value.contains(".") && value.contains("erp")) {
      value = value + ".powerfox.it";
    }

    // if(value.startsWith("http://")) {
    //   value.replaceAll("http", "https");
    // }


    if (value.startsWith("http://") && !value.contains(apiVersion)) {
      url = value + "/data/API/" + apiVersion;
    } else if(!value.contains(apiVersion)) {
      url = "http://" + value + "/data/API/" + apiVersion;
    }



  }

  Api({
    this.id = 0,
  });

}