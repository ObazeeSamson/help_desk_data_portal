import 'package:flutter/material.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final fromController = TextEditingController(text: '09/01/2024');
  final toController = TextEditingController(text: '09/30/2024');

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  void exportCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export prepared for download.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 48,
                ),
                child: Center(child: _exportCard()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportCard() {
    return Container(
      width: 440,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120c1b33),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xfff0f2f5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xff29364a),
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'CSV Data Export',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xff162238),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Download support requests and technician logs structured\nfor analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xff5e6470),
            ),
          ),
          const SizedBox(height: 28),
          _scopePanel(),
          const SizedBox(height: 25),
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: exportCsv,
              icon: const Icon(Icons.download, size: 16),
              label: const Text(
                'Export as CSV',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0b172c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scopePanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xfff4f6f8),
        border: Border.all(color: const Color(0xffe6e9ed)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'FILTER EXPORT SCOPE',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff7b818b),
                ),
              ),
              Text(
                '284 Records Selected',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1c283a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _dateField('START DATE (FROM)', fromController)),
              const SizedBox(width: 16),
              Expanded(child: _dateField('END DATE (TO)', toController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.info_outline, size: 13, color: Color(0xff78818e)),
              SizedBox(width: 5),
              Text(
                'Estimated payload: ~96 KB (CSV)',
                style: TextStyle(fontSize: 10, color: Color(0xff737b87)),
              ),
              Spacer(),
              Text(
                'UTF-8 • Encoded',
                style: TextStyle(fontSize: 9, color: Color(0xffb8bdc5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: .7,
            fontWeight: FontWeight.w700,
            color: Color(0xff7b818b),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 30,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 11, color: Color(0xff4a5260)),
            decoration: const InputDecoration(
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Color(0xff454d58),
              ),
              suffixIconConstraints: BoxConstraints(minWidth: 30),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffe1e4e8)),
                borderRadius: BorderRadius.zero,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffe1e4e8)),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff52647d)),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffe9edf1))),
      ),
      child: Row(
        children: [
          const Icon(Icons.dns_outlined, size: 16, color: Color(0xff29364a)),
          const SizedBox(width: 7),
          const Text(
            'ICT Help Desk',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xff29364a),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            color: const Color(0xfff1f3f5),
            child: const Text(
              'DATA PORTAL',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: .8,
                color: Color(0xff737b87),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'AUTHORIZED STAFF ONLY',
            style: TextStyle(
              fontSize: 8,
              letterSpacing: .8,
              color: Color(0xff737b87),
            ),
          ),
        ],
      ),
    );
  }
}
