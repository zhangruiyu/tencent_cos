import 'package:xml/xml.dart';

XmlElement subElem(XmlElement node, String name) {
  return node.childElements.singleWhere((node) => node.name.local == name);
}

class ObjectItem {
  String key = "";
  DateTime lastModified = DateTime.now();
  String eTag = "";
  int size = 0;
  ObjectItem(XmlElement root) {
    key = subElem(root, "Key").innerText;
    lastModified = DateTime.parse(subElem(root, "LastModified").innerText);
    eTag = subElem(root, "ETag").innerText;
    size = int.parse(subElem(root, "Size").innerText);
  }
}

class ListBucketResult {
  String name = "";
  String prefix = "";
  String marker = "";
  int maxKeys = 0;
  bool isTruncated = false;
  List<ObjectItem> contents = [];

  Iterable<XmlElement> subElems(XmlElement node, String name) {
    return node.childElements.where((node) => node.name.local == name);
  }

  ListBucketResult(XmlElement root) {
    name = subElem(root, "Name").innerText;
    prefix = subElem(root, "Prefix").innerText;
    marker = subElem(root, "Marker").innerText;
    maxKeys = int.parse(subElem(root, "MaxKeys").innerText);
    isTruncated = subElem(root, "IsTruncated").innerText == "true";
    var contentNodes = subElems(root, "Contents");
    contents = contentNodes.map((e) => ObjectItem(e)).toList();
  }
}
