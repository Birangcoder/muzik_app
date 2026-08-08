class TrackModel {
  final String id;
  final String name;
  final String artistName;
  final String image;
  final bool? audioDownloadAllowed;
  final String? audio;
  final String? audioDownload;
  final String license;

  const TrackModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.image,
    this.audioDownloadAllowed,
    this.audio,
    this.audioDownload,
    this.license = "CC BY-NC-SA",
  });
}
