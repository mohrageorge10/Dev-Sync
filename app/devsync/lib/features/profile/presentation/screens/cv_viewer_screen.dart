import 'dart:typed_data';

import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/delete_cv_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// In-app PDF viewer for previewing, replacing, or deleting the user's CV.
class CvViewerScreen extends StatefulWidget {
  const CvViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.bytes,
    this.allowManage = true,
  });

  final String title;
  final String? url;
  final Uint8List? bytes;
  final bool allowManage;

  @override
  State<CvViewerScreen> createState() => _CvViewerScreenState();
}

class _CvViewerScreenState extends State<CvViewerScreen> {
  static const _maxBytes = 5 * 1024 * 1024;

  final PdfViewerController _pdfController = PdfViewerController();
  late String _title = widget.title;
  late String? _url = widget.url;
  late Uint8List? _bytes = widget.bytes;

  int _pageNumber = 1;
  int _pageCount = 0;
  String? _loadError;
  bool _isBusy = false;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _replaceCv() async {
    const pdf = XTypeGroup(
      label: 'PDF',
      extensions: ['pdf'],
      mimeTypes: ['application/pdf'],
    );
    final file = await openFile(acceptedTypeGroups: [pdf]);
    if (file == null) return;

    final size = await file.length();
    if (size > _maxBytes) {
      if (!mounted) return;
      AppFeedback.show(
        context,
        message: 'File is too large. Max size is 5 MB.',
        type: AppFeedbackType.warning,
      );
      return;
    }

    setState(() => _isBusy = true);
    final bytes = await file.readAsBytes();
    final profile = ServiceLocator.get<ProfileController>();
    final error = await profile.uploadResume(
      name: file.name,
      size: size,
      bytes: bytes,
    );

    if (!mounted) return;
    if (error != null) {
      setState(() => _isBusy = false);
      AppFeedback.show(context, message: error, type: AppFeedbackType.error);
      return;
    }

    setState(() {
      _title = profile.resumeName ?? file.name;
      _url = profile.resumeUrl;
      _bytes = profile.resumeBytes;
      _loadError = null;
      _pageNumber = 1;
      _pageCount = 0;
      _isBusy = false;
    });
    AppFeedback.show(
      context,
      message: 'CV replaced successfully.',
      type: AppFeedbackType.success,
    );
  }

  Future<void> _deleteCv() async {
    final confirmed = await showDeleteCvDialog(context);
    if (!confirmed || !mounted) return;
    setState(() => _isBusy = true);
    await ServiceLocator.get<ProfileController>().clearResume();
    if (!mounted) return;
    AppFeedback.show(
      context,
      message: 'CV removed.',
      type: AppFeedbackType.info,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasBytes = _bytes != null && _bytes!.isNotEmpty;
    final hasUrl = _url != null && _url!.isNotEmpty;

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: c.backgroundPrimary,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.title15Bold(context),
            ),
            if (_pageCount > 0)
              Text(
                'Page $_pageNumber of $_pageCount',
                style: AppStyles.caption10Secondary(context),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.zoom_out_rounded, size: 20),
            onPressed: () {
              final next = (_pdfController.zoomLevel - 0.25).clamp(1.0, 3.0);
              _pdfController.zoomLevel = next;
            },
          ),
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.zoom_in_rounded, size: 20),
            onPressed: () {
              final next = (_pdfController.zoomLevel + 0.25).clamp(1.0, 3.0);
              _pdfController.zoomLevel = next;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isBusy
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? _ErrorState(message: _loadError!)
                : hasBytes
                ? SfPdfViewer.memory(
                    _bytes!,
                    key: ValueKey('mem_${_title}_${_bytes!.length}'),
                    controller: _pdfController,
                    onDocumentLoaded: (details) => setState(
                      () => _pageCount = details.document.pages.count,
                    ),
                    onPageChanged: (details) =>
                        setState(() => _pageNumber = details.newPageNumber),
                    onDocumentLoadFailed: (details) =>
                        setState(() => _loadError = details.description),
                  )
                : hasUrl
                ? SfPdfViewer.network(
                    _url!,
                    key: ValueKey('net_$_url'),
                    controller: _pdfController,
                    onDocumentLoaded: (details) => setState(
                      () => _pageCount = details.document.pages.count,
                    ),
                    onPageChanged: (details) =>
                        setState(() => _pageNumber = details.newPageNumber),
                    onDocumentLoadFailed: (details) =>
                        setState(() => _loadError = details.description),
                  )
                : const _ErrorState(
                    message: 'This CV has no cloud link yet. Tap Replace CV below to upload and preview it.',
                  ),
          ),
          if (widget.allowManage)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: c.backgroundPrimary,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _isBusy ? null : _deleteCv,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: c.subtle(c.error),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: c.error.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: c.error,
                              ),
                              Flexible(
                                child: Text(
                                  'Delete CV',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.lightPrimary_16_500(
                                    context,
                                  ).copyWith(color: c.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ProfilePrimaryButton(
                        'Replace CV',
                        icon: Icons.upload_file_rounded,
                        onPressed: _isBusy ? null : _replaceCv,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 48, color: c.error),
            const SizedBox(height: 12),
            Text('Unable to display CV', style: AppStyles.title16Bold(context)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.body13Secondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
