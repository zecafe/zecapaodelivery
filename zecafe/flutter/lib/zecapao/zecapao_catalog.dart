class ZecapaoPartner {
  final String name;
  final String asset;
  final String category;
  final List<String> tags;
  const ZecapaoPartner(this.name, this.asset, this.category, [this.tags = const []]);
}

class ZecapaoCategory {
  final String id;
  final String name;
  final String emoji;
  const ZecapaoCategory(this.id, this.name, this.emoji);
}

abstract final class ZecapaoCatalog {
  static const categories = <ZecapaoCategory>[
    ZecapaoCategory('food', 'Comer & Beber', '🍽️'),
    ZecapaoCategory('markets', 'Mercados', '🛒'),
    ZecapaoCategory('shops', 'Lojas', '🛍️'),
    ZecapaoCategory('lodging', 'Hospedagem', '🏡'),
    ZecapaoCategory('experiences', 'Passeios & Experiências', '🥾'),
    ZecapaoCategory('services', 'Turismo & Serviços', '🧭'),
    ZecapaoCategory('events', 'Eventos', '🎟️'),
  ];

  static const partners = <ZecapaoPartner>[
    ZecapaoPartner('Comercial Bastos', 'assets/zecapao/partners/comercial_bastos.jpg', 'markets'),
    ZecapaoPartner('Café NuValle', 'assets/zecapao/partners/cafe_nuvalle.jpg', 'food', ['Café']),
    ZecapaoPartner('Frutos', 'assets/zecapao/partners/frutos.jpg', 'food'),
    ZecapaoPartner('Garimpo Burger', 'assets/zecapao/partners/garimpo_burger.jpg', 'food', ['Hambúrguer']),
    ZecapaoPartner('Gatto Sete Bistrô', 'assets/zecapao/partners/gatto_sete.jpg', 'food', ['Bistrô']),
    ZecapaoPartner('Green', 'assets/zecapao/partners/green.jpg', 'food'),
    ZecapaoPartner('Zecafé', 'assets/zecapao/partners/zecafe.jpg', 'food', ['Café']),
    ZecapaoPartner('Mandioca Gastrobar', 'assets/zecapao/partners/mandioca_gastrobar.jpg', 'food', ['Gastrobar']),
    ZecapaoPartner('Ôxe Restô', 'assets/zecapao/partners/oxe_resto.jpg', 'food', ['Restaurante']),
    ZecapaoPartner('Paulistano Capão', 'assets/zecapao/partners/paulistano_capao.jpg', 'food', ['Restaurante']),
    ZecapaoPartner('Pico do Açaí', 'assets/zecapao/partners/pico_do_acai.jpg', 'food', ['Açaí', 'Lanches']),
    ZecapaoPartner('Pizza Lab', 'assets/zecapao/partners/pizza_lab.jpg', 'food', ['Pizza']),
    ZecapaoPartner('Princesas das Empadas', 'assets/zecapao/partners/princesas_das_empadas.jpg', 'food', ['Empadas']),
    ZecapaoPartner('Voraz Sanduicheria', 'assets/zecapao/partners/voraz_sanduicheria.jpg', 'food', ['Sanduíches']),
  ];
}
