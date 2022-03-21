import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'cos_clientbase.dart';
import 'cos_comm.dart';
import "cos_config.dart";
import 'cos_exception.dart';
import "cos_model.dart";

class COSClient extends COSClientBase {
  COSClient(COSConfig _config) : super(_config);

  Future<ListBucketResult> listObject({String prefix = ""}) async {
    cosLog("listObject");
    var response = await getResponse("GET", "/", params: {"prefix": prefix});
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    String xmlContent = await response.transform(utf8.decoder).join("");
    if (response.statusCode != 200) {
      throw COSException(response.statusCode, xmlContent);
    }
    var content = XmlDocument.parse(xmlContent);
    return ListBucketResult(content.rootElement);
  }

  Future<String?> putObjectWithFileData(String objectKey, List<int> fileData,
      {String? token}) async {
    cosLog("putObject");
    int fileLength = fileData.length;
    var req = await getRequest("PUT", objectKey,
        headers: {
          "content-type": "image/jpeg",
          "content-length": fileLength.toString()
        },
        token: token);
    req.add(fileData);
    var response = await req.close();
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    if (response.statusCode != 200) {
      String content = await response.transform(utf8.decoder).join("");
      cosLog("putObject error content: $content");
      return null;
    } else {
      return objectKey;
    }
  }

  Future<String?> putObject(String objectKey, String filePath,
      {String? token}) async {
    cosLog("putObject");
    var f = File(filePath);
    int flength = await f.length();
    var fs = f.openRead();
    var req = await getRequest("PUT", objectKey,
        headers: {
          "content-type": "image/jpeg",
          "content-length": flength.toString()
        },
        token: token);
    await req.addStream(fs);
    var response = await req.close();
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    if (response.statusCode != 200) {
      String content = await response.transform(utf8.decoder).join("");
      cosLog("putObject error content: $content");
      return null;
    } else {
      return objectKey;
    }
  }

  deleteObject(String objectKey) async {
    cosLog("deleteObject");
    var response = await getResponse("DELETE", objectKey);
    cosLog("request-id:" + (response.headers["x-cos-request-id"]?.first ?? ""));
    if (response.statusCode != 204) {
      cosLog("deleteObject error");
      String content = await response.transform(utf8.decoder).join("");
      throw COSException(response.statusCode, content);
    }
  }
}
