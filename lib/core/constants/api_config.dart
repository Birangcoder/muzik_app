class ApiConfig {
  static const baseUrl = 'https://musicapi-1xqp.onrender.com/v2';

  static const login = '$baseUrl/auth/login';

  static const register = '$baseUrl/auth/register';

  static const logout = '$baseUrl/auth/logout';

  static const profile = '$baseUrl/profile';

  static const home = '$baseUrl/home';

  static const songs = '$baseUrl/songs';

  static const trending = '$baseUrl/songs/trending';

  static String song(int id) => '$baseUrl/songs/$id';

  static String songPlay(int id) => '$baseUrl/songs/$id/play';

  static String songProgress(int id) => '$baseUrl/songs/$id/progress';

  static String songRemoveFavorite(int id) => '$baseUrl/favorites/$id';

  static const songFavorite = '$baseUrl/favorites';

  static const history = '$baseUrl/history';

  static const latestSong = '$baseUrl/songs/latest';

  static const recommendedSong = '$baseUrl/songs/recommended';

  static const albums = '$baseUrl/albums';

  static const albumSearch = '$baseUrl/albums/search';

  static String album(int id) => '$baseUrl/albums/$id';

  static String albumTracks(int id) => '$baseUrl/albums/$id/tracks';
  //
  // static const categories = "$baseUrl/products/categories";
  //
  // static String product(int id) => "$baseUrl/products/$id";
  //
  // static String search(String query) => "$baseUrl/products/search?q=$query";
  //
  // static String category(String name) => "$baseUrl/products/category/$name";
  //
  // static String cart(int id) => "$baseUrl/carts/$id";
  //
  // static String user(int id) => "$baseUrl/users/$id";
  //
  // static String currentUser = "$baseUrl/auth/me";
}
