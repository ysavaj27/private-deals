import 'package:flutter/material.dart';

import 'add_channel_partner_form.dart';

class PhoneAddChannelPartnerView extends StatelessWidget {
  const PhoneAddChannelPartnerView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SafeArea(child: AddChannelPartnerForm()));
}
