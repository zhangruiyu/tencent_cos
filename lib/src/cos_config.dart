class COSConfig {
  String secretId;
  String secretKey;
  String bucketName;
  String region;
  String scheme;
  bool anonymous;
  COSConfig(
    this.secretId,
    this.secretKey,
    this.bucketName,
    this.region, {
    this.scheme = "https",
    this.anonymous = false,
  });

  String get uri {
    return "$scheme://$bucketName.cos.$region.myqcloud.com";
  }
}
