import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'institutional_db.dart';
import 'user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> cadastrarUsuario({
    required String matricula,
    required String email,
    required String senha,
  }) async {
    final record = InstitutionalDB.validate(matricula: matricula, email: email);

    final queryMatricula = await _db
        .collection('usuarios')
        .where('matricula', isEqualTo: matricula.trim())
        .get();

    if (queryMatricula.docs.isNotEmpty) {
      throw Exception('Esta matrícula já está vinculada a uma conta.');
    }

    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      AppUser novoUsuario = AppUser(
        id: firebaseUser.uid,
        name: record.name,
        email: record.email,
        matricula: record.matricula,
        role: record.role,
      );

      await _db
          .collection('usuarios')
          .doc(firebaseUser.uid)
          .set(novoUsuario.toMap());

      await firebaseUser.sendEmailVerification();

      await _auth.signOut();
    }
  }

  Future<User?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    User? user = userCredential.user;

    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      if (!user!.emailVerified) {
        await _auth.signOut();
        throw Exception(
          'Por favor, confirme seu e-mail para ativar a conta antes de fazer login.',
        );
      }
    }
    return user;
  }

  Future<void> deslogar() async {
    await _auth.signOut();
  }
}
