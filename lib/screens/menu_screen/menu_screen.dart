import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}

/*
ListView.builder(
  itemCount: masterCategories.length,
  itemBuilder: (context, mIndex) {
    final master = masterCategories[mIndex];

    return ExpansionTile(
      title: Text(master.name),
      children: [
        FutureBuilder<List<CategoryModel>>(
          future: RealtimeDbHelper.instance.getCategoriesByMaster(master.id),
          builder: (context, catSnap) {
            if (!catSnap.hasData) return CircularProgressIndicator();

            return Column(
              children: catSnap.data!.map((category) {
                return ExpansionTile(
                  title: Text(category.name),
                  children: [
                    FutureBuilder<List<ProductModel>>(
                      future: RealtimeDbHelper.instance
                          .getProductsByCategory(category.id),
                      builder: (context, prodSnap) {
                        if (!prodSnap.hasData) return SizedBox();

                        return Column(
                          children: prodSnap.data!
                              .map((p) => ListTile(
                                    title: Text(p.name),
                                    trailing: Text('₹${p.price}'),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  },
);

*/