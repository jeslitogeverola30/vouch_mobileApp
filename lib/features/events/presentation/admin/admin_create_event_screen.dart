import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/event_admin_service.dart';
import '../../data/event_image_upload_service.dart';
import '../../domain/event_creation_validators.dart';
import '../../domain/event_date_time_formatters.dart';
import '../../domain/event_form_initial_data.dart';

class CreateEventScreen extends StatefulWidget {
  final EventFormInitialData? initialData;

  const CreateEventScreen({super.key, this.initialData});

  bool get isEditMode => initialData != null;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _eventDateController;
  late final TextEditingController _timeInController;
  late final TextEditingController _timeOutController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _fullDescController;

  File? _selectedImage;
  DateTime? _selectedEventDate;
  TimeOfDay? _timeInStart;
  TimeOfDay? _timeInEnd;
  TimeOfDay? _timeOutStart;
  TimeOfDay? _timeOutEnd;
  bool _isLoadingImage = false;
  bool _isSubmitting = false;
  bool _isObligatory = false;
  String _existingImageUrl = '';

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _fieldBorder = Color(0xFFDAE2EF);
  static const Color _fieldFill = Color(0xFFF8FAFD);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _titleText = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _eventDateController = TextEditingController();
    _timeInController = TextEditingController();
    _timeOutController = TextEditingController();
    _shortDescController = TextEditingController();
    _fullDescController = TextEditingController();

