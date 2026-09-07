import '../models/product.dart';

/// Static catalogue of 12 products with curated Unsplash lifestyle/product images.
///
/// URL format: images.unsplash.com with w=600&h=700&fit=crop for a consistent
/// portrait aspect ratio that matches the 3:5 product card layout.
const List<Product> kProducts = [
  // ── Apparel ────────────────────────────────────────────────────────────────
  Product(
    id: '1',
    name: 'Classic White Tee',
    description:
        'A timeless staple in premium 100% organic cotton. Relaxed fit, crew neck, and pre-washed for softness from the first wear. Available in sizes XS–XXL.',
    // Clean white t-shirt on wooden hanger — Unsplash by @shootdelicious
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=700&fit=crop&q=80',
    category: 'Apparel',
    price: 29.99,
    rating: 4.7,
    reviewCount: 312,
  ),
  Product(
    id: '2',
    name: 'Slim Chino Pants',
    description:
        'Versatile slim-fit chinos crafted from stretch-cotton blend. Perfect from the office to the weekend. Features zip fly, front pockets, and a clean hem.',
    // Folded slim trousers lifestyle flat-lay — Unsplash by @charlesdeluvio
    imageUrl:
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600&h=700&fit=crop&q=80',
    category: 'Apparel',
    price: 64.99,
    rating: 4.5,
    reviewCount: 198,
  ),
  Product(
    id: '6',
    name: 'Oversized Hoodie',
    description:
        'Drop-shoulder hoodie in 320gsm French terry fleece. Kangaroo pocket, ribbed cuffs, and a brushed interior for warmth without the bulk.',
    // Oversized grey hoodie flatlay on clean surface — Unsplash by @itshoobastank
    imageUrl:
        'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=600&h=700&fit=crop&q=80',
    category: 'Apparel',
    price: 74.99,
    rating: 4.7,
    reviewCount: 356,
  ),
  Product(
    id: '9',
    name: 'Linen Button-Up Shirt',
    description:
        'Breathable 100% European linen shirt with a relaxed fit. Single chest pocket, mother-of-pearl buttons, and a curved hem. Ideal for warm weather.',
    // White linen button-up shirt on hanger — Unsplash by @nimolamo
    imageUrl:
        'https://images.unsplash.com/photo-1602810319428-019690571b5b?w=600&h=700&fit=crop&q=80',
    category: 'Apparel',
    price: 59.99,
    rating: 4.5,
    reviewCount: 222,
  ),

  // ── Accessories ────────────────────────────────────────────────────────────
  Product(
    id: '3',
    name: 'Leather Crossbody Bag',
    description:
        'Full-grain vegetable-tanned leather crossbody bag. Adjustable strap, interior zip pocket, and magnetic snap closure. Ages beautifully over time.',
    // Structured leather handbag on clean surface — Unsplash by @annapelzer
    imageUrl:
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&h=700&fit=crop&q=80',
    category: 'Accessories',
    price: 89.99,
    rating: 4.8,
    reviewCount: 405,
  ),
  Product(
    id: '4',
    name: 'Minimalist Watch',
    description:
        'Stainless steel case with sapphire crystal glass and genuine leather strap. Slim 8mm profile. Japanese quartz movement. 5ATM water resistant.',
    // Silver minimalist watch macro shot on white — Unsplash by @icons8
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&h=700&fit=crop&q=80',
    category: 'Accessories',
    price: 149.99,
    rating: 4.9,
    reviewCount: 520,
  ),
  Product(
    id: '10',
    name: 'Canvas Tote Bag',
    description:
        '12oz waxed canvas tote with leather-wrapped handles and an interior zip pocket. Holds up to 20kg. Machine washable.',
    // Natural canvas tote bag editorial flat-lay — Unsplash by @marceloleal80
    imageUrl:
        'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&h=700&fit=crop&q=80',
    category: 'Accessories',
    price: 39.99,
    rating: 4.3,
    reviewCount: 176,
  ),

  // ── Footwear ───────────────────────────────────────────────────────────────
  Product(
    id: '5',
    name: 'Running Sneakers',
    description:
        'Lightweight mesh upper with responsive foam midsole. Breathable design for long-distance comfort. Reflective details for low-light safety.',
    // Bold colourway running sneaker product shot — Unsplash by @bryangarces
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&h=700&fit=crop&q=80',
    category: 'Footwear',
    price: 119.99,
    rating: 4.6,
    reviewCount: 287,
  ),
  Product(
    id: '12',
    name: 'Chelsea Boots',
    description:
        'Pull-on leather Chelsea boots with elastic side panels and a stacked heel. Leather-lined interior for all-day comfort. Resoleable construction.',
    // Classic brown leather Chelsea boot product shot — Unsplash
    imageUrl:
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=600&h=700&fit=crop&q=80',
    category: 'Footwear',
    price: 169.99,
    rating: 4.8,
    reviewCount: 389,
  ),

  // ── Home & Kitchen ─────────────────────────────────────────────────────────
  Product(
    id: '7',
    name: 'Ceramic Pour-Over Set',
    description:
        'Hand-thrown ceramic dripper and matching carafe. Brews 2–4 cups. Dishwasher safe glaze. Comes with 40 bonded paper filters.',
    // Ceramic pour-over coffee brewing lifestyle — Unsplash by @nate_dumlao
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&h=700&fit=crop&q=80',
    category: 'Home & Kitchen',
    price: 54.99,
    rating: 4.4,
    reviewCount: 133,
  ),
  Product(
    id: '8',
    name: 'Scented Soy Candle',
    description:
        'Hand-poured 8oz soy wax candle with a cotton wick. Notes of cedarwood, vanilla, and amber. Burns cleanly for up to 45 hours.',
    // Hand-poured candle with warm scent — Unsplash
    imageUrl:
        'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=600&h=700&fit=crop&q=80',
    category: 'Home & Kitchen',
    price: 24.99,
    rating: 4.6,
    reviewCount: 441,
  ),

  // ── Electronics ────────────────────────────────────────────────────────────
  Product(
    id: '11',
    name: 'Wireless Earbuds',
    description:
        'True wireless earbuds with 8-hour battery life and 24-hour charging case. Active noise cancellation, IPX4 water resistance, and touch controls.',
    // White wireless earbuds floating on pastel background — Unsplash by @elisa_ventur
    imageUrl:
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&h=700&fit=crop&q=80',
    category: 'Electronics',
    price: 79.99,
    rating: 4.5,
    reviewCount: 614,
  ),
];
