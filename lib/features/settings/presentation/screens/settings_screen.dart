import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final isDataSaver = ref.watch(dataSaverProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isAmharic ? 'ማስተካከያ' : 'Settings',
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // UI & Display Preferences (JIJI Style View Modes)
          _buildCard(
            title: isAmharic ? 'የእይታ ምርጫዎች (Display)' : 'Display Preferences',
            children: [
              // Grid vs List mode
              ListTile(
                leading: const Icon(Icons.grid_view_rounded, color: Color(0xFF00B53F)),
                title: Text(isAmharic ? 'የእቃዎች አቀራረብ' : 'Layout style'),
                subtitle: Text(
                  viewMode == ViewMode.grid
                      ? (isAmharic ? 'ፍርግርግ (Jiji ባለ ሁለት ረድፍ)' : '2-Column Grid (Jiji style)')
                      : (isAmharic ? 'ዝርዝር (አንድ ረድፍ)' : 'Single column list'),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: SegmentedButton<ViewMode>(
                  segments: [
                    ButtonSegment(
                      value: ViewMode.grid,
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                      label: Text(isAmharic ? 'ፍርግርግ' : 'Grid'),
                    ),
                    ButtonSegment(
                      value: ViewMode.list,
                      icon: const Icon(Icons.view_list_rounded, size: 16),
                      label: Text(isAmharic ? 'ዝርዝር' : 'List'),
                    ),
                  ],
                  selected: {viewMode},
                  onSelectionChanged: (set) => ref.read(viewModeProvider.notifier).setMode(set.first),
                ),
              ),
              const Divider(height: 1),
              // IDEA 6: Data Saver / Zero-Data Mode Toggle
              SwitchListTile(
                secondary: const Icon(Icons.offline_bolt_rounded, color: Color(0xFFD97706)),
                title: Text(
                  isAmharic ? 'ዳታ ቆጣቢ ሁነታ (Data Saver)' : 'Data Saver Mode',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  isAmharic
                      ? 'ከፍተኛ ፍጥነት እና አነስተኛ የኢንተርኔት ዳታ ፍጆታ (ለኢትዮ ቴሌኮም ተስማሚ)'
                      : 'Compresses photos & accelerates loading on Ethiopian mobile networks',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                value: isDataSaver,
                activeColor: const Color(0xFF00B53F),
                onChanged: (_) => ref.read(dataSaverProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // IDEA 5: Telegram Community & Price Bot
          _buildCard(
            title: isAmharic ? 'ቴሌግራም ቦትና ቻናል' : 'Telegram & Community',
            children: [
              ListTile(
                leading: const Icon(Icons.send_rounded, color: Color(0xFF0088CC)),
                title: const Text('Gebeya Telegram Bot (@gebeya_price_bot)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(
                  isAmharic
                      ? 'የእቃውን ስም በመላክ ፈጣን የዋጋ መረጃ በቴሌግራም ያግኙ'
                      : 'Query real-time market medians directly via Telegram bot',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'https://t.me/gebeya_price_bot'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0088CC),
                      content: Text(isAmharic ? 'የቦቱ አድራሻ ተቀድቷል፡ @gebeya_price_bot' : 'Copied bot handle: @gebeya_price_bot'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language Card
          _buildCard(
            title: isAmharic ? 'ቋንቋ (Language)' : 'Language (ቋንቋ)',
            children: [
              RadioListTile<String>(
                title: const Text('አማርኛ (Amharic)'),
                value: 'am',
                groupValue: isAmharic ? 'am' : 'en',
                activeColor: const Color(0xFF00B53F),
                onChanged: (_) => ref.read(localeProvider.notifier).setLocale('am'),
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: isAmharic ? 'am' : 'en',
                activeColor: const Color(0xFF00B53F),
                onChanged: (_) => ref.read(localeProvider.notifier).setLocale('en'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Backend Status Card (Idea 6: Offline-first)
          _buildCard(
            title: isAmharic ? 'የሲስተም ሁኔታ' : 'System & Offline Storage',
            children: [
              ListTile(
                leading: Icon(
                  SupabaseConfig.isConfigured ? Icons.cloud_done_rounded : Icons.offline_pin_rounded,
                  color: const Color(0xFF00B53F),
                ),
                title: Text(
                  SupabaseConfig.isConfigured
                      ? (isAmharic ? 'Supabase ተገናኝቷል' : 'Supabase Cloud Connected')
                      : (isAmharic ? 'ከመስመር ውጭ ይሰራል (Offline Ready)' : 'Offline Ready / Local Cache Active'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  SupabaseConfig.isConfigured
                      ? (isAmharic ? 'የቀጥታ ዳታቤዝ ይሰራል' : 'Live cloud synchronization active')
                      : (isAmharic ? '214 የተረጋገጡ እቃዎች በስልኩ ላይ ተቀምጠዋል' : '214 verified items stored on-device; works without data'),
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Sources Transparency
          _buildCard(
            title: isAmharic ? 'የመረጃ ምንጮችና ግልጽነት' : 'Data Transparency',
            children: [
              ListTile(
                leading: const Icon(Icons.verified_outlined, color: Color(0xFFF59E0B)),
                title: Text(
                  isAmharic ? 'የገበያ ዋጋ እንዴት ይሰላል?' : 'How prices are calculated',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isAmharic
                        ? '1. በሸማቾች የሚቀርቡ እውነተኛ የግብይት ሪፖርቶች\n2. የጂጂ እና ቴሌግራም የሻጭ ዋጋዎች ማጠቃለያ\n3. በየገበያው (መርካቶ፣ ሾላ፣ ሳሪስ፣ ቄራ፣ መገናኛ) አማካኝ ዋጋ።'
                        : '1. Verified consumer receipts in local markets\n2. Aggregated Jiji & Telegram seller asking prices\n3. Cross-market rolling median across Addis Ababa.',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About App
          Center(
            child: Column(
              children: [
                Text(
                  'ገበያ (Gebeya Ethiopia) v1.1.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ethiopia\'s Smart Market Price & Shopping Intelligence 🇪🇹',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
