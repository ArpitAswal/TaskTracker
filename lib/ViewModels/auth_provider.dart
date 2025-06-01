import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../Models/auth_model.dart';
import '../NetworkRequests/node_server_repository.dart';
import '../Service/initialization_service.dart';
import '../Utils/constants/app_constants.dart';
import '../Utils/helpers/dynamic_context_widgets.dart';

class AuthenticateProvider extends ChangeNotifier {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late Box<AuthenticateModel> _userAuth;
  late AuthenticateModel _authUser;
  late InitializationService _service;
  late DynamicContextWidgets _dynamic;

  bool _loginLoading = false;
  bool _isObscured = true;
  bool _isChecked = false;
  bool _emailFocus = false;
  bool _passFocus = false;
  bool _adminFocus = false;
  bool _notOnboarding = true;
  String _selectedRole = "Select";
  int _selectedHour = 1;

  String? _error;
  UpdateSuccess userInfo = UpdateSuccess.initial;
  NetworkStatus netStatus = NetworkStatus.initial;

  bool get loginLoading => _loginLoading;
  bool get isObscured => _isObscured;
  bool get isChecked => _isChecked;
  bool get emailFocus => _emailFocus;
  bool get passFocus => _passFocus;
  bool get adminFocus => _adminFocus;
  bool get notOnboarding => _notOnboarding;
  String get selectedRole => _selectedRole;
  int get selectedHour => _selectedHour;
  String? get error => _error;
  AuthenticateModel get authUser => _authUser;

