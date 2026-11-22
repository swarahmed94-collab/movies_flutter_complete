import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/movie.dart';

/// Shows the YTS YouTube trailer inside Movies. This is NOT full-film streaming.
/// Uses the Movie entity already supplied by the existing API repository.
class MoviesTrailerPlayerScreen extends StatefulWidget {
  const MoviesTrailerPlayerScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MoviesTrailerPlayerScreen> createState() =>
      _MoviesTrailerPlayerScreenState();
}

class _MoviesTrailerPlayerScreenState extends State<MoviesTrailerPlayerScreen> {
  YoutubePlayerController? _controller;

  bool get _hasTrailer => _controller != null;

  @override
  void initState() {
    super.initState();
    final videoId = widget.movie.trailerCode.trim();
    // YTS gives a YouTube video ID (not a playable full-movie URL).
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(videoId)) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          playsInline: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Uri get _youtubeTrailerUrl => Uri.https(
        'www.youtube.com',
        '/watch',
        {'v': widget.movie.trailerCode.trim()},
      );

  Uri get _youtubeFullMovieSearchUrl {
    final title = widget.movie.title.trim();
    final year = widget.movie.year > 0 ? ' ${widget.movie.year}' : '';
    return Uri.https(
      'www.youtube.com',
      '/results',
      {'search_query': '$title$year full movie official'},
    );
  }

  Future<void> _openExternal(Uri url) async {
    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Could not open YouTube.');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not open YouTube.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // youtube_player_iframe 5.x: the Scaffold wrapper provides fullscreen.
    final controller = _controller;
    if (controller == null) {
      return _screen(context, const _UnavailableTrailer());
    }
    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => _screen(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: player,
            ),
            YoutubeValueBuilder(
              controller: controller,
              builder: (context, value) {
                if (!value.hasError) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    'This trailer cannot be played here. Open it on YouTube instead.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.destructive,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _screen(BuildContext context, Widget videoArea) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const AppIcon('assets/icons/back.svg', size: 25),
        ),
        title: Text(
          'Watch Trailer',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.movie.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                'Official YouTube trailer, when available',
                style: TextStyle(
                  color: AppColors.onSurfaceMuted,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 17.h),
              videoArea,
              SizedBox(height: 24.h),
              if (_hasTrailer) ...[
                PrimaryButton(
                  text: 'Open Trailer on YouTube',
                  height: 48,
                  outlined: true,
                  color: AppColors.accent,
                  foreground: AppColors.accent,
                  onPressed: () => _openExternal(_youtubeTrailerUrl),
                ),
                SizedBox(height: 12.h),
              ],
              PrimaryButton(
                text: 'Find Full Movie on YouTube',
                height: 48,
                color: AppColors.destructive,
                foreground: Colors.white,
                onPressed: () => _openExternal(_youtubeFullMovieSearchUrl),
              ),
              SizedBox(height: 11.h),
              Text(
                'Opens YouTube search results. A full-length, legally available version is not guaranteed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceMuted,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableTrailer extends StatelessWidget {
  const _UnavailableTrailer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      alignment: Alignment.center,
      child: Text(
        'No YouTube trailer is available for this movie.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 15.sp),
      ),
    );
  }
}
