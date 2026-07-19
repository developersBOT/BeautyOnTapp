import 'package:beautyontapp/widgets/popular_item.dart';
import 'package:beautyontapp/widgets/promo.dart';
import 'package:beautyontapp/widgets/offer.dart';
import '../models/product.dart';
import '../models/wish_item.dart'; // <-- for Loves/Wishlist

/// Top chips under header
const topCategories = [
  'Brands', 'Skin Care', 'Hair', 'Make Up', 'Men', 'Bath & Body', 'Korean SkinCare', 'Beauty Under R200', 'Mini Size', 'Suncare','Book Skin Analysis', 'Sale & Offer'
];

/// Top promo cards (2 boxes) with image + text + CTA
/// Top promo cards (scrollable row, now 4 items)
const promosTop = [
  Promo(
    imageAsset: 'assets/images/pastry1.png',
    title: 'A Handbag Must Have',
    subtitle: 'Keep Your Lips Soft And Supple All Day Long',
    cta: 'SHOP NOW',
    apiUrl: 'https://beautyontapp.net/api/products/make-up-lips?limit=100',
    brand: 'Make Up - Lips',
  ),
  Promo(
    imageAsset: 'assets/images/pastry2.png',
    title: 'Must Have Pastry Products',
    subtitle: 'Keep Your Hands Supple And Hydrated With Our Hand Creams & More',
    cta: 'SHOP NOW',
    apiUrl: 'https://beautyontapp.net/api/products/pastry-skincare-1?limit=100',
    brand: 'Pastry Skincare',
  ),
  Promo(
    imageAsset: 'assets/images/pastry3.png',
    title: 'Soothe And Calm Your Skin',
    subtitle: 'The Cosrx Propolis Range',
    cta: 'SHOP NOW',
    apiUrl: 'https://beautyontapp.net/api/products/cosrx-1?limit=100',
    brand: 'Cosrx',
  ),
  Promo(
    imageAsset: 'assets/images/pastry4.png',
    title: 'Your Skins Extra Glow',
    subtitle: 'Deep nourishment with our body oils',
    cta: 'SHOP NOW',
    apiUrl: 'https://beautyontapp.net/api/products/body-oil?limit=100',
    brand: 'Body Oil',
  ),
];


/// Beauty Offers (white panel + black border)
const offersBeauty = [
  Offer(
    imageAsset: 'assets/images/offer1.png',
    title: 'Fade Dark Marks Faster With..',
    subtitle:
        'Get 20% off the Glutathione Dark Mark Serum • Replenish & Repair Barrier Serum',
    cta: 'SHOP NOW',
  ),
  Offer(
    imageAsset: 'assets/images/offer1.png', // replace with 2nd asset when ready
    title: 'Travel Sized Convenience',
    subtitle:
        'Targeted skincare, travel-sized convenience. Shop our breakthrough right now.',
    cta: 'SHOP NOW',
  ),
];

/// Chosen For You
const productsChosenForYou = [
  Product(
    id: 'p1',
    title: 'Axis - Y',
    subtitle: 'The Mini Glow Set',
    imageAsset: 'assets/images/p1.png',
    price: 320.0,
    rating: 4.7,
    reviews: 85,
  ),
  Product(
    id: 'p2',
    title: 'Pasty Skin Care',
    subtitle: 'Niacinamide Body Lotion',
    imageAsset: 'assets/images/p2.png',
    price: 320.0,
    rating: 4.9,
    reviews: 102,
  ),
  Product(
    id: 'p3',
    title: 'Acid Toner',
    subtitle: 'Niacinamide 2% Salicylic',
    imageAsset: 'assets/images/p2.png',
    price: 320.0,
    rating: 4.6,
    reviews: 63,
  ),
];

/// New Arrivals
const productsNewArrivals = [
  Product(
    id: 'n1',
    title: 'Axis - Y',
    subtitle: 'The Mini Glow Set',
    imageAsset: 'assets/images/new_arrival_1.png',
    price: 320.0,
    rating: 4.8,
    reviews: 90,
  ),
  Product(
    id: 'n2',
    title: 'Pasty Skin Care',
    subtitle: 'Niacinamide Body Lotion',
    imageAsset: 'assets/images/new_arrival_2.png',
    price: 320.0,
    rating: 4.7,
    reviews: 74,
  ),
  Product(
    id: 'n3',
    title: 'Acid Toner',
    subtitle: 'Niacinamide 2% Salicylic',
    imageAsset: 'assets/images/new_arrival_2.png',
    price: 320.0,
    rating: 4.5,
    reviews: 58,
  ),
];

