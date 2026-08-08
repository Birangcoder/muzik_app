class ApiConfig {
  static const baseUrl = "https://328c-2409-40c1-5479-d3d1-60cb-5b9-3197-c313.ngrok-free.app/MusicAPI-v2/public";

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
