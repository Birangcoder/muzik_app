import 'model/track_model.dart';
import 'model/album_model.dart';
import 'model/artist_model.dart';

final List<TrackModel> trendingTracks = [
  const TrackModel(
    id: '1',
    name: 'glass horizon',
    artistName: 'deepend',
    image:
        'https://usercontent.jamendo.com?type=album&id=24&width=300&trackid=168',
  ),
  const TrackModel(
    id: '2',
    name: 'amber static',
    artistName: 'felix orr',
    image:
        'https://usercontent.jamendo.com?type=album&id=24&width=300&trackid=169',
  ),
  const TrackModel(
    id: '3',
    name: 'paper moons',
    artistName: 'vela',
    image:
        'https://usercontent.jamendo.com?type=album&id=24&width=300&trackid=170',
  ),
  const TrackModel(
    id: '4',
    name: 'driftwood',
    artistName: 'oyu',
    image:
        'https://usercontent.jamendo.com?type=album&id=24&width=300&trackid=171',
  ),
];

final List<AlbumModel> newReleases = [
  const AlbumModel(id: '1', name: 'holo garden', artistName: 'kessy'),
  const AlbumModel(id: '2', name: 'low tide', artistName: 'oyu'),
  const AlbumModel(id: '3', name: 'night frequencies', artistName: 'mira wave'),
  const AlbumModel(id: '4', name: 'afterglow', artistName: 'retrograde'),
];

final List<ArtistModel> artists = [
  const ArtistModel(id: '1', name: 'deepend', trackCount: 34),
  const ArtistModel(id: '2', name: 'mira wave', trackCount: 21),
  const ArtistModel(id: '3', name: 'retrograde', trackCount: 58),
  const ArtistModel(id: '4', name: 'kessy', trackCount: 12),
];

final List<String> genres = [
  'electronic',
  'lo-fi',
  'bass',
  'hip-hop',
  'ambient',
  'synth',
];
