// ignore_for_file: public_member_api_docs, sort_constructors_first
class Cake {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  bool isFavorite;
  final String subMenu;

  Cake({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
    required this.subMenu,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}

final List<Cake> listCakes = [
  Cake(
    id: 1,
    name: 'Cake 1',
    price: '10000',
    imageUrl: 'assets/box1.jpeg',
    isFavorite: true,
    subMenu: 'cake',
  ),
  Cake(
    id: 2,
    name: 'Cake 2',
    price: '20000',
    imageUrl: 'assets/box2.jpeg',
    isFavorite: true,
    subMenu: 'cake',
  ),
  Cake(
    id: 3,
    name: 'Cake 3',
    price: '30000',
    imageUrl: 'assets/box3.jpeg',
    isFavorite: false,
    subMenu: 'cake',
  ),
  Cake(
    id: 4,
    name: 'Cake 4',
    price: '40000',
    imageUrl: 'assets/box4.jpeg',
    isFavorite: true,
    subMenu: 'cake',
  ),
  Cake(
    id: 5,
    name: 'Cake 5',
    price: '50000',
    imageUrl: 'assets/box5.jpeg',
    isFavorite: false,
    subMenu: 'cake',
  ),
  Cake(
    id: 6,
    name: 'Cake 6',
    price: '60000',
    imageUrl: 'assets/box6.jpeg',
    isFavorite: true,
    subMenu: 'cake',
  ),
  Cake(
    id: 7,
    name: 'Bakery 1',
    price: '10000',
    imageUrl: 'assets/box1.jpeg',
    isFavorite: true,
    subMenu: 'bakery',
  ),
  Cake(
    id: 8,
    name: 'Bakery 2',
    price: '20000',
    imageUrl: 'assets/box2.jpeg',
    isFavorite: false,
    subMenu: 'bakery',
  ),
  Cake(
    id: 9,
    name: 'Bakery 3',
    price: '30000',
    imageUrl: 'assets/box3.jpeg',
    isFavorite: false,
    subMenu: 'bakery',
  ),
  Cake(
    id: 10,
    name: 'Bakery 4',
    price: '40000',
    imageUrl: 'assets/box4.jpeg',
    isFavorite: true,
    subMenu: 'bakery',
  ),
  Cake(
    id: 11,
    name: 'Bakery 5',
    price: '50000',
    imageUrl: 'assets/box5.jpeg',
    isFavorite: false,
    subMenu: 'bakery',
  ),
  Cake(
    id: 12,
    name: 'Bakery 6',
    price: '60000',
    imageUrl: 'assets/box6.jpeg',
    isFavorite: true,
    subMenu: 'bakery',
  ),
  Cake(
    id: 13,
    name: 'Bakery 7',
    price: '10000',
    imageUrl: 'assets/box1.jpeg',
    isFavorite: true,
    subMenu: 'bakery',
  ),
  Cake(
    id: 14,
    name: 'Ice 1',
    price: '20000',
    imageUrl: 'assets/box2.jpeg',
    isFavorite: true,
    subMenu: 'ice',
  ),
  Cake(
    id: 15,
    name: 'Ice 2',
    price: '30000',
    imageUrl: 'assets/box3.jpeg',
    isFavorite: true,
    subMenu: 'ice',
  ),
  // Cake(
  //   id: 16,
  //   name: 'Ice 3',
  //   price: '40',
  //   imageUrl: 'assets/box4.jpeg',
  //   isFavorite: true,
  //   subMenu: 'ice',
  // ),
  // Cake(
  //   id: 17,
  //   name: 'Ice 4',
  //   price: '50',
  //   imageUrl: 'assets/box5.jpeg',
  //   isFavorite: false,
  //   subMenu: 'ice',
  // ),
  // Cake(
  //   id: 18,
  //   name: 'Ice 5',
  //   price: '60',
  //   imageUrl: 'assets/box6.jpeg',
  //   isFavorite: true,
  //   subMenu: 'ice',
  // ),
  // Cake(
  //   id: 19,
  //   name: 'Ice 6',
  //   price: '10',
  //   imageUrl: 'assets/box1.jpeg',
  //   isFavorite: true,
  //   subMenu: 'ice',
  // ),
  // Cake(
  //   id: 20,
  //   name: 'Ice 7',
  //   price: '20',
  //   imageUrl: 'assets/box2.jpeg',
  //   isFavorite: false,
  //   subMenu: 'ice',
  // ),
  // Cake(
  //   id: 21,
  //   name: 'Ice 8',
  //   price: '30',
  //   imageUrl: 'assets/box3.jpeg',
  //   isFavorite: false,
  //   subMenu: 'ice',
  // ),
];
