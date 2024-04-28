import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../constants/storage.dart';
import 'endpoints.dart';
import 'models.dart';
export 'models.dart';

class ApiService {
  final _headers = {"Content-Type": "application/json"};
  final String _success = 'SUCCESS', failed = 'FAILED';

  Future<Response> _getRequests(Uri url) async {
    try {
      final http.Response response = await http.get(url, headers: _headers);

      final responseData = jsonDecode(response.body);
      final result = Response.fromJson(responseData);

      // log(responseData.toString());

      if (result.statusMessage == _success || result.data != null) {
        return result.copyWith(status: ResponseStatus.success);
      }
      return result.copyWith(status: ResponseStatus.failed);
    } on SocketException catch (_) {
      // log('[SocketException] $_');
      return Response(status: ResponseStatus.connectionError);
    } catch (_) {
      // log('[UNKNOWN ERROR] $_');
      return Response(status: ResponseStatus.unknownError);
    }
  }

  Future<Response> _postRequests(Uri url, Map<String, dynamic> data) async {
    try {
      final http.Response response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      final result = Response.fromJson(responseData);

      if (result.statusMessage == _success || result.data != null) {
        return result.copyWith(status: ResponseStatus.success);
      }
      return result.copyWith(status: ResponseStatus.failed);
    } on SocketException catch (e) {
      log('[SocketException] $e');
      return Response(status: ResponseStatus.connectionError);
    } catch (e) {
      log('[UNKNOWN ERROR] $e');
      return Response(status: ResponseStatus.unknownError);
    }
  }

  Future<Response> _putRequests(Uri url, Map<String, dynamic> data) async {
    try {
      final http.Response response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      final result = Response.fromJson(responseData);

      log(responseData.toString());

      if (result.statusMessage == _success) {
        return result.copyWith(status: ResponseStatus.success);
      }
      return result.copyWith(status: ResponseStatus.failed);
    } on SocketException catch (e) {
      log('[SocketException] $e');
      return Response(status: ResponseStatus.connectionError);
    } catch (e) {
      log('[UNKNOWN ERROR] $e');
      return Response(status: ResponseStatus.unknownError);
    }
  }

  Future<Response> _deleteRequests(Uri url) async {
    try {
      final http.Response response = await http.delete(
        url,
        headers: _headers,
        // body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      final result = Response.fromJson(responseData);

      log(responseData.toString());

      if (result.statusMessage == _success) {
        return result.copyWith(status: ResponseStatus.success);
      }
      return result.copyWith(status: ResponseStatus.failed);
    } on SocketException catch (e) {
      log('[SocketException] $e');
      return Response(status: ResponseStatus.connectionError);
    } catch (e) {
      log('[UNKNOWN ERROR] $e');
      return Response(status: ResponseStatus.unknownError);
    }
  }

  Future<Response> login(String email, String password) async {
    final data = {'email': email.trim(), 'password': password.trim()};
    return await _postRequests(ApiEndpoints.login, data);
  }

  Future<Response> signup(
      String firstname, String lastname, String email, String password) async {
    final data = {
      'firstname': firstname.trim(),
      'lastname': lastname.trim(),
      'email': email.trim(),
      'password': password.trim(),
    };
    return await _postRequests(ApiEndpoints.signup, data);
  }

  Future<Response> forgotPassword(String email) async {
    final data = {'email': email.trim()};
    return await _postRequests(ApiEndpoints.forgotPassword, data);
  }

  Future<Response> confirmReset(
      String email, String otp, String password) async {
    final data = {
      'email': email.trim(),
      'otp': otp.trim(),
      'password': password.trim(),
    };
    return await _postRequests(ApiEndpoints.confirmReset, data);
  }

  Future<Response> sendOtp(String email) async {
    final data = {'email': email.trim()};
    return await _postRequests(ApiEndpoints.sendOtp, data);
  }

  Future<Response> verifyOtp(String email, String otp) async {
    final data = {'email': email.trim(), 'otp': otp.trim()};
    return await _postRequests(ApiEndpoints.verifyOtp, data);
  }

  Future<Response> editProfile(
      int id, String firstname, String lastname, String email) async {
    final Uri url = Uri.parse('${ApiEndpoints.editProfile}/$id');
    final data = {
      'firstname': firstname.trim(),
      'lastname': lastname.trim(),
      'email': email.trim(),
    };
    return await _putRequests(url, data);
  }

  Future<Response> changePassword(
      int id, String oldPassword, String newPassword) async {
    final Uri url = Uri.parse('${ApiEndpoints.changePassword}/$id');
    final data = {
      'oldPassword': oldPassword.trim(),
      'newPassword': newPassword.trim(),
    };
    return await _putRequests(url, data);
  }

  Future<Response> delete(int id) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse('${ApiEndpoints.delete}/$id'),
        headers: _headers,
      );

      final responseData = jsonDecode(response.body);
      final result = Response.fromJson(responseData);

      log(responseData.toString());

