import '../../../../shared/models/album_model.dart';
import '../../../song/data/models/songs_model.dart';
import '../../../../shared/models/artists_model.dart';

class HomeModel {
  final List<SongModel> trending;
  final List<SongModel> popular;
  final List<SongModel> recommended;
  final List<SongModel> newReleases;
  final List<SongModel> continueListening;
  final List<ArtistsModel> artists;
  final List<AlbumModel> albums;

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
          .map((e) => ArtistsModel.fromJson(e))
          .toList(),

      albums: (json['top_albums'] as List)
          .map((e) => AlbumModel.fromJson(e))
          .toList(),

      continueListening: (json['continue_listening'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList(),
    );
  }
}

//add popular, recommended, continue listening