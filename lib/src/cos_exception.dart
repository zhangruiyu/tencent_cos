class COSException implements Exception {
  int statusCode;
  String msg;
  COSException(this.statusCode, this.msg);
  @override
  String toString() {
    return "COSException:\nstatusCode:$statusCode\n\n$msg";
  }
}