  AuthenticateProvider() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _userAuth = Hive.box<AuthenticateModel>(HiveDatabaseConstants.authHive);
    _service = InitializationService();
    _authUser = AuthenticateModel(name: "", email: "", id: "", role: "");
    _dynamic = DynamicContextWidgets();
    getUserPreference();
  }

  void toggleObscure() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

  void toggleRememberMe() {
    _isChecked = !_isChecked;
    notifyListeners();
  }

  void changeRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void emailFocusChange(bool hasFocus) {
    _emailFocus = hasFocus;
    notifyListeners();
  }

  void passFocusChange(bool hasFocus) {
    _passFocus = hasFocus;
    notifyListeners();
  }

  void adminFocusChange(bool hasFocus) {
    _adminFocus = hasFocus;
    notifyListeners();
  }

  void setOnboarding(bool value) {
    _notOnboarding = value;
    notifyListeners();
  }

  void setSelectedHour(int value) {
    _selectedHour = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _loginLoading = true;
      _error = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _error = "Login failed: ${e.toString()}";
      return false;
    } finally {
      _loginLoading = false;
      notifyListeners();
    }
  }

  // Register User (Admin/User)
  Future<bool> register(String email, String password, String admin) async {
    try {
      _loginLoading = true;
      _error = null;
      notifyListeners();
      if (admin.isNotEmpty && !await isAdmin(admin)) {
        _error = "Admin Key is not valid";
        return false;
      }
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      setOnboarding(false);
      saveUserPreference(
          userCred: userCredential, email, password, selectedRole);
      changeRole("Select");
      return true;
    } catch (e) {
      _error = "Register failed: ${e.toString()}";
      return false;
    } finally {
      _loginLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _loginLoading = true;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
      _dynamic.showSnackbar("Password reset link sent to your email");
      return true;
    } catch (e) {
      _error = "Password reset failed: ${e.toString()}";
      return false;
    } finally {
      _loginLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserPreference(String email, String pass, String role,
      {required UserCredential userCred}) async {
    Box<bool> settingBox = Hive.box<bool>(HiveDatabaseConstants.permissionHive);
    settingBox.put(HiveDatabaseConstants.permissionHiveAsk, false);
    final authData = AuthenticateModel(
      name: null,
      id: userCred.user!.uid,
      email: email,
      role: role,
    );
    await _userAuth.put(authData.id, authData);
    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userCred.user!.uid)
        .set({
      "user_name": null,
      "user_id": userCred.user!.uid,
      "user_email": email,
      "user_password": pass,
      "user_role": role,
    });
  }

  Future<void> getUserPreference() async {
    if (_userAuth.values.isNotEmpty) {
      final list = _userAuth.values
          .where(
            (user) => user.id == _auth.currentUser?.uid,
          )
          .toList();
      if (list.isNotEmpty) {
        _authUser = list.first;
      }
    } else if (_authUser.id.isEmpty) {
      DocumentSnapshot snapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(_auth.currentUser?.uid)
          .get();
      if (snapshot.exists && _auth.currentUser != null) {
        _authUser = AuthenticateModel(
            name: snapshot['user_name'],
            email: snapshot['user_email'],
            id: snapshot['user_id'],
            role: snapshot['user_role']);
        _userAuth.put(_authUser.id, _authUser);
      } else if (_auth.currentUser != null) {
        _dynamic.showSnackbar("User Information does not exist");
      }
    }
    notifyListeners();
  }

  Future<void> deleteUserAccount(String email, String pass) async {
    try {
      String? uid = _auth.currentUser?.uid;

      if (uid != null) {
        // Re-authenticate the user before deleting the account
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: pass, // Ask the user for their password
        );

        await _auth.currentUser!.reauthenticateWithCredential(credential);

        //remove WorkManager Tasks
        _service.cancelWorkManagerTasks();

        // Delete user from Firestore
        await _firestore
            .collection(FirestoreConstants.usersCollection)
            .doc(uid)
            .delete();
        await _firestore
            .collection(FirestoreConstants.tokenCollection)
            .doc(uid)
            .delete();

        // Remove hive values
        Box<bool> themeBox = Hive.box<bool>(HiveDatabaseConstants.themeHive);
        themeBox.put(_auth.currentUser!.uid, false);
        // Remove user from Hive storage
        await _userAuth.delete(uid);
        // Delete the user from Firebase Authentication
        await _auth.currentUser!.delete();
        // sign out and navigate to login screen
        _dynamic.showSnackbar("Delete the account successfully");
        await signOut();
      }
    } catch (e) {
      _dynamic.showSnackbar("Error: ${e.toString()}");
    }
  }

  Future<void> updateUser(String name, String email) async {
    try {
      userInfo = UpdateSuccess.loading;
      notifyListeners();
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(_auth.currentUser!.uid)
          .update({'user_name': name, 'user_email': email});
      userInfo = UpdateSuccess.success;
      notifyListeners();
      _authUser = AuthenticateModel(
          name: name, id: _authUser.id, email: email, role: _authUser.role);
      _userAuth.put(_authUser.id, _authUser);
      _dynamic.showSnackbar("Update Info Successfully");
    } catch (e) {
      userInfo = UpdateSuccess.fail;
      _dynamic.showSnackbar("Error: error updating user, ${e.toString()}");
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      setOnboarding(true);
      await _auth.signOut();
    } catch (e) {
      _dynamic.showSnackbar("Sign out failed: ${e.toString()}");
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamSnapshot(
      [String col = FirestoreConstants.usersCollection, String? docID]) {
    return FirebaseFirestore.instance
        .collection(col)
        .doc(docID ?? _auth.currentUser?.uid)
        .snapshots();
  }

  Future<void> verifyAccount(
      {required String email,
      required String value,
      required bool update}) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(_auth.currentUser!.uid)
          .get();
      if (snapshot.exists && snapshot['user_email'] == email) {
        if (!update && snapshot['user_password'] == value) {
          deleteUserAccount(email, value);
        } else if (update) {
          updateUser(value, email);
        } else {
          _dynamic.showSnackbar("Failed: enter the valid information");
        }
      } else {
        _dynamic.showSnackbar(
            "You can not perform this operation because of privacy");
      }
    } catch (e) {
      _dynamic.showSnackbar("Error: ${e.toString()}");
    }
  }

  Future<bool> isAdmin(String admin) async {
    DocumentSnapshot snapshot = await _firestore
        .collection(FirestoreConstants.adminCollection)
        .doc(FirestoreConstants.authAdmin)
        .get();
    if (snapshot.exists && snapshot['Key'] == admin) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> sendNotification(
      {required String title, required String body}) async {
    netStatus = NetworkStatus.loading;
    notifyListeners();
    try {
      final req = await NodeServerRepository()
          .sendNotification(title: title, body: body);
      netStatus = NetworkStatus.success;
      _dynamic.showSnackbar(req);
    } catch (e) {
      netStatus = NetworkStatus.fail;
      _dynamic.showSnackbar(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void changePassword({required String pass}) async {
    DocumentSnapshot snapshot = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(_auth.currentUser?.uid)
        .get();
    if (snapshot.exists && snapshot['user_password'] != pass) {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(_auth.currentUser?.uid)
          .update({'user_password': pass});
    }
  }
}

enum UpdateSuccess { initial, loading, success, fail }

enum NetworkStatus { initial, loading, success, fail }
