import 'package:flutter/material.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final List<String> _cartItems = []; // List to store items added to the cart

  void _addToCart(String itemName) {
    setState(() {
      _cartItems.add(itemName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _goToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: _cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 10, // Number of items in the marketplace
          itemBuilder: (context, index) {
            final itemName = 'Item ${index + 1}';
            return Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add a light gradient background for the image section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 202, 216, 240),
                            Colors.blue.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        size: 30,
                        color: const Color.fromARGB(255, 53, 51, 51),
                      ),
                    ),
                  ),
                  // Add item name with a soft style
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      itemName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Add price with a soft green style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '\$${(index + 1) * 10}',
                      style: TextStyle(
                        color: Color.fromARGB(255, 91, 31, 229),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Add a "Buy Now" button with light colors
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 216, 240), // Light button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () => _addToCart(itemName), // Add item to cart
                      child: Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCartPage, // Set the icon
        backgroundColor:const Color.fromARGB(255, 159, 188, 239), // Navigate to the CartPage
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<String> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: const Color.fromARGB(255, 110, 179, 235),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.shopping_cart, color: const Color.fromARGB(255, 19, 36, 49)),
                  title: Text(
                    cartItems[index],
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}