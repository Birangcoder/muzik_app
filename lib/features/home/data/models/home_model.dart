import '../../../../shared/models/album_model_ref.dart';
import '../../../song/data/models/song_model.dart';
import '../../../../shared/models/artist_model_ref.dart';

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

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      trending: (json['trending'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList(),

      popular: (json['popular'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList(),

      recommended: (json['recommended'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList(),

      newReleases: (json['new_release'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList(),

      artists: (json['top_artists'] as List)
          .map((e) => ArtistsModelRef.fromJson(e))
          .toList(),

      albums: (json['top_albums'] as List)
          .map((e) => AlbumModelRef.fromJson(e))
          .toList(),

      continueListening: (json['continue_listening'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList(),
    );
  }
}

//add popular, recommended, continue listening