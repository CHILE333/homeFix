import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                controller: _authController.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email required';
                  if (!value.contains('@')) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _authController.passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password required';
                  if (value.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              Obx(() => _authController.errorMessage.value.isNotEmpty
                  ? Text(
                      _authController.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    )
                  : const SizedBox()),

              // Login Button
              Obx(() => ElevatedButton(
                onPressed: _authController.isLoading.value
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await _authController.login();
                        }
                      },
                child: _authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('LOGIN'),
              )),
              const SizedBox(height: 16),

              // Register Link
              TextButton(
                onPressed: () => Get.offNamed('/register'),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}