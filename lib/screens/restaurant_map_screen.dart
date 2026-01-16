import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/restaurant.dart';
import '../widgets/restaurant_card.dart';

class RestaurantMapScreen extends StatefulWidget {
  @override
  State<RestaurantMapScreen> createState() => _RestaurantMapScreenState();
}

class _RestaurantMapScreenState extends State<RestaurantMapScreen> {
  final ScrollController _scrollController = ScrollController();
  GoogleMapController? _mapController;

  final double itemWidth = 276;
  int _currentIndex = 0;
  bool _isProgrammaticScroll = false;

  final List<Restaurant> restaurants = [
    Restaurant(
      id: '1',
      name: 'Pizza Hut',
      lat: 23.8103,
      lng: 90.4125,
      offer: '20% OFF',
    ),
    Restaurant(
      id: '2',
      name: 'Burger King',
      lat: 23.8120,
      lng: 90.4150,
      offer: 'Buy 1 Get 1',
    ),
    Restaurant(
      id: '3',
      name: 'KFC',
      lat: 23.8150,
      lng: 90.4180,
      offer: 'Free Drink',
    ),
    Restaurant(
      id: '4',
      name: 'Domino’s Pizza',
      lat: 23.8165,
      lng: 90.4102,
      offer: '30% OFF',
    ),
    Restaurant(
      id: '5',
      name: 'Subway',
      lat: 23.8182,
      lng: 90.4148,
      offer: 'Combo Meal ৳299',
    ),
    Restaurant(
      id: '6',
      name: 'Chillox',
      lat: 23.8174,
      lng: 90.4195,
      offer: 'Free Fries',
    ),
    Restaurant(
      id: '7',
      name: 'Madchef',
      lat: 23.8148,
      lng: 90.4207,
      offer: '25% OFF',
    ),
    Restaurant(
      id: '8',
      name: 'Sultan’s Dine',
      lat: 23.8131,
      lng: 90.4172,
      offer: 'Special Kacchi',
    ),
    Restaurant(
      id: '9',
      name: 'Takeout',
      lat: 23.8117,
      lng: 90.4190,
      offer: 'Buy 2 Get 1',
    ),
    Restaurant(
      id: '10',
      name: 'Boomers Café',
      lat: 23.8099,
      lng: 90.4161,
      offer: 'Free Coffee',
    ),
    Restaurant(
      id: '11',
      name: 'Cheez',
      lat: 23.8084,
      lng: 90.4143,
      offer: '20% OFF',
    ),
    Restaurant(
      id: '12',
      name: 'Nando’s',
      lat: 23.8076,
      lng: 90.4186,
      offer: 'Peri-Peri Deal',
    ),
    Restaurant(
      id: '13',
      name: 'Herfy',
      lat: 23.8069,
      lng: 90.4201,
      offer: 'Family Combo',
    ),
    Restaurant(
      id: '14',
      name: 'BBQ Tonight',
      lat: 23.8053,
      lng: 90.4174,
      offer: '15% OFF',
    ),
    Restaurant(
      id: '15',
      name: 'Tasty Treat',
      lat: 23.8041,
      lng: 90.4159,
      offer: 'Free Dessert',
    ),
    Restaurant(
      id: '16',
      name: 'Star Kabab',
      lat: 23.8030,
      lng: 90.4188,
      offer: 'Kebab Platter',
    ),
    Restaurant(
      id: '17',
      name: 'Kabab Factory',
      lat: 23.8022,
      lng: 90.4210,
      offer: '10% OFF',
    ),
    Restaurant(
      id: '18',
      name: 'The Manhattan Fish Market',
      lat: 23.8015,
      lng: 90.4192,
      offer: 'Seafood Combo',
    ),
    Restaurant(
      id: '19',
      name: 'Café Rio',
      lat: 23.8007,
      lng: 90.4168,
      offer: 'Happy Hour',
    ),
    Restaurant(
      id: '20',
      name: 'Pizza Roma',
      lat: 23.7998,
      lng: 90.4149,
      offer: 'Buy 1 Get 1',
    ),
  ];


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onListScroll);
  }

  void _onListScroll() {
    if (_isProgrammaticScroll) return;

    final index = (_scrollController.offset / itemWidth).round();
    if (index != _currentIndex && index >= 0 && index < restaurants.length) {
      _currentIndex = index;
      _animateMapToRestaurant(index);
    }
  }

  void _animateMapToRestaurant(int index) {
    final restaurant = restaurants[index];

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(restaurant.lat, restaurant.lng),
          zoom: 15,
        ),
      ),
    );

    _mapController?.showMarkerInfoWindow(
      MarkerId(restaurant.id),
    );
  }

  void _scrollToRestaurant(int index) {
    _isProgrammaticScroll = true;

    _scrollController.animateTo(
      index * itemWidth,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ).then((_) {
      _isProgrammaticScroll = false;
    });
  }

  Set<Marker> _buildMarkers() {
    return restaurants.asMap().entries.map((entry) {
      final index = entry.key;
      final restaurant = entry.value;

      return Marker(
        markerId: MarkerId(restaurant.id),
        position: LatLng(restaurant.lat, restaurant.lng),
        infoWindow: InfoWindow(
          title: restaurant.offer,
          snippet: restaurant.name,
        ),
        onTap: () {
          _scrollToRestaurant(index);
          _animateMapToRestaurant(index);
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            trafficEnabled: true,
            indoorViewEnabled: true,
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(
                restaurants.first.lat,
                restaurants.first.lng,
              ),
              zoom: 14,
              tilt: 59.440717697143555
            ),
            markers: _buildMarkers(),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(
                    restaurant: restaurants[index],
                    isSelected: index == _currentIndex,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