/// “Check out What’s popular Now!” items (icons scroller)
const popularNow = <PopularItem>[
  PopularItem(title: 'Mini Size',        imageAsset: 'assets/images/shop-tab-mini-1.svg'),
  PopularItem(title: 'Active Body Care', imageAsset: 'assets/images/active1.png'),
  PopularItem(title: 'Serums',           imageAsset: 'assets/images/shop-tab-mini-1.svg'),
  PopularItem(title: 'Body Care',        imageAsset: 'assets/images/pop_mini.png'),
  PopularItem(title: 'Face Masks',       imageAsset: 'assets/images/pop_mini.png'),
  PopularItem(title: 'Cleansers',        imageAsset: 'assets/images/pop_mini.png'),
  PopularItem(title: 'Toners',           imageAsset: 'assets/images/pop_mini.png'),
  PopularItem(title: 'Moisturisers',     imageAsset: 'assets/images/pop_mini.png'),
];

/// Brand logos (placeholder list)
const brandLogos = [
  {"name": "Pastry Skincare", "asset": "assets/images/pastry.1.png"},
  {"name": "Mzuri Skin", "asset": "assets/images/mzuri.svg"},
  {"name": "Standard.", "asset": "assets/images/standard1.png"},
  {"name": "Dermopal", "asset": "assets/images/derm1.png"},
  {"name": "Skin functional", "asset": "assets/images/skin.svg"},
  {"name": "Cerave", "asset": "assets/images/cera.svg"},
];



/// Footer helpers
const featureIcons = [
  {'title': 'Convenient', 'subtitle': 'Easy Payments, returns,\nand exchanges.'},
  {'title': 'Efficient',  'subtitle': 'We Deliver to your door\nwithin 24-72 hours'},
];

const footerStats = [
  {'title': 'Convenient',          'subtitle': 'Easy Payments, returns,\nand exchanges.'},
  {'title': 'Efficient',           'subtitle': 'We Deliver to your door\nwithin 24-72 hours'},
  {'title': 'Wide Variety',        'subtitle': 'Over 1000 beauty\nproducts to shop on\none platform'},
  {'title': 'Find a BeautyOnTApp', 'subtitle': 'Choose your Store'},
];

const footerCols = {
  'About Beauty': [
    'About Us', 'Careers', 'Brands on beauty On TApp', 'Blogs', 'Gift Vouchers'
  ],
  'My Beauty': [
    'Shop All', 'Best Sellers', 'Korean Skin Care', 'MakeUp', 'Hair Care'
  ],
  'Customer Service': [
    'Contact Us', 'Log Return/ Exchange', 'Refund & Return Policy', 'Sell on BeautyOnTApp'
  ],
};

/// Footer contact info
const contactEmail = 'customer@beautyontapp.co.za';
const contactAddress =
    'Fourways Mall, Gateway Theatre of Shopping, Mall of Africa, Merlyn Park';

/// Drawer items (hamburger)
const drawerItems = [
  'Brands','Skin Care','Hair','Make Up','Men','Bath & Body',
  'Korean Skin Care','Beauty Under R200','Mini Size','Suncare',
  'Book Analysis','Sales & offers',
];

