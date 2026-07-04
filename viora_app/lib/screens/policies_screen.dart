import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Icon mapping cho Privacy Policy sections
  static const Map<String, IconData> _privacyIcons = {
    'ppInfoCollected': LucideIcons.shieldCheck,
    'ppPurpose': LucideIcons.target,
    'ppStorageSecurity': LucideIcons.lock,
    'ppDataSharing': LucideIcons.share2,
    'ppUserRights': LucideIcons.userCheck,
    'ppPolicyChanges': LucideIcons.refreshCw,
    'ppContact': LucideIcons.mail,
  };

  // Icon mapping cho Terms of Service sections
  static const Map<String, IconData> _termsIcons = {
    'tosAcceptance': LucideIcons.checkCircle2,
    'tosAccount': LucideIcons.user,
    'tosProhibited': LucideIcons.alertTriangle,
    'tosUserContent': LucideIcons.fileText,
    'tosAppRights': LucideIcons.shield,
    'tosDisclaimer': LucideIcons.info,
    'tosChanges': LucideIcons.refreshCw,
    'tosContact': LucideIcons.mail,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.policiesTitle,
          style: AppTypography.title.copyWith(color: context.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: context.cardColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: context.textSecondary,
              labelStyle: AppTypography.title.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
              unselectedLabelStyle: AppTypography.body.copyWith(
                fontSize: 14,
                color: context.textSecondary,
              ),
              splashBorderRadius: BorderRadius.circular(AppRadius.sm),
              tabs: [
                Tab(text: l10n.privacyPolicyTitle),
                Tab(text: l10n.termsOfServiceTitle),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivacyPolicy(l10n),
          _buildTermsOfService(l10n),
        ],
      ),
    );
  }

  Widget _buildPolicyHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required int index,
  }) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2E433C).withValues(alpha: 0.5)
              : AppColors.border.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: context.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: AppTypography.bodySecondary.copyWith(
              height: 1.7,
              fontSize: 13.5,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        _buildPolicyHeader(
          icon: LucideIcons.shieldCheck,
          title: l10n.privacyPolicyTitle,
          subtitle: l10n.privacyPolicyTitle == 'Chính sách Bảo mật'
              ? 'Cam kết bảo vệ thông tin cá nhân của bạn'
              : 'Our commitment to protecting your personal information',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSection(
          title: l10n.ppInfoCollected,
          content: l10n.ppInfoCollectedContent,
          icon: _privacyIcons['ppInfoCollected']!,
          index: 0,
        ),
        _buildSection(
          title: l10n.ppPurpose,
          content: l10n.ppPurposeContent,
          icon: _privacyIcons['ppPurpose']!,
          index: 1,
        ),
        _buildSection(
          title: l10n.ppStorageSecurity,
          content: l10n.ppStorageSecurityContent,
          icon: _privacyIcons['ppStorageSecurity']!,
          index: 2,
        ),
        _buildSection(
          title: l10n.ppDataSharing,
          content: l10n.ppDataSharingContent,
          icon: _privacyIcons['ppDataSharing']!,
          index: 3,
        ),
        _buildSection(
          title: l10n.ppUserRights,
          content: l10n.ppUserRightsContent,
          icon: _privacyIcons['ppUserRights']!,
          index: 4,
        ),
        _buildSection(
          title: l10n.ppPolicyChanges,
          content: l10n.ppPolicyChangesContent,
          icon: _privacyIcons['ppPolicyChanges']!,
          index: 5,
        ),
        _buildSection(
          title: l10n.ppContact,
          content: l10n.ppContactContent,
          icon: _privacyIcons['ppContact']!,
          index: 6,
        ),
      ],
    );
  }

  Widget _buildTermsOfService(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        _buildPolicyHeader(
          icon: LucideIcons.fileCheck,
          title: l10n.termsOfServiceTitle,
          subtitle: l10n.termsOfServiceTitle == 'Điều khoản Sử dụng'
              ? 'Điều kiện và quy định khi sử dụng ứng dụng'
              : 'Terms and conditions for using the application',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSection(
          title: l10n.tosAcceptance,
          content: l10n.tosAcceptanceContent,
          icon: _termsIcons['tosAcceptance']!,
          index: 0,
        ),
        _buildSection(
          title: l10n.tosAccount,
          content: l10n.tosAccountContent,
          icon: _termsIcons['tosAccount']!,
          index: 1,
        ),
        _buildSection(
          title: l10n.tosProhibited,
          content: l10n.tosProhibitedContent,
          icon: _termsIcons['tosProhibited']!,
          index: 2,
        ),
        _buildSection(
          title: l10n.tosUserContent,
          content: l10n.tosUserContentContent,
          icon: _termsIcons['tosUserContent']!,
          index: 3,
        ),
        _buildSection(
          title: l10n.tosAppRights,
          content: l10n.tosAppRightsContent,
          icon: _termsIcons['tosAppRights']!,
          index: 4,
        ),
        _buildSection(
          title: l10n.tosDisclaimer,
          content: l10n.tosDisclaimerContent,
          icon: _termsIcons['tosDisclaimer']!,
          index: 5,
        ),
        _buildSection(
          title: l10n.tosChanges,
          content: l10n.tosChangesContent,
          icon: _termsIcons['tosChanges']!,
          index: 6,
        ),
        _buildSection(
          title: l10n.tosContact,
          content: l10n.tosContactContent,
          icon: _termsIcons['tosContact']!,
          index: 7,
        ),
      ],
    );
  }
}
