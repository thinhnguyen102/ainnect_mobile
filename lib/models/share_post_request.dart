class SharePostRequest {
  final String? comment;
  final String? visibility;

  const SharePostRequest({
    this.comment,
    this.visibility,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (comment != null && comment!.isNotEmpty) {
      data['comment'] = comment;
    }
    if (visibility != null) {
      data['visibility'] = visibility;
    }
    return data;
  }
}

