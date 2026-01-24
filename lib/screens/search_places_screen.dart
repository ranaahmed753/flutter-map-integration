import 'package:flutter/material.dart';
import 'package:map/core/providers/search_places_provider.dart';
import 'package:provider/provider.dart';

class SearchPlacesScreen extends StatelessWidget {
  const SearchPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Places Autocomplete'), elevation: 2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: context.read<SearchPlacesProvider>().controller,
                  focusNode: context.read<SearchPlacesProvider>().focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        context
                            .read<SearchPlacesProvider>()
                            .controller
                            .text
                            .isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              context
                                  .read<SearchPlacesProvider>()
                                  .controller
                                  .clear();
                              context.read<SearchPlacesProvider>().searchPlaces(
                                '',
                              );
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) =>
                      context.read<SearchPlacesProvider>().searchPlaces(value),
                ),
                const SizedBox(height: 16),
                Consumer<SearchPlacesProvider>(
                  builder: (context, provider, child) {
                    if (provider.selectedPlace != null) {
                      final place = provider.selectedPlace!;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    place.formattedAddress,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (place.lat != null && place.lng != null)
                                    Text(
                                      'Lat: ${place.lat!.toStringAsFixed(6)}, Lng: ${place.lng!.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                provider.dispose();
                                context
                                    .read<SearchPlacesProvider>()
                                    .controller
                                    .clear();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Consumer<SearchPlacesProvider>(
                  builder: (context, provider, child) {
                    if (provider.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                provider?.errorMessage ?? "",
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SearchPlacesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.predictions.isEmpty &&
                    context
                        .read<SearchPlacesProvider>()
                        .controller
                        .text
                        .isNotEmpty &&
                    provider.errorMessage == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No places found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.predictions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start typing to search places',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = provider.predictions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: const Icon(Icons.place, color: Colors.blue),
                      ),
                      title: Text(
                        prediction.mainText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(prediction.secondaryText),
                      onTap: () {
                        provider.selectPlace(prediction);
                        context.read<SearchPlacesProvider>().controller.text =
                            prediction.mainText;
                        context
                            .read<SearchPlacesProvider>()
                            .focusNode
                            .unfocus();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
