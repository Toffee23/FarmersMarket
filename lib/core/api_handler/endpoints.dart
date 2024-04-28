class ApiEndpoints {
  static const String baseUrl = 'https://app.farmersmarketplace.ng';

  static const String _auth = '$baseUrl/auth';
  static final Uri login = Uri.parse('$_auth/login');
  static final Uri signup = Uri.parse('$_auth/signup');
  static final Uri forgotPassword = Uri.parse('$_auth/forgotPassword');
  static final Uri confirmReset = Uri.parse('$_auth/confirmReset');
  static final Uri sendOtp = Uri.parse('$_auth/sendOtp');
  static final Uri verifyOtp = Uri.parse('$_auth/verifyOtp');

  static const String user = '$baseUrl/user';
  static const editProfile = '$user/editProfile';
  static const delete = '$user/delete';
  static const changePassword = '$user/changePassword';

  static final Uri categories = Uri.parse('$baseUrl/categories');

  static const String cart = '$baseUrl/cart';

  static const String products = '$baseUrl/products';
  static const String productsImages = '$baseUrl/products/prod_images';

  static final Uri like = Uri.parse('$baseUrl/like');

  static const String address = '$baseUrl/address';
  static const String addAddress = '$address/addAddress';
  static const String editAddress = '$address/editAddress';
  static const String setPrimaryAddress = '$address/setPrimaryAddress';
  static const String deleteAddress = '$address/delete';

  static const String search = '$baseUrl/search';
  static const String shipping = '$baseUrl/shipping';
  static const String orders = '$baseUrl/orders';
  static const String notifications = '$baseUrl/notifications';

  static const String stateShippingFee = '$baseUrl/shipping';
  static const String lagosCityShippingFee = '$baseUrl/shipping/lagos';

  static const String _image = 'https://farmersmarketplace.ng/images';
  static const String categoryImage = '$_image/category_images';
  static const String productImage = '$_image/product_images/small/';
}
// https://farmersmarketplace.ng/images/product_images/small/Carrot.webp-227.webp
