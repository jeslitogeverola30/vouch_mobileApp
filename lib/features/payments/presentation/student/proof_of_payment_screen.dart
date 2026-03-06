import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/payment_receiver_service.dart';
import '../../data/receipt_image_upload_service.dart';
import '../../data/student_transaction_service.dart';
import '../../domain/payment_receipt_validators.dart';

class ProofOfPaymentScreen extends StatefulWidget {
  final int? requirementId;
  final String gcashNumber;
  final String accountName;
  final String paymentItem;
  final String amountToPay;

  const ProofOfPaymentScreen({
    super.key,
    this.requirementId,
    this.gcashNumber = '0912 345 6789',
    this.accountName = 'JOSHUA SERRANO',
    this.paymentItem = 'Membership Fee',
    this.amountToPay = '₱0.00',
  });

  @override
  State<ProofOfPaymentScreen> createState() => _ProofOfPaymentScreenState();
}

class _ProofOfPaymentScreenState extends State<ProofOfPaymentScreen> {
  File? _uploadedFile;
  final TextEditingController _referenceController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _receiverGcashNumber;
  String? _receiverAccountName;

  @override
  void initState() {
    super.initState();
    _loadReceiverDetails();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _loadReceiverDetails() async {
    try {
      final receiver = await PaymentReceiverService.instance
          .fetchActiveReceiver();
      if (!mounted || receiver == null) {
        return;
      }

      setState(() {
        _receiverGcashNumber = receiver.gcashNumber.trim();
        _receiverAccountName = receiver.name.trim();
      });
    } catch (_) {}
  }

  String get _displayGcashNumber {
    final rawValue =
        (_receiverGcashNumber != null && _receiverGcashNumber!.isNotEmpty)
        ? _receiverGcashNumber!
        : widget.gcashNumber;
    return PaymentReceiverDetails.formatGcashNumber(rawValue);
  }

  String get _displayAccountName {
    if (_receiverAccountName != null && _receiverAccountName!.isNotEmpty) {
      return _receiverAccountName!;
    }

    return widget.accountName;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final File file = File(pickedFile.path);
      final int fileSize = await file.length();

      if (!PaymentReceiptValidators.isFileSizeAllowed(fileSize)) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File size exceeds ${PaymentReceiptValidators.maxFileSizeMegabytes}MB limit',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _uploadedFile = file;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt uploaded successfully'),
          backgroundColor: Color(0xFF003DA5),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: const Color(0xFF003DA5),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitProof() async {
    if (_uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a receipt first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final requirementId = widget.requirementId;
    if (requirementId == null || requirementId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit proof for this fee.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final referenceNumber = _referenceController.text.trim();
    if (referenceNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter reference number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final alreadySubmitted = await StudentTransactionService.instance
          .hasSubmissionForRequirement(requirementId: requirementId);
      if (alreadySubmitted) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already submitted proof for this fee.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final proofPhotoUrl = await ReceiptImageUploadService.uploadReceiptImage(
        imageFile: _uploadedFile!,
      );

      await StudentTransactionService.instance.createTransaction(
        requirementId: requirementId,
        referenceNumber: referenceNumber,
        proofPhotoUrl: proofPhotoUrl,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proof of payment submitted successfully'),
          backgroundColor: Color(0xFF003DA5),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 900));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_supabaseErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } on ArgumentError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?.toString() ?? 'Invalid input.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_exceptionMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _supabaseErrorMessage(PostgrestException error) {
    final message = error.message.trim();
    if (message.isNotEmpty) {
      return message;
    }

    final errorCode = error.code?.trim() ?? '';
    if (errorCode.isNotEmpty) {
      return 'Supabase request failed ($errorCode).';
    }

    return 'Unexpected database error. Please try again.';
  }

  String _exceptionMessage(Object error) {
    final message = error.toString().trim();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 260,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF003DA5).withOpacity(0.1),
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
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPaymentItemChip(),
                            const SizedBox(height: 14),
                            _buildTransferCard(),
                            const SizedBox(height: 16),
                            _buildUploadCard(),
                            const SizedBox(height: 16),
                            _buildReferenceField(),
                            const SizedBox(height: 20),
                            _buildSubmitButton(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: Color(0xFF003DA5)),
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(
                    text: 'Proof of ',
                    style: TextStyle(color: Color(0xFF003DA5)),
                  ),
                  TextSpan(
                    text: 'Payment',
                    style: TextStyle(color: Color(0xFFFFC107)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItemChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Item: ${widget.paymentItem}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF003DA5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Amount to Pay: ${widget.amountToPay}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF003DA5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Funds To',
            style: GoogleFonts.poppins(
              color: const Color(0xFF003DA5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _buildCopyRow(
            label: 'GCash Number',
            value: _displayGcashNumber,
            onCopy: () => _copyToClipboard(_displayGcashNumber, 'GCash Number'),
          ),
          const SizedBox(height: 12),
          _buildCopyRow(
            label: 'Account Name',
            value: _displayAccountName,
            onCopy: () => _copyToClipboard(_displayAccountName, 'Account Name'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Note: Please ensure details are correct and keep your transaction screenshot.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black54,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF003DA5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF003DA5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Ionicons.copy, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Proof of Transaction',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003DA5),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF003DA5).withOpacity(0.25),
                  width: 1.6,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF7FAFF),
                image: _uploadedFile != null
                    ? DecorationImage(
                        image: FileImage(_uploadedFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _uploadedFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003DA5).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Ionicons.image_outline,
                            color: Color(0xFF003DA5),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to upload receipt',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF003DA5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Supports JPG/PNG • Max 10MB',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Receipt Uploaded',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Number',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF003DA5),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _referenceController,
          decoration: InputDecoration(
            hintText: 'Enter GCash Ref No.',
            hintStyle: GoogleFonts.poppins(
              color: Colors.black38,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF003DA5).withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF003DA5).withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF003DA5), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProof,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),
          foregroundColor: const Color(0xFF003DA5),
          disabledBackgroundColor: const Color(0xFFFFC107).withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003DA5)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Proof',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
