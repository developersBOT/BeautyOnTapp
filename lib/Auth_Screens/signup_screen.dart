import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'; // Import the package
import '../../services/auth/signup_service.dart'; // Adjust path if needed

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _formKey       = GlobalKey<FormState>();

  bool _obscure = true;
  bool _agree = false;
  bool _loading = false;

  PhoneNumber? _phoneNumber;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.15), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final email = v.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Invalid email';
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_agree) {
      Get.snackbar('Error', 'You must agree to Terms',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final res = await SignUpService.signUp(
        firstName: _firstNameCtrl.text,
        lastName:  _lastNameCtrl.text,
        email:     _emailCtrl.text,
        password:  _passwordCtrl.text,
        phone:     _phoneNumber?.phoneNumber ?? '', // Pass the phone number
      );

      // If successful, show a success message
      final msg = res['message'] ?? 'Account created successfully';
      Get.snackbar('Success', msg, snackPosition: SnackPosition.BOTTOM);
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed('/login');
    } catch (e) {
      // Show error message from the exception
      print("Error during signup: $e");  // Debugging print statement
      Get.snackbar('Signup failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double logoWidth  = size.width * 0.63;
    final double logoHeight = logoWidth * (138 / 245);
    final double gap = size.height * 0.018;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.07,
            vertical: size.height * 0.03,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: gap * 1.2),
                Center(
                  child: SizedBox(
                    width: logoWidth,
                    height: logoHeight,
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                ),
                SizedBox(height: gap * 1.2),

                const Text('Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),
                const SizedBox(height: 6),
                const Text(
                  'Welcome Back! Enter Your Account Details',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400, color: Colors.black87),
                ),
                SizedBox(height: gap * 1.3),

                // First Name field
                TextFormField(
                  controller: _firstNameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration('First Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: gap),

                // Last Name field
                TextFormField(
                  controller: _lastNameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration('Last Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: gap),

                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration('Email Address'),
                  validator: _emailValidator,
                ),
                SizedBox(height: gap),

                // Password field
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  decoration: _fieldDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.black54),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: gap),

                // Phone Number field with country code picker
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    setState(() {
                      _phoneNumber = number;
                    });
                  },
                  onInputValidated: (isValid) {
                    // You can add validation here if needed
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET, // Use bottom sheet for country code selection
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: _phoneNumber,
                  textFieldController: _phoneCtrl,
                  formatInput: false,
                  inputDecoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.15), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                ),

                SizedBox(height: gap),

                // Terms and conditions agreement
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.95,
                      child: Checkbox(
                        value: _agree,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                        shape: const CircleBorder(),
                        side: BorderSide(color: Colors.black.withOpacity(0.5)),
                        activeColor: Colors.black,
                        checkColor: Colors.white,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'I Agree with Terms & Conditions And Privacy Policy',
                        style: TextStyle(fontSize: 12.5, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),

                // Submit button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign Up'),
                  ),
                ),

                SizedBox(height: size.height * 0.12),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: Colors.black87, fontSize: 13.5)),
                      GestureDetector(
                        onTap: () => Get.offAllNamed('/login'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: gap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
