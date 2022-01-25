import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'cos_comm.dart';
import "cos_config.dart";

class COSClientBase {
  final COSConfig _config;

  COSClientBase(this._config);

  ///生成签名
  String getSign(String method, String key,
      {Map<String, String?> headers = const {},
      Map<String, String?> params = const {},
      DateTime? signTime}) {
    if (_config.anonymous) {
      return "";
    } else {
      signTime = signTime ?? DateTime.now();
      int startSignTime = signTime.millisecondsSinceEpoch ~/ 1000 - 60;
      int stopSignTime = signTime.millisecondsSinceEpoch ~/ 1000 + 120;
      String keyTime = "$startSignTime;$stopSignTime";
      cosLog("keyTime=$keyTime");
      String signKey = hmacSha1(keyTime, _config.secretKey);
      cosLog("signKey=$signKey");

      var lap = getListAndParameters(params);
      String urlParamList = lap[0];
      String httpParameters = lap[1];
      cosLog("urlParamList=$urlParamList");
      cosLog("httpParameters=$httpParameters");

      lap = getListAndParameters(filterHeaders(headers));
      String headerList = lap[0];
      String httpHeaders = lap[1];
      cosLog("headerList=$headerList");
      cosLog("httpHeaders=$httpHeaders");

      String httpString =
          "${method.toLowerCase()}\n$key\n$httpParameters\n$httpHeaders\n";
      cosLog("httpString=$httpString");
      String stringToSign =
          "sha1\n$keyTime\n${hex.encode(sha1.convert(httpString.codeUnits).bytes)}\n";
      cosLog("stringToSign=$stringToSign");
      String signature = hmacSha1(stringToSign, signKey);
      cosLog("signature=$signature");
      String res =
          "q-sign-algorithm=sha1&q-ak=${_config.secretId}&q-sign-time=$keyTime&q-key-time=$keyTime&q-header-list=$headerList&q-url-param-list=$urlParamList&q-signature=$signature";
      cosLog("Authorization=$res");
      return res;
    }
  }

  filterHeaders(Map<String, String?> src) {
    Map<String, String?> res = {};
    const validHeaders = {
      "cache-control",
      "content-disposition",
      "content-encoding",
      "content-type",
      "expires",
      "content-md5",
      "content-length",
      "host"
    };
    for (String key in src.keys) {
      if (validHeaders.contains(key) || key.toLowerCase().startsWith("x")) {
        if (key == "content-length" && src["content-length"] == "0") {
          continue;
        }
        res[key] = src[key];
      }
    }
    return res;
  }

  ///处理请求头和参数列表
  List<String> getListAndParameters(Map<String, String?> params) {
    params = params.map((key, value) => MapEntry(
        Uri.encodeComponent(key).toLowerCase(),
        Uri.encodeComponent(value ?? "")));

    var keys = params.keys.toList();
    keys.sort();
    String urlParamList = keys.join(";");
    String httpParameters =
        keys.map((e) => e + "=" + (params[e] ?? "")).join("&");
    return [urlParamList, httpParameters];
  }

  /// 使用HMAC-SHA1计算摘要
  String hmacSha1(String msg, String key) {
    return hex.encode(Hmac(sha1, key.codeUnits).convert(msg.codeUnits).bytes);
  }

  Future<HttpClientRequest> getRequest(String method, String action,
      {Map<String, String?> params = const {},
      Map<String, String?> headers = const {},
      String? token}) async {
    String urlParams =
        params.keys.toList().map((e) => e + "=" + (params[e] ?? "")).join("&");
    if (urlParams.isNotEmpty) {
      urlParams = "?" + urlParams;
    }
    HttpClient client = HttpClient();

    if (!action.startsWith("/")) {
      action = "/" + action;
    }

    var req = await client.openUrl(
        method, Uri.parse("${_config.uri}$action$urlParams"));

    headers.forEach((key, value) {
      req.headers.add(key, value ?? "");
    });
    Map<String, String> _headers = {};
    req.headers.forEach((name, values) {
      _headers[name] = values[0];
    });
    var sighn = getSign(method, action, params: params, headers: _headers);
    req.headers.add("Authorization", sighn);
    if(token != null){
      req.headers.add("x-cos-security-token", token);
    }
    return req;
  }

  Future<HttpClientResponse> getResponse(String method, String action,
      {Map<String, String?> params = const {},
      Map<String, String?> headers = const {}}) async {
    var req =
        await getRequest(method, action, params: params, headers: headers);
    var res = await req.close();
    return res;
  }
}
