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
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E12),
        elevation: 0,
        title: Text(
          isAmharic ? 'ማስተካከያ' : 'Settings',
          style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // UI & Display Preferences (Kalo Style View Modes)
          _buildCard(
            title: isAmharic ? 'የእይታ ምርጫዎች (Display)' : 'Display Preferences',
            children: [
              // Grid vs List mode
              ListTile(
                leading: const Icon(Icons.grid_view_rounded, color: Color(0xFFC7F33B)),
                title: Text(isAmharic ? 'የእቃዎች አቀራረብ' : 'Layout style', style: const TextStyle(color: Color(0xFFF8FAFC))),
                subtitle: Text(
                  viewMode == ViewMode.grid
                      ? (isAmharic ? 'ፍርግርግ (Kalo ባለ ሁለት ረድፍ)' : '2-Column Grid (Kalo style)')
                      : (isAmharic ? 'ዝርዝር (አንድ ረድፍ)' : 'Single column list'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                ),
                trailing: SegmentedButton<ViewMode>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return const Color(0xFFC7F33B);
                      return const Color(0xFF1E232B);
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return const Color(0xFF0C0E12);
                      return const Color(0xFF8E9BAE);
                    }),
                  ),
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
              const Divider(height: 1, color: Color(0xFF262C36)),
              // IDEA 6: Data Saver / Zero-Data Mode Toggle
              SwitchListTile(
                secondary: const Icon(Icons.offline_bolt_rounded, color: Color(0xFFF59E0B)),
                title: Text(
                  isAmharic ? 'ዳታ ቆጣቢ ሁነታ (Data Saver)' : 'Data Saver Mode',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF8FAFC)),
                ),
                subtitle: Text(
                  isAmharic
                      ? 'ከፍተኛ ፍጥነት እና አነስተኛ የኢንተርኔት ዳታ ፍጆታ (ለኢትዮ ቴሌኮም ተስማሚ)'
                      : 'Compresses photos & accelerates loading on Ethiopian mobile networks',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                ),
                value: isDataSaver,
                activeThumbColor: const Color(0xFFC7F33B),
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
                leading: const Icon(Icons.send_rounded, color: Color(0xFF38BDF8)),
                title: const Text('Gebeya Telegram Bot (@gebeya_price_bot)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF8FAFC))),
                subtitle: Text(
                  isAmharic
                      ? 'የእቃውን ስም በመላክ ፈጣን የዋጋ መረጃ በቴሌግራም ያግኙ'
                      : 'Query real-time market medians directly via Telegram bot',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BAE)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF566171)),
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'https://t.me/gebeya_price_bot'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0284C7),
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
                title: const Text('አማርኛ (Amharic)', style: TextStyle(color: Color(0xFFF8FAFC))),
                value: 'am',
                groupValue: isAmharic ? 'am' : 'en',
                activeColor: const Color(0xFFC7F33B),
                onChanged: (_) => ref.read(localeProvider.notifier).setLocale('am'),
              ),
              RadioListTile<String>(
                title: const Text('English', style: TextStyle(color: Color(0xFFF8FAFC))),
                value: 'en',
                groupValue: isAmharic ? 'am' : 'en',
                activeColor: const Color(0xFFC7F33B),
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
                  color: const Color(0xFFC7F33B),
                ),
                title: Text(
                  SupabaseConfig.isConfigured
                      ? (isAmharic ? 'Supabase ተገናኝቷል' : 'Supabase Cloud Connected')
                      : (isAmharic ? 'ከመስመር ውጭ ይሰራል (Offline Ready)' : 'Offline Ready / Local Cache Active'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF8FAFC)),
                ),
                subtitle: Text(
                  SupabaseConfig.isConfigured
                      ? (isAmharic ? 'የቀጥታ ዳታቤዝ ይሰራል' : 'Live cloud synchronization active')
                      : (isAmharic ? '214 የተረጋገጡ እቃዎች በስልኩ ላይ ተቀምጠዋል' : '214 verified items stored on-device; works without data'),
                  style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Sources Transparency
          _buildCard(
            title: isAmharic ? 'የመረጃ ምንጮችና ግልጽነት' : 'Data Transparency',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  isAmharic
                      ? 'የገበያ ዋጋዎች የሚሰበሰቡት ከአዲስ አበባ ዋና ዋና ገበያዎች (መርካቶ፣ ሾላ፣ ሳሪስ፣ ቄራ፣ መገናኛ)፣ እንዲሁም ከተረጋገጡ የቴሌግራም ቻናሎችና የመስክ ተጠቃሚዎች ሪፖርት ነው።'
                      : 'Prices are crowdsourced & verified from Addis Ababa physical markets (Merkato, Shola, Saris, Kera, Megenagna), public Telegram marketplace channels, and consumer submissions.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8E9BAE), height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16191E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF262C36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC7F33B),
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF262C36)),
          ...children,
        ],
      ),
    );
  }
}
