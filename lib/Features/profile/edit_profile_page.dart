import 'package:flutter/material.dart';

import 'package:campus_guide/Features/auth/auth_service.dart';
import 'package:campus_guide/Features/auth/user.dart';
import 'package:campus_guide/components/buttons/primary_button.dart';
import 'package:campus_guide/components/dialogs/error_dialog.dart';
import 'package:campus_guide/components/dialogs/success_dialog.dart';
import 'package:campus_guide/components/inputs/app_text_field.dart';
import 'package:campus_guide/components/inputs/password_field.dart';

class EditProfilePage extends StatefulWidget {
  final AppUser? user;

  const EditProfilePage({super.key, this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const String _profileImageAsset = 'imagens/Icone_perfil.png';

  final AuthService _authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(
    text: "********",
  );

  bool loadingUser = true;
  bool saving = false;
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    matriculaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = widget.user ?? await _authService.buscarUsuarioAtual();

      if (!mounted) return;

      setState(() {
        currentUser = user;
        nameController.text = user?.name ?? '';
        matriculaController.text = user?.matricula ?? '';
        loadingUser = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadingUser = false;
      });

      ErrorDialog.show(
        context,
        title: "Erro ao carregar perfil",
        message: _cleanError(error),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      await _authService.atualizarPerfil(name: nameController.text);

      if (!mounted) return;

      SuccessDialog.show(
        context,
        title: "Perfil atualizado",
        message: "As alterações foram salvas com sucesso.",
        buttonText: "Voltar",
        onPressed: () {
          Navigator.pop(context, true);
        },
      );
    } catch (error) {
      if (!mounted) return;

      ErrorDialog.show(
        context,
        title: "Erro ao atualizar",
        message: _cleanError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void _showFixedPhotoMessage() {
    ErrorDialog.show(
      context,
      title: "Foto padrão",
      message: "A foto do perfil é fixa nesta versão do aplicativo.",
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loadingUser
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildAvatar(),
                          Positioned(
                            bottom: 4,
                            right: -2,
                            child: GestureDetector(
                              onTap: saving ? null : _showFixedPhotoMessage,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 28,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Nome",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(hint: "Nome", controller: nameController),
                    const SizedBox(height: 24),
                    const Text(
                      "Matrícula",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      hint: "Matrícula",
                      controller: matriculaController,
                      enabled: false,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Senha",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PasswordField(
                      hint: "Senha",
                      controller: passwordController,
                      enabled: false,
                    ),
                    const Spacer(),
                    PrimaryButton(
                      text: "Salvar Alterações",
                      loading: saving,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF0D4DB3),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(_profileImageAsset, fit: BoxFit.cover),
    );
  }
}
