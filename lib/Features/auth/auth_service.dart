import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'institutional_db.dart';
import 'user.dart';


//tentei fazer alterações aqui para que depois que o usuário verifica-se
//o email o popup de encontrado aparece, mas acho que devido a limitações do firebase 
//isso não está sendo posivel no momento, por isso vc pode deixar esse arquivo na main sem as auterações
//que fiz
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> cadastrarUsuario({
    required String matricula,
    required String email,
    required String senha,
  }) async {
    // Validação institucional permanece igual
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

      // Envia o e-mail de verificação
      await firebaseUser.sendEmailVerification();

      // LOGOUT FORÇADO: O usuário é deslogado logo após o cadastro 
      // para que ele só acesse o app após clicar no link do e-mail.
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
      // 1. RECARREGA o estado do usuário do servidor Firebase
      await user.reload();
      
      // 2. Atualiza a referência local após o recarregamento
      user = _auth.currentUser;

      // 3. TRAVA DE SEGURANÇA: Se não estiver verificado, desloga e impede o login
      if (!user!.emailVerified) {
        await _auth.signOut();
        throw Exception(
          'Por favor, confirme seu e-mail institucional para ativar a conta antes de fazer login.',
        );
      }
    }
    return user;
  }

  Future<void> deslogar() async {
    await _auth.signOut();
  }
}