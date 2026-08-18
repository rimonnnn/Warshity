import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/routing/app_routes.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({
    super.key,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width,
  });

  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool isLoading = false;

  Future<void> _logout() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Logout من Firebase
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // بعد الـ Logout يروح للـ Login
      context.go(AppRoutes.loginScreen);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: 52.h,
      child: FilledButton.icon(
        onPressed: isLoading ? null : _logout,

        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                widget.icon ?? Icons.logout_rounded,
              ),

        label: Text(
          isLoading
              ? 'Logging out...'
              : widget.title ?? 'Logout',
        ),

        style: FilledButton.styleFrom(
          backgroundColor:
              widget.backgroundColor ?? Colors.red,
          foregroundColor:
              widget.foregroundColor ?? Colors.white,
          disabledBackgroundColor:
              (widget.backgroundColor ?? Colors.red)
                  .withOpacity(.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}