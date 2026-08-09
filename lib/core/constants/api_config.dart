class ApiConfig {
  static const baseUrl = "https://decb-2409-40c1-551d-a6b7-f473-198e-bf60-de9d.ngrok-free.app/MusicAPI-v2/public";

  static const login = "$baseUrl/auth/login";

  static const register = "$baseUrl/auth/register";

  static const logout = '$baseUrl/auth/logout';

  static const profile = '$baseUrl/profile';

  // static const products = "$baseUrl/products";
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
