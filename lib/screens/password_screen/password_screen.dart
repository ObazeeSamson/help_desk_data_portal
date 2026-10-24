import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/screens/request_screen/request_screen.dart';
import 'package:help_desk_data_portal/services/help_desk_service.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Authentication gatekeeper screen for the ICT Help Desk Data Portal.
///
/// Prompts users for an authorized administrative access password before
/// granting entry to the main request management dashboard.
class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  /// Controller managing the text input for the portal password.
  final _passwordController = TextEditingController();

  /// Toggles visibility of password characters in the text input field.
  bool _obscure = true;

  /// Indicates whether the verification network request is currently active.
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates the input and verifies the password against the backend API.
  ///
  /// On success: Navigates to [RequestScreen].
  /// On failure: Displays an error snackbar with feedback.
  Future<void> _accessPortal() async {
    final password = _passwordController.text.trim();

    // Prevent submitting empty password strings
    if (password.isEmpty) {
      _showSnack('Please enter your access password.');
      return;
    }

    setState(() => _loading = true);

    try {
      final success = await HelpDeskService.verifyPassword(password);
      if (!mounted) return;

      if (success) {
        // Navigate to the main requests dashboard
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const RequestScreen()));
      } else {
        _showSnack('Incorrect access password.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        'Connection error. Check that the backend server is reachable.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Displays floating feedback notification snackbars for success or error states.
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top green accent line for enterprise brand polish
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: Container(color: AppColors.primary),
          ),

          // Centered login card and footer container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCard(),
                    const SizedBox(height: 24),
                    // Copyright & version footer
                    Text(
                      'ICT Help Desk Portal © 2024',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the elevated modal card containing header, form, and notice banner.
  Widget _buildCard() {
    return Container(
      width: 450,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Card Header (Brand badge, Title, Subtitle) ────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand icon and title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ICT HELP DESK',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'DATA PORTAL',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                Text(
                  'Enter your access password to view the request dashboard.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── Form Body (Password input field & Access button) ──────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  // Allow pressing Enter on the keyboard to submit
                  onSubmitted: (_) => _accessPortal(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter access password',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Submit button with progress indicator when loading
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _accessPortal,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Access Portal',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Footer Notice (Authorization warning) ─────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 16),
            decoration: const BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Restricted to authorized ICT personnel only. '
                    'Submissions are routed from the mobile help-desk app.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