/// Demo "Smooch" catalog data for SHOP NOW navigation
const smoochProducts = <Product>[
  Product(
    id: 'sm1',
    title: 'Honeymoon Glow – Brightening Serum',
    subtitle: '',
    imageAsset: 'assets/images/p1.png',
    price: 349.00,
  ),
  Product(
    id: 'sm2',
    title: 'Forever Young – No Filter Needed',
    subtitle: '',
    imageAsset: 'assets/images/new_arrival_1.png',
    price: 349.00,
  ),
  Product(
    id: 'sm3',
    title: 'Eyeconic Eye Firming Serum',
    subtitle: '',
    imageAsset: 'assets/images/p2.png',
    price: 349.00,
  ),
  Product(
    id: 'sm4',
    title: 'Eyecandy – Lash Growth',
    subtitle: '',
    imageAsset: 'assets/images/new_arrival_2.png',
    price: 299.00,
  ),
  Product(
    id: 'sm5',
    title: '(H2) Oh-My – Serious Hydration. Zero Drama',
    subtitle: '',
    imageAsset: 'assets/images/p1.png',
    price: 349.00,
  ),
  Product(
    id: 'sm6',
    title: 'Calm Down – Soothing Serum',
    subtitle: '',
    imageAsset: 'assets/images/p1.png',
    price: 349.00,
  ),
];

/// Loves / Wishlist items
const wishlistItems = <WishItem>[
  WishItem(
    id: 'w1',
    brand: 'FORME',
    imageAsset: 'assets/images/p1.png', // replace with actual product asset
    title: 'Wig Removal Spray',
    price: 195.00,
  ),
];
const brandsByLetter = <String, List<String>>{
  'A': [
    'Afrobotanics',
    'Anasa',
    'ANUA',
    'Amazi Beauty',
    'Avene',
    'Aveeno',
    'AXIS-Y',
  ],
  'B': [
    "B' Air Skin care",
    'Barulab',
    'Beauty of Joseon',
    'Benton',
    'Biodance',
    'Bioderma',
    'Black African Organics',
    'Black Girl Sunscreen',
    'Breast Tape by Si',
  ],
  'C': [
    'Cerave',
    'COSRX',
    'Curl Chemistry',  // Cleaned from "Cur l Chemistry"
  ],
  'D': [
    'Dermopal',
    'Dermalogica',
  ],
  'E': [
    'Essie',
    'Eucerin',
  ],
  'F': [
    'First Seed',
    'Fundamentals',
  ],
  'G': [
    'Garnier',
    'Glamour Beauty',
  ],
  'H': [
    'Haruharu Wonder',  // Cleaned
    'Hermosa Flor',
    'HOM',
    'Huegah',
  ],
  'I': [
    'Isntree',
  ],
  'K': [
    'Kiko Vitals',
    'Koosh Kream',  // Cleaned from "K Vita ls"
    'Kudu Cosmetica',
  ],
  'L': [
    "Laneige",
    'Lanolab',
    "La Roche-Posay",  // Cleaned from "Le l'emin e"
    "Lelive",
    'Lele Feminine',
    'Lelapa La Bakoena',
    'LOreal',
    'Lumi Gio'
  ],
  'M': [
    'Medicube',   // Cleaned from "Mi lford"
    'Mzuri Skin',
    'Manetain',
    'Millford',
    'Mielle'
  ],
  'N': [
    'Nakolwethu',
    'Native Child',
    'Naturallly Africa',  // Cleaned from "Natural y Africa"
    'Naturals Beauty',  // Cleaned from "Natural s Beauty"
    'Neutroherb',
    'Neutrogena',
    'Nilotiqa',
    'Ndanaka',
  ],
  'O': [
      // Cleaned from "O Osti bel"
    'Olio',
    'Ostibel',
  ],
   'P': [
    'Pastry SkinCare',  // Cleaned from "O Osti bel"
    'Purpul Hair',
  ],
  'R': [
    'R&R',  // Cleaned from "O Osti bel"
    'Ren Clear Skin',
  ],
  'S': [
    'Serene',  // Cleaned from "O Osti bel"
    'Some by Mi',
    'Sheba Feminine',
    'Skin Creamery',
    'Skin functional',
    'Skin Republic',
    'Skin 1004',
    'Skinny Colour',
    'Standard',
    'Switchbeauty',
  ],
  'T':[
    'Teaology',
  ],
  'U':[
    'Uso Skincare'
  ],
  'V':[
    'Vichy',
  ],
  'Y':[
    'Yearn'
  ],
  
  // P, R, S, T, U, V, Y: Empty in screenshot, so skipped. Agar add karne ho to batao.
};
// ... (Baaki code same rahega, sirf end mein yeh add karo)

