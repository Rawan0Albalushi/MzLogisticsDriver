import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/page_header.dart';
import '../../tracking/data/location_service.dart';
import '../../trip_details/providers/trip_details_providers.dart';
import '../../trips/data/trips_repository.dart';
import '../../trips/providers/trips_providers.dart';

class PodFormScreen extends ConsumerStatefulWidget {
  const PodFormScreen({super.key, required this.tripId});

  final int tripId;

  @override
  ConsumerState<PodFormScreen> createState() => _PodFormScreenState();
}

class _PodFormScreenState extends ConsumerState<PodFormScreen> {
  final _receiver = TextEditingController();
  final _otp = TextEditingController();
  final _quantity = TextEditingController();
  final _notes = TextEditingController();
  final _photos = <XFile>[];
  bool _seeded = false;
  bool _submitting = false;
  String? _error;
  String? _receiverError;
  String? _otpError;
  String? _quantityError;

  @override
  void dispose() {
    _receiver.dispose();
    _otp.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _seedFromTrip() {
    if (_seeded) {
      return;
    }
    final trip = ref.read(tripDetailsProvider(widget.tripId)).valueOrNull;
    if (trip == null) {
      return;
    }
    _seeded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (trip.plannedQuantity != null && _quantity.text.isEmpty) {
        _quantity.text = trip.plannedQuantity!.toString();
      }
    });
  }

  Future<void> _addPhoto(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final files = await picker.pickMultiImage(imageQuality: 70);
      if (files.isEmpty) {
        return;
      }
      setState(() => _photos.addAll(files.take(6 - _photos.length)));
      return;
    }
    final file = await picker.pickImage(source: source, imageQuality: 70);
    if (file != null && _photos.length < 6) {
      setState(() => _photos.add(file));
    }
  }

  Future<void> _submit() async {
    final strings = ref.read(stringsProvider);
    setState(() {
      _receiverError = _receiver.text.trim().isEmpty ? strings.t('pod.required') : null;
      _otpError = _otp.text.trim().length != 6 ? strings.t('pod.otp_length') : null;
      _quantityError = double.tryParse(_quantity.text.trim()) == null
          ? strings.t('pod.qty_invalid')
          : null;
      _error = null;
    });
    if (_receiverError != null || _otpError != null || _quantityError != null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final location = await ref.read(locationServiceProvider).currentFix();
      final photos = <MultipartFile>[];
      for (final file in _photos) {
        photos.add(
          await MultipartFile.fromFile(file.path, filename: file.name),
        );
      }
      await ref.read(tripsRepositoryProvider).submitPod(
            id: widget.tripId,
            receiverName: _receiver.text.trim(),
            otp: _otp.text.trim(),
            receivedQuantity: double.parse(_quantity.text.trim()),
            notes: _notes.text.trim(),
            lat: location.fix?.lat,
            lng: location.fix?.lng,
            photos: photos,
          );
      ref.invalidate(tripDetailsProvider(widget.tripId));
      ref.invalidate(tripsListProvider);
      if (mounted) {
        context.pop();
      }
    } on ApiException catch (error) {
      setState(() {
        _otpError = error.firstFieldError('otp') != null
            ? strings.t('pod.otp_length')
            : _otpError;
        _error = errorMessageFor(
          error,
          strings.t('state.offline'),
          error.message == 'request_failed' ? strings.t('state.error') : error.message,
        );
      });
    } catch (_) {
      setState(() => _error = strings.t('state.error'));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    _seedFromTrip();

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: strings.t('pod.title'),
            showBack: true,
          ),
          Expanded(
            child: tripAsync.when(
        loading: () => LoadingState(message: strings.t('state.loading')),
        error: (error, _) => ErrorState(
          message: errorMessageFor(
            error,
            strings.t('state.offline'),
            strings.t('state.error'),
          ),
          retryLabel: strings.t('state.retry'),
          onRetry: () => ref.invalidate(tripDetailsProvider(widget.tripId)),
        ),
        data: (_) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                label: strings.t('pod.receiver'),
                controller: _receiver,
                textInputAction: TextInputAction.next,
                errorText: _receiverError,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: strings.t('pod.otp'),
                controller: _otp,
                keyboardType: TextInputType.number,
                errorText: _otpError,
                prefixIcon: Icons.pin_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                strings.t('pod.otp_hint'),
                style: AppText.label,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: strings.t('pod.quantity'),
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: _quantityError,
                prefixIcon: Icons.scale_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: strings.t('pod.notes'),
                controller: _notes,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                strings.t('pod.photos'),
                style: AppText.title,
              ),
              const SizedBox(height: 4),
              Text(
                strings.t('pod.photos_hint'),
                style: AppText.label,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    Container(
                      width: 108,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(i)),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.image_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _photos[i].name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: strings.t('pod.camera'),
                      tone: AppButtonTone.ghost,
                      icon: Icons.photo_camera_outlined,
                      onPressed: _photos.length >= 6
                          ? null
                          : () => _addPhoto(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: strings.t('pod.gallery'),
                      tone: AppButtonTone.ghost,
                      icon: Icons.photo_library_outlined,
                      onPressed: _photos.length >= 6
                          ? null
                          : () => _addPhoto(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: AppText.body.copyWith(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
            ),
          ),
        ],
      ),
      bottomNavigationBar: tripAsync.hasValue
          ? Material(
              color: AppColors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: AppButton(
                    label: _error != null
                        ? strings.t('action.retry')
                        : strings.t('pod.submit'),
                    busy: _submitting,
                    icon: Icons.assignment_turned_in_rounded,
                    onPressed: _submit,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
