// ============================================
// FILE: lib/fatures/settings/screens/cubit/contact_us_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/company_remote_data_source.dart';
import '../../data/models/company_info_model.dart';

enum ContactUsStatus { idle, sending, sent, failure }

class ContactUsState extends Equatable {
  final ContactUsStatus status;
  final String? error;

  const ContactUsState({this.status = ContactUsStatus.idle, this.error});

  bool get isSending => status == ContactUsStatus.sending;

  @override
  List<Object?> get props => [status, error];
}

class ContactUsCubit extends Cubit<ContactUsState> {
  final CompanyRemoteDataSource dataSource;

  ContactUsCubit(this.dataSource) : super(const ContactUsState());

  /// POST /public/contact-us. Validation errors from the server are already
  /// shown field-by-field by ApiService.
  Future<void> send({
    required String name,
    required String email,
    required ContactSubject subject,
    required String message,
  }) async {
    if (state.isSending) return;
    emit(const ContactUsState(status: ContactUsStatus.sending));
    try {
      await dataSource.sendContactMessage(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
      emit(const ContactUsState(status: ContactUsStatus.sent));
    } catch (e) {
      emit(
        ContactUsState(status: ContactUsStatus.failure, error: e.toString()),
      );
    }
  }
}
