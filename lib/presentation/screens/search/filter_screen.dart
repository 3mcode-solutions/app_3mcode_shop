import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(0, 100);
  double _minRating = 0;
  String _selectedCategory = '';
  bool _onlyDiscounted = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('filters')),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(localizations.translate('reset')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Range
            Text(
              localizations.translate('price_range'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 100,
              divisions: 20,
              labels: RangeLabels(
                '\$${_priceRange.start.toStringAsFixed(0)}',
                '\$${_priceRange.end.toStringAsFixed(0)}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_priceRange.start.toStringAsFixed(0)}'),
                Text('\$${_priceRange.end.toStringAsFixed(0)}'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Rating
            Text(
              localizations.translate('minimum_rating'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _minRating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _minRating = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0'),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < _minRating 
                          ? Colors.amber 
                          : Colors.grey.shade300,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Categories
            Text(
              localizations.translate('categories'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "All" category
                      ChoiceChip(
                        label: Text(localizations.translate('all')),
                        selected: _selectedCategory.isEmpty,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = '';
                            });
                          }
                        },
                      ),
                      
                      // Other categories
                      ...state.categories.map((category) {
                        return ChoiceChip(
                          label: Text(category.name),
                          selected: _selectedCategory == category.name,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category.name;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Discounted only
            Row(
              children: [
                Checkbox(
                  value: _onlyDiscounted,
                  onChanged: (value) {
                    setState(() {
                      _onlyDiscounted = value ?? false;
                    });
                  },
                ),
                Text(
                  localizations.translate('only_discounted_products'),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  localizations.translate('apply_filters'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100);
      _minRating = 0;
      _selectedCategory = '';
      _onlyDiscounted = false;
    });
  }
  
  void _applyFilters() {
    // Create filter parameters
    final filterParams = {
      'min_price': _priceRange.start,
      'max_price': _priceRange.end,
      'min_rating': _minRating,
      'category': _selectedCategory,
      'only_discounted': _onlyDiscounted,
    };
    
    // Apply filters
    context.read<ProductBloc>().add(FilterProducts(filterParams));
    
    // Close the screen
    Navigator.pop(context);
  }
}
