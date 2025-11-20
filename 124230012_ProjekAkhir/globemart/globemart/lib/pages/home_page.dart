import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../pages/product_detail_page.dart';
import '../providers/cart_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ProductProvider>(context, listen: false).loadData());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GlobeMart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: () {},
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(Icons.notifications_none, size: 26),
                  if (cart.totalItems > 0)
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('${cart.totalItems}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                    ),
                ],
              ),
            ),
          )
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF130f40), Color(0xFF22124b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // header / search card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF23103f), Color(0xFF4f3fff)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 12)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.storefront, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Hi, Shopper', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 2),
                                Text('Discover Neon Deals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.filter_list, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      // search field
                      TextField(
                        controller: searchController,
                        onChanged: provider.search,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // categories horizontal (fixed)
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    GestureDetector(
                      onTap: provider.resetFilter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white12),
                        child: const Center(child: Text('All', style: TextStyle(color: Colors.white))),
                      ),
                    ),
                    for (var c in provider.categories)
                      GestureDetector(
                        onTap: () => provider.filterByCategory(c.name),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white10),
                          child: Center(child: Text(c.name, style: const TextStyle(color: Colors.white70))),
                        ),
                      )
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // product grid
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.loadData();
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.66,
                          ),
                          itemCount: provider.filteredProducts.length,
                          itemBuilder: (context, index) {
                            final ProductModel p = provider.filteredProducts[index];
                            return _ProductCard(product: p);
                          },
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

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product.price;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1b0f2b), Color(0xFF4f3fff)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.18), blurRadius: 10, offset: const Offset(0,6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(product.thumbnail, fit: BoxFit.cover, errorBuilder: (_,__ ,___) => Container(color: Colors.black26, child: const Icon(Icons.broken_image, color: Colors.white70))),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                        child: Text('⭐ ${product.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                      const Spacer(),
                      Text('USD ${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)));
                          },
                          child: const Text('Detail'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFff4ecf)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
