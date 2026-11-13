import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'ማስተካከያ' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Card
          _buildCard(
            title: isAmharic ? 'ቋንቋ (Language)' : 'Language (ቋንቋ)',
            children: [
              RadioListTile<String>(
                title: const Text('አማርኛ (Amharic)'),
                value: 'am',
                groupValue: isAmharic ? 'am' : 'en',
                activeColor: const Color(0xFF136A36),
                onChanged: (val) {
                  ref.read(localeProvider.notifier).setLocale('am');
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: isAmharic ? 'am' : 'en',
                activeColor: const Color(0xFF136A36),
                onChanged: (val) {
                  ref.read(localeProvider.notifier).setLocale('en');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Backend Status Card
          _buildCard(
            title: isAmharic ? 'የሲስተም ሁኔታ' : 'System Status',
            children: [
              ListTile(
                leading: Icon(
                  SupabaseConfig.isConfigured ? Icons.cloud_done_rounded : Icons.offline_pin_rounded,
                  color: const Color(0xFF136A36),
                ),
                title: Text(
                  SupabaseConfig.isConfigured
                      ? (isAmharic ? 'Supabase ተገናኝቷል' : 'Supabase Cloud Connected')
                      : (isAmharic ? 'ከመስመር ውጭ / የማሳያ ሁነታ' : 'Offline / Local Demo Mode'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  SupabaseConfig.isConfigured
                      ? (isAmharic ? 'የቀጥታ ዳታቤዝ ይሰራል' : 'Live cloud synchronization active')
                      : (isAmharic ? 'በአዲስ አበባ እውነተኛ የገበያ መረጃ ይሰራል' : 'Running on verified Addis Ababa baseline dataset'),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Sources Transparency
          _buildCard(
            title: isAmharic ? 'የመረጃ ምንጮች' : 'Data Transparency',
            children: [
              ListTile(
                leading: const Icon(Icons.verified_outlined, color: Color(0xFFD97706)),
                title: Text(
                  isAmharic ? 'የገበያ መረጃ እንዴት ይሰበሰባል?' : 'How prices are calculated',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isAmharic
                        ? '1. በገዢዎች የሚቀርቡ ሪፖርቶች\n2. የWFP እና የንግድ ቢሮ ሳምንታዊ መረጃዎች\n3. ከልክ ያለፈ ዋጋዎችን በማጣራት መካከለኛውን (Median) ዋጋ ያሰላል።'
                        : '1. Verified shopper reports in local markets\n2. Weekly baseline datasets (WFP & Trade Bureau)\n3. Filtered rolling median over 14 days.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About App
          Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'ገበያ (Gebeya) v1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Empowering fair market transparency across Ethiopia 🇪🇹',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
