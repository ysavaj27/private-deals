import 'package:flutter/material.dart';

import 'add_channel_partner_form.dart';

class DesktopAddChannelPartnerView extends StatelessWidget {
  const DesktopAddChannelPartnerView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SafeArea(child: AddChannelPartnerForm()));
}
