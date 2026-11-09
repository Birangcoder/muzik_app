import '../../../../core/utils/json_utils.dart';
import '../../../../shared/models/album_model_ref.dart';
import '../../../../shared/models/artist_model_ref.dart';
import '../../../song/data/models/song_model.dart';

class HomeModel {
  final List<SongModel> trending;
  final List<SongModel> popular;
  final List<SongModel> recommended;
  final List<SongModel> newReleases;
  final List<SongModel> continueListening;
  final List<ArtistsModelRef> artists;
  final List<AlbumModelRef> albums;

  HomeModel({
    required this.trending,
    required this.popular,
    required this.recommended,
    required this.newReleases,
    required this.continueListening,
    required this.artists,
    required this.albums,
  });

  /// Every section is optional: a missing / null section becomes an empty
  /// list instead of crashing the whole home screen.
  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      trending: Json.list(json['trending'], SongModel.fromJson),
      popular: Json.list(json['popular'], SongModel.fromJson),
      recommended: Json.list(json['recommended'], SongModel.fromJson),
      newReleases: Json.list(
        json['new_release'] ?? json['new_releases'],
        SongModel.fromJson,
      ),
      continueListening: Json.list(
        json['continue_listening'],
        SongModel.fromJson,
      ),
      artists: Json.list(json['top_artists'], ArtistsModelRef.fromJson),
      albums: Json.list(json['top_albums'], AlbumModelRef.fromJson),
    );
  }
}