      if (result.statusMessage == _success) {
        return result.copyWith(status: ResponseStatus.success);
      }
      return result.copyWith(status: ResponseStatus.failed);
    } on SocketException catch (e) {
      log('[SocketException] $e');
      return Response(status: ResponseStatus.connectionError);
    } catch (e) {
      log('[UNKNOWN ERROR] $e');
      return Response(status: ResponseStatus.unknownError);
    }
  }

  Future<Response> categories() async {
    return await _getRequests(ApiEndpoints.categories);
  }

  // Future<Response> cart(int id) async {
  //   final url = Uri.parse('${ApiEndpoints.cart}/$id');
  //   return await _getRequests(url);
  // }

  Future<List<Cart>> cart(int id) async {
    final url = Uri.parse('${ApiEndpoints.cart}/$id');
    final response = await _getRequests(url);

    if (response.status == ResponseStatus.success) {
      return response.data.map<Cart>((data) => Cart.fromJson(data)).toList();
    }
    return [];
  }

  Future<Response> addCartProduct(int userId, int prodId, int qty) async {
    final data = {'user_id': userId, 'prod_id': prodId, 'qty': qty};
    return await _postRequests(Uri.parse(ApiEndpoints.cart), data);
  }

  Future<Response> updateCartProduct(
      int prodId, int userId, String action) async {
    final data = {'action': action};
    final url = Uri.parse('${ApiEndpoints.cart}/$prodId/$userId');
    return await _putRequests(url, data);
  }

  Future<Response> deleteCartProduct(int prodId, int userId) async {
    final url = Uri.parse('${ApiEndpoints.cart}/$prodId/$userId');
    return await _deleteRequests(url);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(StorageKey.userId);

    if (userId != null) {
      final url = Uri.parse('${ApiEndpoints.user}/$userId');
      final response = await _getRequests(url);

      if (response.status == ResponseStatus.success) {
        return User.fromJson(response.data.first);
      }
    }

    return null;
  }

  Future<Response> categoryProducts(int catId, int userId) async {
    final url = Uri.parse('${ApiEndpoints.products}/category/$catId/$userId');
    return await _getRequests(url);
  }

  Future<List<Product>> productsFuture(int userId) async {
    final url = Uri.parse('${ApiEndpoints.products}/$userId');
    final response = await _getRequests(url);

    if (response.status == ResponseStatus.success) {
      return response.data
          .map<Product>((data) => Product.fromJson(data))
          .toList();
    }
    return List.empty();
  }

  Future<List<ProductImage>> productsImagesFuture(int userId) async {
    final url = Uri.parse('${ApiEndpoints.productsImages}/$userId');
    final response = await _getRequests(url);

    if (response.status == ResponseStatus.success) {
      return response.data
          .map<ProductImage>((data) => ProductImage.fromJson(data))
          .toList();
    }
    return List.empty();
  }

  Future<List<Category>> categoriesFuture() async {
    final response = await _getRequests(ApiEndpoints.categories);

    if (response.status == ResponseStatus.success) {
      return response.data
          .map<Category>((data) => Category.fromJson(data))
          .toList();
    }
    return List.empty();
  }

  Future<Response> relatedProducts(int catId, int userId) async {
    final url = Uri.parse('${ApiEndpoints.products}/related/$catId/$userId');
    return await _getRequests(url);
  }

  Future<Response> like(int prodId, int userId) async {
    final data = {'prod_id': prodId, 'user_id': userId};
    return await _postRequests(ApiEndpoints.like, data);
  }

  Future<Response> getProductLikeStatus(int userId, int prodId) async {
    final url = Uri.parse('${ApiEndpoints.like}/$userId/$prodId');
    return await _getRequests(url);
  }

  Future<Response> getProductLikeCount(int prodId) async {
    final url = Uri.parse('${ApiEndpoints.like}/$prodId');
    return await _getRequests(url);
  }

  Future<Response> addAddress(
    int userId,
    String fullName,
    String address,
    String state,
    String city,
    String phoneNumber,
    String additionalPhoneNumber, [
    int? addressId,
  ]) async {
    final data = {
      'user_id': userId,
      'fullname': fullName,
      'address': address,
      'city': city,
      'state': state,
      'phone': phoneNumber,
      'additionalPhone': additionalPhoneNumber,
    };
    if (addressId == null) {
      final url = Uri.parse('${ApiEndpoints.addAddress}/$userId');
      return await _postRequests(url, data);
    } else {
      final url = Uri.parse('${ApiEndpoints.editAddress}/$addressId');
      return await _putRequests(url, data);
    }
  }

  Future<Response> setPrimaryAddress(int addressId, int userId) async {
    final url =
        Uri.parse('${ApiEndpoints.setPrimaryAddress}/$addressId/$userId');
    return await _putRequests(url, {});
  }

  Future<Response> deleteAddress(int addressId) async {
    final url = Uri.parse('${ApiEndpoints.deleteAddress}/$addressId');
    return await _deleteRequests(url);
  }

  Future<List<Address>> addressesFuture(int userId) async {
    final url = Uri.parse('${ApiEndpoints.address}/$userId');
    final response = await _getRequests(url);

    if (response.status == ResponseStatus.success) {
      return response.data
          .map<Address>((data) => Address.fromJson(data))
          .toList();
    }
    return List.empty();
  }

  Future<List<Order>> ordersFuture(int userId) async {
    final url = Uri.parse('${ApiEndpoints.orders}/$userId');
    final response = await _getRequests(url);

    if (response.status == ResponseStatus.success) {
      return response.data.map<Order>((data) => Order.fromJson(data)).toList();
    }
    return List.empty();
  }

  Future<Response> stateShippingFee(String state) async {
    final url = Uri.parse('${ApiEndpoints.stateShippingFee}/$state');
    return await _getRequests(url);
  }

  Future<Response> lagosCityShippingFee(String city) async {
    final url = Uri.parse('${ApiEndpoints.lagosCityShippingFee}/$city');
    return await _getRequests(url);
  }
}

final apiService = ApiService();
