import 'package:flutter/material.dart';

import '../../features/home/widgets/student_event_search_delegate.dart';

Future<void> openGlobalHeaderSearch(BuildContext context) async {
  await showSearch<void>(
    context: context,
    delegate: StudentEventSearchDelegate(),
  );
}