import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  final IconData headerIcon;
  final List<Color> headerIconGradient;
  final Color headerIconGlow;
  final String title;
  final String smalltitle;
  final Color topGlowColor;
  final Color bottomGlowColor;
  final bool glowTop;
  final Color borderColor;
  final String submitButtonText;
  final List<Color> submitButtonGradient;
  final Color submitButtonGlow;
  final String googleText;
  final String footerText;
  final String linkText;
  final Color linkColor;
  final String message;
  final Future<void> Function(String email, String password)? onSubmit;
  final Future<void> Function()? onGoogleAuth;
  final VoidCallback? linkTap;

  const AuthPage({
    super.key,
    required this.headerIcon,
    required this.headerIconGradient,
    required this.headerIconGlow,
    required this.title,
    required this.smalltitle,
    required this.topGlowColor,
    required this.bottomGlowColor,
    required this.glowTop,
    required this.borderColor,
    required this.submitButtonText,
    required this.submitButtonGradient,
    required this.submitButtonGlow,
    required this.googleText,
    required this.footerText,
    required this.linkText,
    required this.linkColor,
    required this.message,
    this.onSubmit,
    this.onGoogleAuth,
    this.linkTap,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.message)));
      return;
    }

    if (widget.onSubmit != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onSubmit!(email, password);
      } catch (_) {
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _googleAuth() async {
    if (widget.onGoogleAuth != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onGoogleAuth!();
      } catch (_) {
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      body: Stack(
        children: [
          // Positioned(
          //   top: -80,
          //   left: widget.glowTop ? -60 : null,
          //   right: widget.glowTop ? null : -60,
          //   child: Container(
          //     width: 260,
          //     height: 260,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.transparent,
          //       boxShadow: [
          //         BoxShadow(
          //           color: widget.topGlowColor.withOpacity(0.2),
          //           blurRadius: 100,
          //           spreadRadius: 20,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // Positioned(
          //   bottom: -80,
          //   right: widget.glowTop ? -60 : null,
          //   left: widget.glowTop ? null : -60,
          //   child: Container(
          //     width: 260,
          //     height: 260,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.transparent,
          //       boxShadow: [
          //         BoxShadow(
          //           color: widget.bottomGlowColor.withOpacity(0.18),
          //           blurRadius: 100,
          //           spreadRadius: 20,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon
                      // Center(
                      // child: Container(
                      //   height: 72,
                      //   width: 72,
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     gradient: LinearGradient(
                      //       colors: widget.headerIconGradient,
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         // color: widget.headerIconGlow.withOpacity(0.4),
                      //         blurRadius: 20,
                      //         spreadRadius: 2,
                      //       ),
                      //     ],
                      //   ),
                      //   // child: Icon(
                      //   //widget.headerIcon,
                      //   //size: 36,
                      //   //color: Colors.white,
                      //   //),
                      // ),
                      // ),
                      const SizedBox(height: 24),

                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.smalltitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13151E),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ).withOpacity(1),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Email Field
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                // prefixIcon: Icon(
                                //   Icons.alternate_email_rounded,
                                //   color: widget.borderColor,
                                //   size: 20,
                                // ),
                                filled: true,
                                fillColor: const Color(0xFF0B0C10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: widget.borderColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                // prefixIcon: Icon(
                                //   Icons.lock_outline_rounded,
                                //   color: widget.borderColor,
                                //   size: 20,
                                // ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0B0C10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: widget.borderColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: widget.submitButtonGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.submitButtonGlow.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  widget.submitButtonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF13151E),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isLoading ? null : _googleAuth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      color: Color(0xFFEA4335),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.googleText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.footerText,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.linkTap,
                            child: Text(
                              widget.linkText,
                              style: TextStyle(
                                color: widget.linkColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
