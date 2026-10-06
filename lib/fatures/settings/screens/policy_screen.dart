// ============================================
// FILE: lib/fatures/settings/screens/policy_screen.dart
// ============================================
//
// Privacy Policy / Terms & Conditions / Financial policy page — the HTML
// body comes from `GET /public/policies?policy_type=...`.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../utils/api_client.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';
import '../data/datasource/settings_remote_data_source.dart';
import '../data/models/policy_model.dart';
import 'cubit/policy_cubit.dart';
import 'widgets/settings_widgets.dart';

class PolicyScreen extends StatelessWidget {
  final PolicyType type;

  /// App bar title (the Settings menu label, as in the design).
  final String title;

  const PolicyScreen({super.key, required this.type, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PolicyCubit(SettingsRemoteDataSourceImpl(ApiService()), type)..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SettingsAppBar(title: title),
        body: BlocBuilder<PolicyCubit, PolicyState>(
          builder: (context, state) {
            final cubit = context.read<PolicyCubit>();
            switch (state.status) {
              case PolicyStatus.initial:
              case PolicyStatus.loading:
                return const LoadingIndicator();

              case PolicyStatus.failure:
                return _Refreshable(
                  onRefresh: cubit.refresh,
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: AppStrings.somethingWentWrong.tr(),
                    subtitle: state.error ?? AppStrings.pleaseTryAgain.tr(),
                    action: CustomButton(
                      text: AppStrings.retry.tr(),
                      onPressed: cubit.load,
                    ),
                  ),
                );

              case PolicyStatus.empty:
                return _Refreshable(
                  onRefresh: cubit.refresh,
                  child: EmptyState(
                    icon: Icons.description_outlined,
                    title: AppStrings.policyNotAvailable.tr(),
                  ),
                );

              case PolicyStatus.success:
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: cubit.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [PolicyHtml(html: state.policy!.content)],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

/// Renders the policy HTML with the design's text styles: 18 / w500
/// headings and 13px grey body copy with roomy line height.
class PolicyHtml extends StatelessWidget {
  final String html;
  const PolicyHtml({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.55,
      ),
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h1':
          case 'h2':
            return {
              'font-size': '18px',
              'font-weight': '500',
              'color': '#1F2937',
              'margin': '16px 0 8px 0',
            };
          case 'h3':
          case 'h4':
            return {
              'font-size': '16px',
              'font-weight': '500',
              'color': '#1F2937',
              'margin': '12px 0 6px 0',
            };
          case 'p':
            return {'margin': '0 0 10px 0'};
          case 'li':
            return {'margin': '0 0 8px 0'};
          case 'a':
            return {'color': '#82003C'};
        }
        return null;
      },
    );
  }
}

class _Refreshable extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _Refreshable({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
