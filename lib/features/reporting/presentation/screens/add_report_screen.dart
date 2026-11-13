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
      final items = ref.read(itemsProvider).valueOrNull ?? MockData.items;
      final markets = ref.read(marketsProvider).valueOrNull ?? MockData.markets;
      final currentMarket = ref.read(selectedMarketProvider);

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
    final items = ref.watch(itemsProvider).valueOrNull ?? MockData.items;
    final markets = ref.watch(marketsProvider).valueOrNull ?? MockData.markets;
    final reportingState = ref.watch(reportingProvider);
    final isAmharic = ref.watch(isAmharicProvider);

    final standardUnit = _selectedItem?.localizedStandardUnit(isAmharic) ?? 'kg';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'ዋጋ ያስመዝግቡ' : 'Submit Price Report'),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF136A36), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAmharic
                            ? 'የእርስዎ ሪፖርት ማህበረሰቡ ትክክለኛውን የገበያ ዋጋ እንዲያውቅ ይረዳል!'
                            : 'Your report helps the community know the fair market price!',
                        style: const TextStyle(
                          color: Color(0xFF136A36),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Item Selector
              Text(
                isAmharic ? 'የእቃው አይነት' : 'Item',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<ItemModel>(
                value: _selectedItem,
                decoration: _inputDecoration(),
                items: items.map((item) {
                  return DropdownMenuItem<ItemModel>(
                    value: item,
                    child: Text(item.localizedName(isAmharic)),
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

              // Market Selector
              Text(
                isAmharic ? 'የገበያ ቦታ' : 'Market',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<MarketModel>(
                value: _selectedMarket,
                decoration: _inputDecoration(),
                items: markets.map((market) {
                  return DropdownMenuItem<MarketModel>(
                    value: market,
                    child: Text(market.localizedName(isAmharic)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMarket = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Unit Selector (supports Tassa, Kubaya, Quintal, etc.)
              Text(
                isAmharic ? 'የገዙበት መለኪያ' : 'Unit of Purchase',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: _inputDecoration(),
                items: [
                  DropdownMenuItem(
                    value: 'standard',
                    child: Text(
                      '${isAmharic ? "መደበኛ" : "Standard"} ($standardUnit)',
                    ),
                  ),
                  if (_selectedItem != null)
                    ..._selectedItem!.supportedLocalUnits.map((lu) {
                      return DropdownMenuItem(
                        value: lu.unitKey,
                        child: Text('${isAmharic ? lu.nameAm : lu.nameEn} (≈ ${lu.multiplier} $standardUnit)'),
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
                      final found = _selectedItem?.supportedLocalUnits.firstWhere(
                        (u) => u.unitKey == val,
                        orElse: () => LocalUnitInfo(unitKey: val, nameAm: val, nameEn: val, multiplier: 1.0),
                      );
                      _unitMultiplier = found?.multiplier ?? 1.0;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Quantity & Total Price Paid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAmharic ? 'መጠን' : 'Quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration(hint: '1'),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            if (double.tryParse(val) == null) return 'Invalid';
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAmharic ? 'የከፈሉት ዋጋ (ብር)' : 'Price Paid (ETB)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration(hint: 'e.g. 150', suffix: 'ETB'),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            final parsed = double.tryParse(val);
                            if (parsed == null || parsed <= 0) return 'Invalid price';
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Standardized Price Preview Card
              if (_calculatedPricePerStandardUnit > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAmharic ? 'የ1 $standardUnit ዋጋ፡' : 'Price per $standardUnit:',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
                      ),
                      Text(
                        '${_calculatedPricePerStandardUnit.toStringAsFixed(1)} ETB / $standardUnit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Optional Notes
              Text(
                isAmharic ? 'ተጨማሪ ማስታወሻ (አማራጭ)' : 'Notes (optional)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: _inputDecoration(
                  hint: isAmharic ? 'ለምሳሌ፡ በጣም ጥራት ያለው' : 'e.g. High quality, fresh stock',
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136A36),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: reportingState.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          if (_selectedItem == null || _selectedMarket == null) return;

                          final success = await ref
                              .read(reportingProvider.notifier)
                              .submitPriceReport(
                                itemId: _selectedItem!.id,
                                marketId: _selectedMarket!.id,
                                totalPrice: double.parse(_priceController.text),
                                quantity: double.parse(_quantityController.text),
                                unit: _selectedUnit,
                                pricePerStandardUnit: _calculatedPricePerStandardUnit,
                                notes: _notesController.text.trim().isEmpty
                                    ? null
                                    : _notesController.text.trim(),
                              );

                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF136A36),
                                content: Text(
                                  isAmharic
                                      ? 'ሪፖርትዎ በተሳካ ሁኔታ ተመዝግቧል! እናመሰግናለን።'
                                      : 'Price report submitted successfully! Thank you.',
                                ),
                              ),
                            );
                            context.pop();
                          }
                        },
                  child: reportingState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isAmharic ? 'ሪፖርቱን አስገባ' : 'Submit Report',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, String? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