// Skin Care categories (from screenshot)
const skinCareCategories = <String, List<String>>{
  'Skin Type': [
    'Combination & Normal Skin Type',
    'Dry',
    'Oily',
    'Sensitive',
  ],
  'Skin Concern': [
    'Acne',
    'Blemishes',
    'Brightening',
    'Dullness',
    'Hyperpigmentation',
    'Moisturising',
    'Visible Pores',
    'Oily Skin',
    'Soothing',
    'Well-aging',
  ],
  'Skincare Product': [
    'Cleansers',
    'Cleansing Oils',
    'Eye Creams',
    'Face Masks',
    'Exfoliators',
    'Korean Skincare',
    'Health Supplements',
    'Make Up',
    'Moisturisers & Balms',
    'Serums',
    'Skincare Combos & Kits',
    'Sunscreen',
    'Teen Skincare',
    'Toners',
  ],
  'Featured Ingredients': [
    'Alpha Arbutin',
    'Azelaic Acid',
    'Ceramide',
    'Collagen',
    'Hyaluronic Acid',
    'Glutathione',
    'Glycolic Acid',
    'Lactic Acid',
    'Kojic Acid',
    'Mandelic Acid',
    'Niacinamide',
    'Retinol',
    'Salicylic Acid',
    'Squalane',
    'Vitamin C',
    'Tranexamic Acid',
  ],
  'Body Care': [
    'Deodorants and Anti-Perspirants',
    'Body Butters',
    'Body Oil',
    'Body Wash',
    'Exfoliators & Scrubs',
  ],
};
// ... (Baaki code same rahega, sirf end mein yeh add karo)

// Hair categories (from screenshot)
const hairCategories = <String, List<String>>{
  'Brushes & Combs': [
    'Hair Accessories',
    'Hair Care Combos',
    'Hair Extensions',
  ],
  'Hair Concern': [
    'Anti-Dandruff',
    'Damaged Hair',
    'Dryness',
    'Hair Growth',
    'Hydrating',
    'Scalp Care',
    'Thickening',
  ],
  'Treatments': [
    'Hair Butters',
    'Hair Oils',
    'Hair Mists',
    'Leave Ins',
  ],
  'Shampoo & Conditioner': [
    'Shampoos',
    'Conditioners',
  ],
  'Styling': [
    'Edge and Styling Gels',
  ],
};
const makeUpEntries = <String>[
  'Eye',
  'Face',
  'Lips',
  'Nails',
];
const menCategories = <String>[
  'Body Wash & Shower Gel',
  'Beard Serum & Oils',
  'Body Butters & Lotion',
];
const bathAndBodyCategories = <String, List<String>>{
  'Skin Concern': [
    'Body Acne',
    'Brightening',
    'Cellulite',
    'Hand Care',
    'Moisturising',
    'Well-aging',
  ],
  'Skincare Product': [
    'Body Wash & Shower Gel',
    'Body Butter & Lotions',
    'Body Mist & Hair Mist',
    'Deodorant & Antiperspirant',
    'Hand Cream & Foot Cream',
    'Scrubs & Exfoliants',
  ],
  'Scent': [
    'Citrus',
    'Floral',
    'Fresh',
    'Fruity',
    'Woody',
    'Green',
    'Musk',
    'Sweet',
    'Fragnance-Free',
  ],
};
const koreanSkinCareEntries = <String>[
  'Ampoiles & Serums',
  'Cleansers/Oils',
  'Essences & Toners',
  'Moisturizers & Creams',
  'SunCare',
];
const sunCareCategories = <String, List<String>>{
  'Formulation': [
    'Mineral',
    'Chemical',
    'White-Cast Free',
  ],
  'Texture': [
    'Texture',
    'Cream',
    'Gel',
  ],
};
const saleAndOfferCategories = <String>[
  'Beauty offers',
  'Rewards/Loyalty Points',
  'Clearance Sale',
];
const bookSkinAnalysisItems = <Map<String, String>>[
  {'title': 'Skin Type Analysis', 'image': 'p1.png'},
  {'title': 'Skin Concern Analysis', 'image': 'p1.png'},
  {'title': 'Personalized Routine', 'image': 'p1.png'},
];