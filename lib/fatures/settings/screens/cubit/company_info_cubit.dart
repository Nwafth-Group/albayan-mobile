// ============================================
// FILE: lib/fatures/settings/screens/cubit/company_info_cubit.dart
// ============================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/company_remote_data_source.dart';
import '../../data/models/company_info_model.dart';

enum CompanyInfoStatus { loading, success, failure }

class CompanyInfoState extends Equatable {
  final CompanyInfoStatus status;
  final CompanyInfoModel? info;

  const CompanyInfoState({this.status = CompanyInfoStatus.loading, this.info});

  @override
  List<Object?> get props => [status, info];
}

/// Loads the shared company info (cached per session by [CompanyInfoStore]).
class CompanyInfoCubit extends Cubit<CompanyInfoState> {
  final CompanyRemoteDataSource dataSource;

  CompanyInfoCubit(this.dataSource) : super(const CompanyInfoState());

  Future<void> load({bool forceRefresh = false}) async {
    if (state.info == null) {
      emit(const CompanyInfoState(status: CompanyInfoStatus.loading));
    }
    try {
      final info = await CompanyInfoStore.get(
        dataSource: dataSource,
        forceRefresh: forceRefresh,
      );
      if (!isClosed) {
        emit(CompanyInfoState(status: CompanyInfoStatus.success, info: info));
      }
    } catch (_) {
      // Keep showing what we had; the screens degrade to their static parts.
      if (!isClosed) {
        emit(
          CompanyInfoState(
            status: state.info == null
                ? CompanyInfoStatus.failure
                : CompanyInfoStatus.success,
            info: state.info,
          ),
        );
      }
    }
  }
}
