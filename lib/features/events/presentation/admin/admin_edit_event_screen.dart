import 'package:flutter/material.dart';

import '../../domain/event_form_initial_data.dart';
import 'admin_create_event_screen.dart';

class EditEventScreen extends StatelessWidget {
  final EventFormInitialData initialData;

  const EditEventScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) {
    return CreateEventScreen(initialData: initialData);
  }
}
