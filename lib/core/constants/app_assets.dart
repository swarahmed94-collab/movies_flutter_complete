abstract final class AppAssets {
  static const brandSymbolRaster = 'assets/images/brand_symbol_raster.png';
  static const splashFooterRaster = 'assets/images/splash_footer_raster.png';
  static const emptyMovies = 'assets/images/empty_movies.png';
  static const availableNow = 'assets/images/available_now.png';
  static const watchNow = 'assets/images/watch_now.png';
  static String onboarding(int index) => 'assets/images/onboarding_art_$index.jpg';
  static String avatar(int index) => 'assets/images/avatar_${index.clamp(0, 8)}.png';
  static const homeIcon = 'assets/icons/home.svg';
  static const searchIcon = 'assets/icons/search.svg';
  static const browseIcon = 'assets/icons/browse.svg';
  static const profileIcon = 'assets/icons/profile.svg';
  static const bookmarkIcon = 'assets/icons/bookmark.svg';
}
