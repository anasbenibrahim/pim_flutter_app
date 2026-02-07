import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? iconData;
  final VoidCallback? onPressed;
  final bool isStatic;

  const SocialLoginButton({
    super.key,
    required this.text,
    this.iconPath,
    this.iconData,
    this.onPressed,
    this.isStatic = false,
  });

  Widget _buildIcon() {
    if (iconPath != null) {
      try {
        return Image.asset(
          iconPath!,
          width: 24.w,
          height: 24.h,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        );
      } catch (e) {
        return _buildFallbackIcon();
      }
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    if (iconData != null) {
      return Icon(
        iconData,
        size: 24.sp,
        color: Colors.white,
      );
    }
    // Default icons based on text
    IconData defaultIcon = Icons.login;
    if (text.toLowerCase().contains('google')) {
      defaultIcon = Icons.g_mobiledata;
    } else if (text.toLowerCase().contains('apple')) {
      defaultIcon = Icons.apple;
    } else if (text.toLowerCase().contains('facebook')) {
      defaultIcon = Icons.facebook;
    }
    return Icon(
      defaultIcon,
      size: 24.sp,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isStatic ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
