import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_router.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../cubit/profile_controller.dart';

/// نقطة الدخول لفيتشر الـ Profile.
/// Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileFlow()));
class ProfileFlow extends StatefulWidget {
  const ProfileFlow({super.key, this.initialRoute = ProfileRoutes.basicInfo});

  /// الشاشة اللي يبدأ منها (افتراضيًا أول شاشة). للتجربة: ProfileRoutes.snapshot ...إلخ
  final String initialRoute;

  @override
  State<ProfileFlow> createState() => _ProfileFlowState();
}

class _ProfileFlowState extends State<ProfileFlow> {
  final _controller = ProfileController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      controller: _controller,
      child: Navigator(
        initialRoute: widget.initialRoute,
        // شاشة واحدة بس، من غير شاشات مكررة تحتها
        onGenerateInitialRoutes: (navigator, name) => [ProfileRouter.generate(RouteSettings(name: name))],
        onGenerateRoute: ProfileRouter.generate,
      ),
    );
  }
}
