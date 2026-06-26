import '../models/trailer.dart';

const _cast = [
  CastMember(
    name: 'Ryan G.',
    role: 'Eli Voss',
    imageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
  ),
  CastMember(
    name: 'Ana D.',
    role: 'Mira',
    imageUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
  ),
  CastMember(
    name: 'Leo K.',
    role: 'Archivist',
    imageUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
  ),
  CastMember(
    name: 'Maya R.',
    role: 'Nova',
    imageUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  ),
];

final trailers = [
  Trailer(
    id: 'neon-shadows',
    youtubeVideoId: 'eTrEcLBsCBM', // Dune: Part Two trailer
    title: 'Neon Shadows',
    tagline: 'The future is not what it used to be.',
    synopsis:
        'In a sprawling metropolis where memories can be bought and sold, a rogue detective uncovers a conspiracy that threatens the fabric of human consciousness itself.',
    backdropUrl:
        'https://img.youtube.com/vi/eTrEcLBsCBM/maxresdefault.jpg',
    posterUrl:
        'https://img.youtube.com/vi/eTrEcLBsCBM/hqdefault.jpg',
    genres: ['Sci-Fi', 'Action', 'Cyberpunk'],
    language: 'English',
    certificate: 'A',
    runtime: '2h 15m',
    releaseDate: 'Oct 12',
    releaseCountdown: 'In cinemas soon',
    hypeScore: 98,
    views: '3.2M',
    studio: 'Netflix Original',
    director: 'Denis Villeneuve',
    cast: _cast,
  ),
  Trailer(
    id: 'echoes',
    youtubeVideoId: 'giXco2jaZ_4', // Interstellar trailer
    title: 'Echoes of Tomorrow',
    tagline: 'A city remembers what people forget.',
    synopsis:
        'A brilliant sound designer hears fragments of future disasters hidden inside old recordings and races to decode them before the next signal becomes real.',
    backdropUrl:
        'https://img.youtube.com/vi/giXco2jaZ_4/maxresdefault.jpg',
    posterUrl:
        'https://img.youtube.com/vi/giXco2jaZ_4/hqdefault.jpg',
    genres: ['Sci-Fi', 'Thriller'],
    language: 'English',
    certificate: 'UA 16+',
    runtime: '2h 04m',
    releaseDate: 'Nov 08',
    releaseCountdown: '24 days',
    hypeScore: 94,
    views: '2.4M',
    studio: 'TB Select',
    director: 'Nia Joseph',
    cast: _cast.reversed.toList(),
  ),
  Trailer(
    id: 'frontier',
    youtubeVideoId: 'zSWdZVtXT7E', // Gravity trailer
    title: 'The Last Frontier',
    tagline: 'Beyond the storm, a signal waits.',
    synopsis:
        'When a research crew vanishes near Jupiter, a rescue pilot follows one impossible transmission into a beautiful and terrifying unknown.',
    backdropUrl:
        'https://img.youtube.com/vi/zSWdZVtXT7E/maxresdefault.jpg',
    posterUrl:
        'https://img.youtube.com/vi/zSWdZVtXT7E/hqdefault.jpg',
    genres: ['Adventure', 'Drama'],
    language: 'English',
    certificate: 'UA',
    runtime: '2h 31m',
    releaseDate: 'Dec 01',
    releaseCountdown: 'Releasing in 3 days',
    hypeScore: 88,
    views: '1.7M',
    studio: 'Apple TV+',
    director: 'Karan Malhotra',
    cast: _cast,
  ),
  Trailer(
    id: 'sultans-legacy',
    youtubeVideoId: 'Ke1Y3P9D0Bc', // Kalki 2898-AD trailer
    title: "Sultan's Legacy",
    tagline: 'Every crown has a shadow.',
    synopsis:
        'A reluctant heir returns to Hyderabad and discovers that his family empire is built on one explosive secret.',
    backdropUrl:
        'https://img.youtube.com/vi/Ke1Y3P9D0Bc/maxresdefault.jpg',
    posterUrl:
        'https://img.youtube.com/vi/Ke1Y3P9D0Bc/hqdefault.jpg',
    genres: ['Bollywood', 'Drama'],
    language: 'Hindi',
    certificate: 'UA 13+',
    runtime: '2h 22m',
    releaseDate: 'Jan 19',
    releaseCountdown: 'Coming soon',
    hypeScore: 91,
    views: '980K',
    studio: 'Red Chillies',
    director: 'Aisha Khan',
    cast: _cast.reversed.toList(),
  ),
  Trailer(
    id: 'paper-moon',
    youtubeVideoId: 'WFaJmNlGsyE', // RRR trailer
    title: 'Paper Moon Protocol',
    tagline: 'The mission was never on Earth.',
    synopsis:
        'A Telugu space thriller about three engineers who fake a satellite failure to stop a political cover-up.',
    backdropUrl:
        'https://img.youtube.com/vi/WFaJmNlGsyE/maxresdefault.jpg',
    posterUrl:
        'https://img.youtube.com/vi/WFaJmNlGsyE/hqdefault.jpg',
    genres: ['Telugu', 'Thriller'],
    language: 'Telugu',
    certificate: 'UA',
    runtime: '1h 58m',
    releaseDate: 'Feb 02',
    releaseCountdown: '39 days',
    hypeScore: 86,
    views: '1.2M',
    studio: 'Mythri',
    director: 'Vikram Rao',
    cast: _cast,
  ),
];

final homeSections = <String, List<Trailer>>{
  'Trending Now': [trailers[1], trailers[0], trailers[2]],
  'Most Awaited': [trailers[3], trailers[4], trailers[0]],
  'Coming Soon': [trailers[2], trailers[3], trailers[4]],
  'Hollywood': [trailers[0], trailers[1], trailers[2]],
  'Bollywood': [trailers[3], trailers[1], trailers[4]],
  'Telugu': [trailers[4], trailers[0], trailers[2]],
  'Tamil': [trailers[2], trailers[3], trailers[1]],
  'Korean': [trailers[1], trailers[2], trailers[0]],
  'OTT Originals': [trailers[0], trailers[2], trailers[3]],
};
