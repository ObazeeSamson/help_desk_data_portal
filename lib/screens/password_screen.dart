import 'package:flutter/material.dart';
import 'package:help_desk_data_portal/screens/request_screen.dart';
import 'package:http/http.dart' as http;

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> accessPortal() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your access password to continue.'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://qvxdfzcq-80.uks1.devtunnels.ms/help_desk_request/verify_password.php',
        ),
        body: {'password': password},
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == 'success') {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const RequestScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect access password.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to connect to the server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error. Check that Apache is running.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 60,
                  ),
                  child: Center(child: _accessCard()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accessCard() {
    return Container(
      width: 500,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x100c1b33),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   color: const Color(0xffeef0f2),
          //   child: const Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.lock, size: 10, color: Color(0xff26354a)),
          //       SizedBox(width: 5),
          //       Text(
          //         ' ICT HELP DESK',
          //         style: TextStyle(
          //           fontSize: 8,
          //           letterSpacing: 1,
          //           color: Color(0xff526071),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 14),
          const Text(
            'ICT Help Desk Data Portal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xff101c30),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Enter the access password to continue.',
            style: TextStyle(fontSize: 13, color: Color(0xff6e7784)),
          ),
          const SizedBox(height: 26),

          const SizedBox(height: 7),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            onSubmitted: (_) => accessPortal(),
            style: const TextStyle(fontSize: 10, color: Color(0xff3c4a5d)),
            decoration: InputDecoration(
              hintText: 'Enter access password',
              hintStyle: const TextStyle(
                fontSize: 10,
                color: Color(0xff8993a0),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 14,
                color: Color(0xff667589),
              ),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 14,
                  color: const Color(0xff667589),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffe4e7eb)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff26364e)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: accessPortal,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff09162b),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                'Access Portal',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            color: const Color(0xfff1f3f5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 13,
                      color: Color(0xff42647a),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Restricted to authorized CUS ICT personnel only.\nSubmissions routed from the mobile help-desk app.',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.4,
                          color: Color(0xff5e6d7e),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SYS-NODE: CUS-PROD-04',
                      style: TextStyle(
                        fontSize: 7,
                        letterSpacing: .7,
                        color: Color(0xff657285),
                      ),
                    ),
                    Text(
                      'TLS 1.3 / AUTH REQ',
                      style: TextStyle(
                        fontSize: 7,
                        letterSpacing: .7,
                        color: Color(0xff657285),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