    _applyInitialData();
  }

  void _applyInitialData() {
    final initialData = widget.initialData;
    if (initialData == null) {
      return;
    }

    _titleController.text = initialData.name;
    _locationController.text = initialData.location;
    _shortDescController.text = initialData.shortDescription;
    _fullDescController.text = initialData.fullDescription;

    _selectedEventDate = DateTime(
      initialData.eventDate.year,
      initialData.eventDate.month,
      initialData.eventDate.day,
    );
    _eventDateController.text = _formatDate(_selectedEventDate!);

    _timeInStart = _minutesToTimeOfDay(initialData.timeInStartMinutes);
    _timeInEnd = _minutesToTimeOfDay(initialData.timeInEndMinutes);
    _timeOutStart = _minutesToTimeOfDay(initialData.timeOutStartMinutes);
    _timeOutEnd = _minutesToTimeOfDay(initialData.timeOutEndMinutes);

    _timeInController.text =
        '${_formatTime(_timeInStart!)} - ${_formatTime(_timeInEnd!)}';
    _timeOutController.text =
        '${_formatTime(_timeOutStart!)} - ${_formatTime(_timeOutEnd!)}';

    _isObligatory = initialData.isMandatory;
    _existingImageUrl = initialData.imageUrl.trim();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _eventDateController.dispose();
    _timeInController.dispose();
    _timeOutController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isLoadingImage) {
      return;
    }

    try {
      setState(() => _isLoadingImage = true);

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null || !mounted) {
        return;
      }

      final file = File(pickedFile.path);
      final fileSizeInBytes = file.lengthSync();

      if (!EventCreationValidators.isFileSizeWithinLimitBytes(
        fileSizeInBytes,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size exceeds 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!EventCreationValidators.isSupportedImageExtension(pickedFile.path)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only JPG and PNG files are supported'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _selectedImage = file);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking image'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    final initialDate = _selectedEventDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _royalBlue,
              onPrimary: Colors.white,
              onSurface: _royalBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedEventDate = pickedDate;
      _eventDateController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _pickTimeInWindow() async {
    final now = TimeOfDay.now();
    final start = await showTimePicker(
      context: context,
      initialTime: _timeInStart ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _royalBlue,
              onPrimary: Colors.white,
              onSurface: _royalBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (start == null || !mounted) {
      return;
    }

    final startInMinutes = _timeToMinutes(start);
    final suggestedEnd = EventCreationValidators.addMinutes(
      hour: start.hour,
      minute: start.minute,
      minutes: 15,
    );
    final endInitial = TimeOfDay(
      hour: suggestedEnd.hour,
      minute: suggestedEnd.minute,
    );

    final end = await showTimePicker(
      context: context,
      initialTime: _timeInEnd ?? endInitial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _royalBlue,
              onPrimary: Colors.white,
              onSurface: _royalBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (end == null || !mounted) {
      return;
    }

    if (_timeToMinutes(end) <= startInMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time in end must be later than start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _timeInStart = start;
      _timeInEnd = end;
      _timeInController.text = '${_formatTime(start)} - ${_formatTime(end)}';

      if (_timeOutStart != null &&
          _timeToMinutes(_timeOutStart!) <= _timeToMinutes(end)) {
        _timeOutStart = null;
        _timeOutEnd = null;
        _timeOutController.clear();
      }
    });
  }

  Future<void> _pickTimeOut() async {
    final startInitial = _timeOutStart ?? _timeInEnd ?? TimeOfDay.now();
    final start = await showTimePicker(
      context: context,
      initialTime: startInitial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _royalBlue,
              onPrimary: Colors.white,
              onSurface: _royalBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (start == null || !mounted) {
      return;
    }

    if (_timeInEnd != null &&
        _timeToMinutes(start) <= _timeToMinutes(_timeInEnd!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time out start must be after time in end'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final startInMinutes = _timeToMinutes(start);
    final suggestedEnd = EventCreationValidators.addMinutes(
      hour: start.hour,
      minute: start.minute,
      minutes: 15,
    );
    final endInitial = TimeOfDay(
      hour: suggestedEnd.hour,
      minute: suggestedEnd.minute,
    );

    final end = await showTimePicker(
      context: context,
      initialTime: _timeOutEnd ?? endInitial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _royalBlue,
              onPrimary: Colors.white,
              onSurface: _royalBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (end == null || !mounted) {
      return;
    }

    if (_timeToMinutes(end) <= startInMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time out end must be later than start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _timeOutStart = start;
      _timeOutEnd = end;
      _timeOutController.text = '${_formatTime(start)} - ${_formatTime(end)}';
    });
  }

  Future<void> _handleCreateEvent() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    if (_selectedImage == null && _existingImageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event banner'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedEventDate == null ||
        _timeInStart == null ||
        _timeInEnd == null ||
        _timeOutStart == null ||
        _timeOutEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the event schedule'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var imageUrl = _existingImageUrl;
      if (_selectedImage != null) {
        imageUrl = await EventImageUploadService.uploadEventImage(
          imageFile: _selectedImage!,
        );
      }

      if (imageUrl.trim().isEmpty) {
        throw StateError('Please select an event banner');
      }

      if (widget.isEditMode) {
        final eventId = widget.initialData?.eventId;
        if (eventId == null) {
          throw StateError('Unable to edit event. Missing event ID.');
        }

        await EventAdminService.updateEvent(
          eventId: eventId,
          name: _titleController.text.trim(),
          shortDescription: _shortDescController.text.trim(),
          fullDescription: _fullDescController.text.trim(),
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          eventDate: _selectedEventDate!,
          timeInStartMinutes: _timeToMinutes(_timeInStart!),
          timeInEndMinutes: _timeToMinutes(_timeInEnd!),
          timeOutStartMinutes: _timeToMinutes(_timeOutStart!),
          timeOutEndMinutes: _timeToMinutes(_timeOutEnd!),
          isMandatory: _isObligatory,
        );
      } else {
        await EventAdminService.createEvent(
          name: _titleController.text.trim(),
          shortDescription: _shortDescController.text.trim(),
          fullDescription: _fullDescController.text.trim(),
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          eventDate: _selectedEventDate!,
          timeInStartMinutes: _timeToMinutes(_timeInStart!),
          timeInEndMinutes: _timeToMinutes(_timeInEnd!),
          timeOutStartMinutes: _timeToMinutes(_timeOutStart!),
          timeOutEndMinutes: _timeToMinutes(_timeOutEnd!),
          isMandatory: _isObligatory,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Event updated successfully!'
                : 'Event created successfully!',
          ),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message.trim().isEmpty
          ? 'Failed to create event'
          : error.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final raw = error.toString();
      final message = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '').trim()
          : widget.isEditMode
          ? 'Failed to update event. Please try again.'
          : 'Failed to create event. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: 240,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _royalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                title: 'Event Setup',
                                subtitle: widget.isEditMode
                                    ? 'Update event details and publishing settings'
                                    : 'Enter event details and publishing settings',
                              ),
                              const SizedBox(height: 12),
                              _buildFormCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCardHeader(),
                                    const SizedBox(height: 20),
                                    _buildLabeledField(
                                      label: 'Event Banner',
                                      child: _buildBannerPicker(),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Event Title',
                                      child: TextFormField(
                                        controller: _titleController,
                                        maxLength: 100,
                                        textInputAction: TextInputAction.next,
                                        decoration: _buildInputDecoration(
                                          hintText: 'e.g., Freshman Night 2024',
                                          icon: Ionicons.pricetag_outline,
                                          hideCounter: true,
                                        ),
                                        validator: EventCreationValidators
                                            .validateTitle,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Event Location',
                                      child: TextFormField(
                                        controller: _locationController,
                                        maxLength: 120,
                                        textInputAction: TextInputAction.next,
                                        decoration: _buildInputDecoration(
                                          hintText:
                                              'e.g., DOrSU Main Covered Court',
                                          icon: Ionicons.location_outline,
                                          hideCounter: true,
                                        ),
                                        validator: EventCreationValidators
                                            .validateLocation,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildScheduleFields(),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Attendance Type',
                                      child: _buildObligatoryToggle(),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Short Description',
                                      trailing: const Text(
                                        'Max 150 chars',
                                        style: TextStyle(
                                          color: _mutedText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _shortDescController,
                                        maxLength: 150,
                                        maxLines: 3,
                                        textInputAction: TextInputAction.next,
                                        decoration: _buildInputDecoration(
                                          hintText:
                                              'A brief summary shown in event listings',
                                          icon: Ionicons.create_outline,
                                          hideCounter: true,
                                        ),
                                        validator: EventCreationValidators
                                            .validateShortDescription,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Full Description',
                                      child: TextFormField(
                                        controller: _fullDescController,
                                        maxLines: 5,
                                        textInputAction: TextInputAction.done,
                                        decoration: _buildInputDecoration(
                                          hintText:
                                              'Detailed information, guidelines, and what to expect',
                                          icon: Ionicons.document_text_outline,
                                        ),
                                        validator: EventCreationValidators
                                            .validateFullDescription,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.isEditMode
                                    ? 'By updating this event, changes are reflected to all eligible students in the DOrSU system.'
                                    : 'By creating this event, it becomes visible to eligible students in the DOrSU system.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _mutedText.withOpacity(0.9),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: _royalBlue),
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: widget.isEditMode ? 'Edit ' : 'Create New ',
                    style: const TextStyle(color: _royalBlue),
                  ),
                  const TextSpan(
                    text: 'Event',
                    style: TextStyle(color: _gold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _royalBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.black.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Ionicons.calendar_outline, color: _gold, size: 18),
        ),
        const SizedBox(width: 8),
        const Text(
          'EVENT DETAILS',
          style: TextStyle(
            color: _mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleFields() {
    final dateField = TextFormField(
      controller: _eventDateController,
      readOnly: true,
      onTap: _pickEventDate,
      decoration: _buildInputDecoration(
        hintText: 'Select event date',
        icon: Ionicons.calendar_outline,
        suffixIcon: Icon(
          Ionicons.chevron_down,
          color: _royalBlue.withOpacity(0.65),
          size: 18,
        ),
      ),
      validator: EventCreationValidators.validateEventDate,
    );

    final timeInField = TextFormField(
      controller: _timeInController,
      readOnly: true,
      onTap: _pickTimeInWindow,
      decoration: _buildInputDecoration(
        hintText: 'e.g., 8:00 AM - 8:15 AM',
        icon: Ionicons.time_outline,
        suffixIcon: Icon(
          Ionicons.chevron_down,
          color: _royalBlue.withOpacity(0.65),
          size: 18,
        ),
      ),
      validator: (value) {
        return EventCreationValidators.validateTimeInWindow(
          value: value,
          startMinutes: _timeInStart != null
              ? _timeToMinutes(_timeInStart!)
              : null,
          endMinutes: _timeInEnd != null ? _timeToMinutes(_timeInEnd!) : null,
        );
      },
    );

    final timeOutField = TextFormField(
      controller: _timeOutController,
      readOnly: true,
      onTap: _pickTimeOut,
      decoration: _buildInputDecoration(
        hintText: 'e.g., 4:00 PM - 4:15 PM',
        icon: Ionicons.log_out_outline,
        suffixIcon: Icon(
          Ionicons.chevron_down,
          color: _royalBlue.withOpacity(0.65),
          size: 18,
        ),
      ),
      validator: (value) {
        return EventCreationValidators.validateTimeOutWindow(
          value: value,
          startMinutes: _timeOutStart != null
              ? _timeToMinutes(_timeOutStart!)
              : null,
          endMinutes: _timeOutEnd != null ? _timeToMinutes(_timeOutEnd!) : null,
          timeInEndMinutes: _timeInEnd != null
              ? _timeToMinutes(_timeInEnd!)
              : null,
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledField(label: 'Event Date', child: dateField),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 440) {
              return Column(
                children: [
                  _buildLabeledField(
                    label: 'Time In (Window)',
                    child: timeInField,
                  ),
                  const SizedBox(height: 14),
                  _buildLabeledField(
                    label: 'Time Out (Window)',
                    child: timeOutField,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildLabeledField(
                    label: 'Time In (Window)',
                    child: timeInField,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildLabeledField(
                    label: 'Time Out (Window)',
                    child: timeOutField,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildObligatoryToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _fieldBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Obligatory Event',
                  style: TextStyle(
                    color: _titleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Require attendance for all students',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isObligatory,
            onChanged: (value) {
              setState(() => _isObligatory = value);
            },
            activeThumbColor: _gold,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _titleText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildBannerPicker() {
    if (_selectedImage == null && _existingImageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _fieldBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.image_outline,
                color: _royalBlue,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload Event Banner',
              style: TextStyle(
                color: _titleText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Supports JPG, PNG (Max 5MB)',
              style: TextStyle(
                color: _mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoadingImage ? null : _pickImage,
              icon: _isLoadingImage
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Ionicons.cloud_upload_outline, size: 16),
              label: const Text(
                'Browse Files',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _royalBlue,
                side: const BorderSide(color: _royalBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedImage == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _fieldBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _existingImageUrl,
                height: 185,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 185,
                    width: double.infinity,
                    color: _fieldFill,
                    child: const Icon(
                      Ionicons.image,
                      color: _mutedText,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _isLoadingImage ? null : _pickImage,
              icon: const Icon(Ionicons.refresh_outline, size: 16),
              label: const Text('Change image'),
              style: TextButton.styleFrom(
                foregroundColor: _royalBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              height: 185,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _isLoadingImage ? null : _pickImage,
            icon: const Icon(Ionicons.refresh_outline, size: 16),
            label: const Text('Change image'),
            style: TextButton.styleFrom(
              foregroundColor: _royalBlue,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
    bool hideCounter = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _mutedText, fontSize: 13),
      prefixIcon: Icon(icon, color: _royalBlue.withOpacity(0.6), size: 19),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _royalBlue, width: 1.8),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFB3261E)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFB3261E), width: 1.5),
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      counterText: hideCounter ? '' : null,
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _royalBlue.withOpacity(0.08))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleCreateEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: _royalBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: _royalBlue.withOpacity(0.55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.isEditMode ? 'Save Changes' : 'Create Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return EventDateTimeFormatters.displayDate(date);
  }

  String _formatTime(TimeOfDay value) {
    final hour24 = value.hour;
    final minuteText = value.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }

  int _timeToMinutes(TimeOfDay value) {
    return EventCreationValidators.timeToMinutes(
      hour: value.hour,
      minute: value.minute,
    );
  }

  TimeOfDay _minutesToTimeOfDay(int minutes) {
    final normalizedMinutes = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60);
    return TimeOfDay(
      hour: normalizedMinutes ~/ 60,
      minute: normalizedMinutes % 60,
    );
  }
}
