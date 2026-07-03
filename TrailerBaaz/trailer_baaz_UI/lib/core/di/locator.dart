import 'package:get_it/get_it.dart';

import '../data/home_experience_provider.dart';
import '../data/youtube_trailers_provider.dart';
import '../repositories/i_trailer_repository.dart';
import '../repositories/trailer_repository.dart';
import '../services/i_trailer_service.dart';
import '../services/youtube_service.dart';
import '../navigation/navigation_service.dart';
import '../../features/notifications/controllers/notification_controller.dart';
import '../../features/notifications/services/local_notification_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<NavigationService>(
    () => NavigationService(navigatorKey),
  );
  // Services
  locator.registerLazySingleton<ITrailerService>(() => YouTubeService());
  locator.registerLazySingleton<LocalNotificationService>(
      () => LocalNotificationService());

  // Repositories
  locator.registerLazySingleton<ITrailerRepository>(
      () => TrailerRepository(locator()));

  // Controllers
  locator.registerLazySingleton<NotificationController>(
      () => NotificationController());

  // Providers
  locator.registerLazySingleton<YoutubeTrailersProvider>(
      () => YoutubeTrailersProvider(locator()));
  locator.registerLazySingleton<HomeExperienceProvider>(
      () => HomeExperienceProvider());
}
