import 'package:flutter/material.dart';

import '../../Components/buttons/primary_button.dart';
import '../../Components/dialogs/success_dialog.dart';
import '../../Components/inputs/app_text_field.dart';
import '../../Components/inputs/password_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController(
    text: "Pedro Alves Santana de Souza",
  );

  final matriculaController = TextEditingController(text: "202312345");

  final passwordController = TextEditingController(text: "12345678");

  String savedName = "Pedro Alves Santana de Souza";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Editar Perfil"),

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,

                children: [
                  Container(
                    width: 140,
                    height: 140,

                    decoration: const BoxDecoration(
                      color: Color(0xFF0D4DB3),
                      shape: BoxShape.circle,
                    ),
                  ),

                  Positioned(
                    bottom: 4,
                    right: -2,

                    child: GestureDetector(
                      onTap: () {
                        print("Alterar foto");
                      },

                      child: Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          shape: BoxShape.circle,

                          border: Border.all(color: Colors.black12, width: 2),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),

            AppTextField(hint: "Nome", controller: nameController),

            const SizedBox(height: 24),

            const Text(
              "Matrícula",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),

            AppTextField(
              hint: "Matrícula",
              controller: matriculaController,
              enabled: false,
            ),

            const SizedBox(height: 24),

            const Text(
              "Senha Atual",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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

              onPressed: () {
                setState(() {
                  savedName = nameController.text;
                });

                SuccessDialog.show(
                  context,

                  title: "Perfil atualizado",

                  message: "As alterações foram salvas com sucesso.",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
