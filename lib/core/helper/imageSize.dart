class CloudinaryImage {
  static String resize(
      String url, {
        required double width,
        double? height,
      }) {
    final h = height ?? width;

    return url.replaceFirst(
      '/image/upload/',
      '/image/upload/'
          'w_${width.toInt()},'
          'h_${h.toInt()},'
          'c_fill,'
          'f_auto,'
          'q_auto/',
    );
  }
}