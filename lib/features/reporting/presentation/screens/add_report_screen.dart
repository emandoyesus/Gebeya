import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gebeya/core/constants/mock_data.dart';
import 'package:gebeya/core/utils/unit_converter.dart';
import 'package:gebeya/features/items/data/item_model.dart';
import 'package:gebeya/features/items/data/market_model.dart';
import 'package:gebeya/features/items/presentation/items_provider.dart';
import 'package:gebeya/features/reporting/presentation/reporting_provider.dart';
import 'package:gebeya/features/settings/presentation/settings_provider.dart';
import 'package:go_router/go_router.dart';

class AddReportScreen extends ConsumerStatefulWidget {
  final String? initialItemId;

  const AddReportScreen({super.key, this.initialItemId});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  ItemModel? _selectedItem;
  MarketModel? _selectedMarket;
  String _selectedUnit = 'standard';
  double _unitMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allItems = ref.read(itemsProvider).valueOrNull ?? MockData.items;
      final available = allItems.where((item) => !item.catalogOnly).toList();
      final items = available.isNotEmpty ? available : allItems;
      final markets = ref.read(marketsProvider).valueOrNull ?? MockData.markets;
      final currentMarket = ref.read(selectedMarketProvider);

      if (!mounted || items.isEmpty || markets.isEmpty) return;
      setState(() {
        if (widget.initialItemId != null) {
          _selectedItem = items.firstWhere(
            (i) => i.id == widget.initialItemId,
            orElse: () => items.first,
          );
        } else {
          _selectedItem = items.first;
        }
        _selectedMarket = currentMarket ?? markets.first;
      });
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _calculatedPricePerStandardUnit {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final qty = double.tryParse(_quantityController.text) ?? 1.0;
    return UnitConverter.calculatePricePerStandardUnit(
      totalPrice: price,
      quantity: qty,
      unitMultiplier: _unitMultiplier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(itemsProvider).valueOrNull ?? MockData.items;
    final available = allItems.where((item) => !item.catalogOnly).toList();
    final items = available.isNotEmpty ? available : allItems;
    final markets = ref.watch(marketsProvider).valueOrNull ?? MockData.markets;
    final reportingState = ref.watch(reportingProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    final standardUnit = _selectedItem?.localizedStandardUnit(isAmharic) ?? 'kg';

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E12),
        elevation: 0,
        title: Text(
          isAmharic ? 'ዋጋ ያስመዝግቡ' : 'Submit Price Report',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF16191E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF262C36)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFFC7F33B), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isAmharic
                            ? 'የእርስዎ ሪፖርት ሌሎች ሸማቾች ትክክለኛውን ዋጋ እንዲያውቁ ይረዳል'
                            : 'Your report helps fellow Ethiopians track fair prices',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF8E9BAE)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Item Dropdown
              Text(isAmharic ? 'የእቃው ስም' : 'Select Item', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
              const SizedBox(height: 8),
              DropdownButtonFormField<ItemModel>(
                value: _selectedItem,
                dropdownColor: const Color(0xFF16191E),
                style: const TextStyle(color: Color(0xFFF8FAFC)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF16191E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                ),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.localizedName(isAmharic), style: const TextStyle(color: Color(0xFFF8FAFC))),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedItem = val;
                    _selectedUnit = 'standard';
                    _unitMultiplier = 1.0;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Market Dropdown
              Text(isAmharic ? 'የገዙበት ገበያ' : 'Market Location', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
              const SizedBox(height: 8),
              DropdownButtonFormField<MarketModel>(
                value: _selectedMarket,
                dropdownColor: const Color(0xFF16191E),
                style: const TextStyle(color: Color(0xFFF8FAFC)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF16191E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                ),
                items: markets.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m.localizedName(isAmharic), style: const TextStyle(color: Color(0xFFF8FAFC))),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedMarket = val),
              ),
              const SizedBox(height: 16),

              // Unit Selector
              Text(isAmharic ? 'የመለኪያ ዓይነት' : 'Unit Type', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                dropdownColor: const Color(0xFF16191E),
                style: const TextStyle(color: Color(0xFFF8FAFC)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF16191E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'standard',
                    child: Text(
                      isAmharic
                          ? 'መደበኛ ($standardUnit)'
                          : 'Standard ($standardUnit)',
                      style: const TextStyle(color: Color(0xFFF8FAFC)),
                    ),
                  ),
                  if (_selectedItem != null)
                    ..._selectedItem!.supportedLocalUnits.map((lu) {
                      return DropdownMenuItem(
                        value: lu.unitKey,
                        child: Text(
                          isAmharic
                              ? '${lu.nameAm} (${lu.multiplier} $standardUnit)'
                              : '${lu.nameEn} (${lu.multiplier} $standardUnit)',
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                        ),
                      );
                    }),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedUnit = val;
                    if (val == 'standard') {
                      _unitMultiplier = 1.0;
                    } else {
                      final lu = _selectedItem?.supportedLocalUnits
                          .firstWhere((u) => u.unitKey == val);
                      _unitMultiplier = lu?.multiplier ?? 1.0;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Price Paid & Quantity Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isAmharic ? 'የከፈሉት ጠቅላላ ዋጋ (ETB)' : 'Total Price Paid (ETB)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: const TextStyle(color: Color(0xFF566171)),
                            prefixText: 'ETB ',
                            prefixStyle: const TextStyle(color: Color(0xFFC7F33B), fontWeight: FontWeight.bold),
                            filled: true,
                            fillColor: const Color(0xFF16191E),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter price';
                            if (double.tryParse(val) == null) return 'Enter valid number';
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isAmharic ? 'ብዛት' : 'Quantity', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Color(0xFFF8FAFC)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF16191E),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF262C36))),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Computed standard unit conversion pill
              if (_selectedUnit != 'standard' && _priceController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232A16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC7F33B).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFC7F33B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isAmharic
                            ? 'በመደበኛ መለኪያ፡ ≈ ${_calculatedPricePerStandardUnit.toStringAsFixed(1)} ETB / $standardUnit'
                            : 'Standard equivalent: ≈ ${_calculatedPricePerStandardUnit.toStringAsFixed(1)} ETB / $standardUnit',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC7F33B)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7F33B),
                    foregroundColor: const Color(0xFF0C0E12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: reportingState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() && _selectedItem != null && _selectedMarket != null) {
                            final price = double.tryParse(_priceController.text) ?? 0.0;
                            final qty = double.tryParse(_quantityController.text) ?? 1.0;
                            final success = await ref.read(reportingProvider.notifier).submitPriceReport(
                                  itemId: _selectedItem!.id,
                                  marketId: _selectedMarket!.id,
                                  totalPrice: price,
                                  quantity: qty,
                                  unit: _selectedUnit,
                                  pricePerStandardUnit: _calculatedPricePerStandardUnit,
                                  notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                                );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF232A16),
                                  content: Text(
                                    isAmharic ? 'ዋጋው በተሳካ ሁኔታ ተመዝግቧል!' : 'Price reported successfully!',
                                    style: const TextStyle(color: Color(0xFFC7F33B), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                              context.pop();
                            }
                          }
                        },
                  child: reportingState.isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF0C0E12))
                      : Text(
                          isAmharic ? 'ዋጋ አስመዝግብ' : 'Submit Price',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
