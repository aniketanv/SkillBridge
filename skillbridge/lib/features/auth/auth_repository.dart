import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/models/user_model.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        
        // Retroactively give existing users 20 credits if they don't have the field
        if (!data.containsKey('credits')) {
          await _firestore.collection('users').doc(user.uid).update({'credits': 20});
          data['credits'] = 20;
        }

        return UserModel.fromMap(data, doc.id);
      }
    }
    return null;
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Create user in firestore
    UserModel userModel = UserModel(
      id: cred.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(cred.user!.uid).set(userModel.toMap());
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // The user canceled the sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      UserCredential cred = await _auth.signInWithCredential(credential);
      
      // Check if user exists in firestore, if not create them
      final userDoc = await _firestore.collection('users').doc(cred.user!.uid).get();
      if (!userDoc.exists) {
        UserModel userModel = UserModel(
          id: cred.user!.uid,
          name: cred.user!.displayName ?? 'User',
          email: cred.user!.email ?? '',
          profilePhotoUrl: cred.user!.photoURL ?? '',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(userModel.toMap());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        await _googleSignIn.signOut();
        throw Exception('account-exists-with-different-credential');
      }
      rethrow;
    }
  }

  Future<void> linkWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    if (_auth.currentUser != null && googleUser.email != _auth.currentUser!.email) {
      await _googleSignIn.signOut();
      throw Exception("Google account email does not match your current registered email.");
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.currentUser?.linkWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

@riverpod
Stream<User?> authStateChange(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChange;
}

@riverpod
Future<UserModel?> currentUser(Ref ref) {
  return ref.watch(authRepositoryProvider).getCurrentUserData();
}
