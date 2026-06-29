import 'package:flutter/material.dart';

import 'app/trailer_baaz_app.dart';
import 'core/data/home_experience_provider.dart';
import 'core/data/youtube_trailers_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Kick off background data load immediately
  YoutubeTrailersProvider.instance.init();
  HomeExperienceProvider.instance.init();
  runApp(const TrailerBaazApp());
}
