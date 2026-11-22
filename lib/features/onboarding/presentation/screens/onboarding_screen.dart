import '../../../../core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  static const titles=[
    'Find Your Next\nFavorite Movie Here',
    'Discover Movies','Create Watchlists','Explore All Genres',
    'Rate, Review, and Learn','Start Watching Now',
  ];
  static const descriptions=[
    'Get access to a huge library of movies to suit all tastes. You will surely like it.',
    'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
    'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
    'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
    "Share your thoughts on the movies you've watched. Dive deep into film details and help others discover great movies with your reviews.",
    '',
  ];
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>OnboardingCubit(getIt()),child:const _OnboardingBody());
}
/// The artwork is deliberately text-free. All captions and actions below are
/// real Flutter widgets, rather than duplicate text baked into a JPG image.
class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody();

  @override
  Widget build(BuildContext context) => BlocBuilder<OnboardingCubit, int>(
    builder: (context, step) => Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: constraints.maxHeight * .77,
              child: Image.asset(
                AppAssets.onboarding(step),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x22121312),
                      AppColors.background,
                    ],
                    stops: [0.44, 0.67, 0.82],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * .64,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(16.w, 19.h, 16.w, 13.h),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22.r),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.text(context, OnboardingScreen.titles[step]),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: step == 0 ? 23.sp : 19.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                            ),
                          ),
                          if (OnboardingScreen.descriptions[step].isNotEmpty) ...[
                            SizedBox(height: 9.h),
                            Text(
                              OnboardingScreen.descriptions[step],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFC8C8C8),
                                fontSize: 14.sp,
                                height: 1.25,
                              ),
                            ),
                          ],
                          SizedBox(height: 17.h),
                          PrimaryButton(
                            text: step == 0
                                ? 'Explore Now'
                                : step == 5
                                    ? 'Finish'
                                    : 'Next',
                            height: 50,
                            onPressed: () async {
                              if (step == 5) {
                                await context.read<OnboardingCubit>().finish();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRouter.login,
                                    (_) => false,
                                  );
                                }
                              } else {
                                context.read<OnboardingCubit>().next();
                              }
                            },
                          ),
                          if (step > 1) ...[
                            SizedBox(height: 10.h),
                            PrimaryButton(
                              text: 'Back',
                              height: 45,
                              outlined: true,
                              foreground: AppColors.accent,
                              onPressed: () =>
                                  context.read<OnboardingCubit>().back(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
