class ApiConfig {
  static const baseUrl = "https://f405-2409-40c1-5464-6b85-a4e6-344e-3bcf-7b52.ngrok-free.app/MusicAPI-v2/public";

  static const login = "$baseUrl/auth/login";

  static const register = "$baseUrl/auth/register";

  static const logout = '$baseUrl/auth/logout';

  static const profile = '$baseUrl/profile';

  static const home = '$baseUrl/home';

  static const songs = "$baseUrl/songs";
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
