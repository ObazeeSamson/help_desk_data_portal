import 'package:flutter/material.dart';

class PageHeader {
  PageHeader._();


 static Widget pageIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submitted Requests & Logs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff101c30),
                ),
              ),
              SizedBox(height: 5),
              // Text(
              //   'Internal registry of ICT support submissions, technician diagnostics, and resolution status structured for analysis.',
              //   style: TextStyle(
              //     fontSize: 14,
              //     height: 1.5,
              //     color: Color(0xff617089),
              //   ),
              // ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: downloadCsv,
          icon: const Icon(Icons.download, size: 18),
          label: const Text(
            'Export Data',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            // backgroundColor: const Color.fromARGB(255, 3, 50, 124),
            // foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: fetchRequests,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text(
            'Refresh Data',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            // backgroundColor: const Color(0xff09162b),
            // foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
