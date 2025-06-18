import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/platform_helper.dart';
import '../theme/app_theme.dart';

// Tambahkan ini di bagian atas file, setelah import
// Ini untuk memastikan MaterialLocalizations tersedia di AdaptiveAppBar

// Scaffold Adaptif
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  
  const AdaptiveScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.floatingActionButtonLocation,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    
    if (PlatformHelper.shouldUseMaterial) {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
    } else {
      // Untuk Cupertino, kita perlu membuat layout yang manual menangani
      // bottomNavigationBar dan floatingActionButton
      
      // Periksa apakah appBar adalah AdaptiveAppBar dan ambil propertinya
      CupertinoNavigationBar? cupertinoNavBar;
      if (appBar is AdaptiveAppBar) {
        final adaptiveAppBar = appBar as AdaptiveAppBar;
        cupertinoNavBar = CupertinoNavigationBar(
          middle: Text(
            adaptiveAppBar.title, 
            style: TextStyle(
              color: adaptiveAppBar.foregroundColor ?? (isDarkMode 
                  ? AppTheme.darkTextColor 
                  : AppTheme.textColor),
            ),
          ),
          trailing: adaptiveAppBar.actions != null && adaptiveAppBar.actions!.isNotEmpty
              ? (adaptiveAppBar.actions!.length == 1
                  ? adaptiveAppBar.actions!.first
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: adaptiveAppBar.actions!,
                    ))
              : null,
          automaticallyImplyLeading: adaptiveAppBar.automaticallyImplyLeading,
          leading: adaptiveAppBar.leading,
          backgroundColor: adaptiveAppBar.backgroundColor ?? (isDarkMode 
              ? CupertinoColors.systemGrey6.darkColor 
              : CupertinoColors.systemGrey6),
          border: const Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey4,
              width: 0.0,
            ),
          ),
        );
      }
      
      Widget content = CupertinoPageScaffold(
        navigationBar: cupertinoNavBar,
        backgroundColor: backgroundColor ?? (isDarkMode 
            ? AppTheme.darkBackgroundColor 
            : AppTheme.backgroundColor),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: SafeArea(
          bottom: bottomNavigationBar == null, // Hanya true jika tidak ada bottomNavigationBar
          top: cupertinoNavBar != null, // Jika ada navbar, SafeArea tidak perlu padding top
          child: Stack(
            fit: StackFit.expand,
            children: [
              body,
              if (floatingActionButton != null)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: floatingActionButton!,
                ),
            ],
          ),
        ),
      );
      
      // Jika ada bottom navigation, wrap dengan Column
      if (bottomNavigationBar != null) {
        content = Column(
          children: [
            Expanded(child: content),
            bottomNavigationBar!,
          ],
        );
      }
      
      return content;
    }
  }
}

// AppBar Adaptif
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool? centerTitle;
  
  const AdaptiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    
    if (PlatformHelper.shouldUseMaterial) {
      return AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: leading,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        centerTitle: centerTitle ?? false,
      );
    } else {
      return CupertinoNavigationBar(
        middle: Text(
          title,
          style: TextStyle(
            color: foregroundColor ?? (isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor),
          ),
        ),
        trailing: actions != null && actions!.isNotEmpty
            ? (actions!.length == 1
                ? actions!.first
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ))
            : null,
        leading: leading ??
            (automaticallyImplyLeading
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.back,
                      color: foregroundColor ?? (isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor),
                    ),
                  )
                : null),
        backgroundColor: backgroundColor ?? (isDarkMode ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6),
      );
    }
  }
  
  @override
  Size get preferredSize => PlatformHelper.shouldUseMaterial 
      ? const Size.fromHeight(kToolbarHeight) 
      : const Size.fromHeight(44.0);
}

// Button Adaptif
class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? height;
  
  const AdaptiveButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.minWidth,
    this.height,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.shouldUseMaterial) {
      Widget buttonChild = isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isFullWidth ? 16 : 14,
              ),
            );
      
      if (icon != null && !isLoading) {
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: buttonChild,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary ? AppTheme.primaryColor : null,
            foregroundColor: isPrimary ? Colors.white : null,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: isFullWidth 
                ? Size(double.infinity, height ?? 48) 
                : Size(minWidth ?? 0, height ?? 0),
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary ? AppTheme.primaryColor : null,
            foregroundColor: isPrimary ? Colors.white : null,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: isFullWidth 
                ? Size(double.infinity, height ?? 48) 
                : Size(minWidth ?? 0, height ?? 0),
          ),
          child: buttonChild,
        );
      }
    } else {
      Widget buttonChild = isLoading
          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
          : Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isFullWidth ? 16 : 14,
              ),
            );
      
      // Buat button yang dibungkus sesuai kebutuhan
      Widget button = CupertinoButton(
        onPressed: onPressed,
        color: isPrimary ? AppTheme.primaryColor : null,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        minSize: height ?? (isFullWidth ? 48 : 44),
        child: icon != null && !isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  buttonChild,
                ],
              )
            : buttonChild,
      );
      
      // Jika perlu full width, bungkus dengan SizedBox
      if (isFullWidth) {
        button = SizedBox(
          width: double.infinity,
          child: button,
        );
      } else if (minWidth != null) {
        button = SizedBox(
          width: minWidth,
          child: button,
        );
      }
      
      return button;
    }
  }
}

// TextField Adaptif
class AdaptiveTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final String? helperText;
  final String? errorText;
  
  const AdaptiveTextField({
    Key? key,
    required this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.helperText,
    this.errorText,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    
    if (PlatformHelper.shouldUseMaterial) {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: placeholder,
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          helperText: helperText,
          errorText: errorText,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        focusNode: focusNode,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        autofocus: autofocus,
        textInputAction: textInputAction,
        maxLines: maxLines,
        minLines: minLines,
        readOnly: readOnly,
      );
    } else {
      // Widget yang akan menampilkan error jika ada
      Widget? errorWidget;
      if (errorText != null && errorText!.isNotEmpty) {
        errorWidget = Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Text(
            errorText!,
            style: const TextStyle(
              color: CupertinoColors.systemRed,
              fontSize: 12,
            ),
          ),
        );
      } else if (validator != null && controller != null) {
        // Jika tidak ada error explicit, gunakan validator
        final error = validator!(controller!.text);
        if (error != null && error.isNotEmpty) {
          errorWidget = Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              error,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
              ),
            ),
          );
        }
      }
      
      // Widget helper text
      Widget? helperWidget;
      if (helperText != null && helperText!.isNotEmpty) {
        helperWidget = Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Text(
            helperText!,
            style: TextStyle(
              color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
              fontSize: 12,
            ),
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              placeholder,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
              ),
            ),
          ),
          CupertinoTextField(
            controller: controller,
            prefix: prefix != null 
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: prefix,
                  ) 
                : null,
            suffix: suffix != null 
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: suffix,
                  ) 
                : null,
            obscureText: obscureText,
            keyboardType: keyboardType,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            autofocus: autofocus,
            textInputAction: textInputAction,
            maxLines: maxLines,
            minLines: minLines,
            readOnly: readOnly,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null 
                    ? CupertinoColors.systemRed 
                    : (isDarkMode ? CupertinoColors.systemGrey4.darkColor : CupertinoColors.systemGrey4),
              ),
            ),
          ),
          if (errorWidget != null) errorWidget,
          if (helperWidget != null && errorWidget == null) helperWidget,
        ],
      );
    }
  }
}

// Switch Adaptif
class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveTrackColor;
  final Color? activeTrackColor;
  
  const AdaptiveSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveTrackColor,
    this.activeTrackColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.shouldUseMaterial) {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeTrackColor ?? AppTheme.primaryColor.withAlpha(128),
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return activeColor ?? AppTheme.primaryColor;
          }
          return Colors.grey.shade400;
        }),
        inactiveTrackColor: inactiveTrackColor,
      );
    } else {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor ?? AppTheme.primaryColor,
        thumbColor: Colors.white,
      );
    }
  }
}

// ProgressIndicator Adaptif
class AdaptiveProgressIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  
  const AdaptiveProgressIndicator({
    Key? key,
    this.color,
    this.size,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.shouldUseMaterial) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: color != null 
              ? AlwaysStoppedAnimation<Color>(color!) 
              : null,
          strokeWidth: size != null ? size! / 10 : 4.0,
        ),
      );
    } else {
      return CupertinoActivityIndicator(
        color: color,
        radius: size != null ? size! / 2 : 10.0,
      );
    }
  }
}

// Dialog Adaptif - Renamed to showAdaptiveAlertDialog to avoid conflict
Future<T?> showAdaptiveAlertDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  String? cancelText,
  String confirmText = 'OK',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
}) {
  if (PlatformHelper.shouldUseMaterial) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel();
              },
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onConfirm != null) onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  } else {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel();
              },
              isDestructiveAction: true,
              child: Text(cancelText),
            ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              if (onConfirm != null) onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

// Adaptif Route
PageRoute<T> adaptivePageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool fullscreenDialog = false,
}) {
  if (PlatformHelper.shouldUseMaterial) {
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  } else {
    return CupertinoPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }
}

// BottomNavigation Adaptif
class AdaptiveBottomNavigation extends StatelessWidget {
  final List<BottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  
  const AdaptiveBottomNavigation({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    
    if (PlatformHelper.shouldUseMaterial) {
      return BottomNavigationBar(
        items: items.map((item) => item.materialItem).toList(),
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: activeColor ?? AppTheme.primaryColor,
        unselectedItemColor: inactiveColor ?? (isDarkMode 
            ? AppTheme.darkMutedTextColor 
            : AppTheme.mutedTextColor),
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
      );
    } else {
      return CupertinoTabBar(
        items: items.map((item) => item.cupertinoItem).toList(),
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: activeColor ?? AppTheme.primaryColor,
        inactiveColor: inactiveColor ?? (isDarkMode 
            ? AppTheme.darkMutedTextColor 
            : AppTheme.mutedTextColor),
        backgroundColor: backgroundColor,
      );
    }
  }
}

class BottomNavigationItem {
  final String label;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  
  const BottomNavigationItem({
    required this.label,
    required this.materialIcon,
    required this.cupertinoIcon,
  });
  
  BottomNavigationBarItem get materialItem => BottomNavigationBarItem(
    icon: Icon(materialIcon),
    label: label,
  );
  
  BottomNavigationBarItem get cupertinoItem => BottomNavigationBarItem(
    icon: Icon(cupertinoIcon),
    label: label,
  );
}

// AdaptiveTabBar
class AdaptiveTabBar extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  
  const AdaptiveTabBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    
    if (PlatformHelper.shouldUseMaterial) {
      return TabBar(
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        onTap: onTap,
        controller: TabController(
          length: tabs.length,
          initialIndex: currentIndex,
          vsync: ScrollableState(),
        ),
        labelColor: activeColor ?? AppTheme.primaryColor,
        unselectedLabelColor: inactiveColor ?? (isDarkMode 
            ? AppTheme.darkMutedTextColor 
            : AppTheme.mutedTextColor),
        indicatorColor: activeColor ?? AppTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
      );
    } else {
      return CupertinoSlidingSegmentedControl<int>(
        children: { for (var i in List.generate(tabs.length, (index) => index)) i : Text(
            tabs[i],
            style: TextStyle(
              color: i == currentIndex 
                  ? (activeColor ?? AppTheme.primaryColor) 
                  : (inactiveColor ?? (isDarkMode 
                      ? AppTheme.darkMutedTextColor 
                      : AppTheme.mutedTextColor)),
            ),
          ) },
        groupValue: currentIndex,
        onValueChanged: (value) {
          if (value != null) onTap(value);
        },
        backgroundColor: backgroundColor ?? (isDarkMode
            ? AppTheme.darkCardColor
            : AppTheme.secondaryColor),
      );
    }
  }
}

// AdaptiveListTile
class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;
  final EdgeInsetsGeometry? contentPadding;
  
  const AdaptiveListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
    this.contentPadding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.shouldUseMaterial) {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        isThreeLine: isThreeLine,
        contentPadding: contentPadding,
      );
    } else {
      // Membuat versi cupertino dari ListTile
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      );
    }
  }
}

// AdaptiveForm
class AdaptiveForm extends StatelessWidget {
  final Widget child;
  final GlobalKey<FormState>? formKey;
  final VoidCallback? onChanged;
  
  const AdaptiveForm({
    Key? key,
    required this.child,
    this.formKey,
    this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Form berfungsi sama untuk Material dan Cupertino
    return Form(
      key: formKey,
      onChanged: onChanged,
      child: child,
    );
  }
}

// AdaptiveScrollView - Wrapper for ScrollView with platform-specific behaviors
class AdaptiveScrollView extends StatelessWidget {
  final Widget child;
  final bool primary;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  
  const AdaptiveScrollView({
    Key? key,
    required this.child,
    this.primary = false,
    this.physics,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final adaptivePhysics = physics ?? (PlatformHelper.shouldUseMaterial
        ? const ClampingScrollPhysics()
        : const BouncingScrollPhysics());
    
    return SingleChildScrollView(
      primary: primary,
      physics: adaptivePhysics,
      padding: padding,
      child: child,
    );
  }
}

// AdaptiveActionSheet - Bottom sheet/action sheet
Future<T?> showAdaptiveActionSheet<T>({
  required BuildContext context,
  required String title,
  required List<AdaptiveActionSheetAction> actions,
  AdaptiveActionSheetAction? cancelAction,
}) {
  if (PlatformHelper.shouldUseMaterial) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ...actions.map((action) => ListTile(
            leading: action.icon != null ? Icon(action.icon) : null,
            title: Text(action.title),
            onTap: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
          )),
          if (cancelAction != null) ...[
            const Divider(),
            ListTile(
              leading: cancelAction.icon != null ? Icon(cancelAction.icon) : null,
              title: Text(cancelAction.title),
              onTap: () {
                Navigator.of(context).pop();
                cancelAction.onPressed();
              },
            ),
          ],
        ],
      ),
    );
  } else {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: actions.map((action) => CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            action.onPressed();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (action.icon != null) ...[
                Icon(action.icon),
                const SizedBox(width: 8),
              ],
              Text(action.title),
            ],
          ),
        )).toList(),
        cancelButton: cancelAction != null ? CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            cancelAction.onPressed();
          },
          isDestructiveAction: cancelAction.isDestructive,
          child: Text(cancelAction.title),
        ) : null,
      ),
    );
  }
}

class AdaptiveActionSheetAction {
  final String title;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDestructive;
  
  const AdaptiveActionSheetAction({
    required this.title,
    this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
}

// AdaptiveGestureDetector - Unified gesture detector with platform-specific feedback
class AdaptiveGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapCallback? onDoubleTap;
  
  const AdaptiveGestureDetector({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.shouldUseMaterial) {
      return InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: child,
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: child,
      );
    }
  }
}

// AdaptiveRadio - Radio button yang bekerja di kedua platform
class AdaptiveRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final Color? activeColor;
  
  const AdaptiveRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    final isSelected = value == groupValue;
    
    if (PlatformHelper.shouldUseMaterial) {
      return Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: activeColor ?? AppTheme.primaryColor,
      );
    } else {
      // Implementasi manual untuk Cupertino
      return GestureDetector(
        onTap: () {
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected 
                  ? (activeColor ?? AppTheme.primaryColor) 
                  : (isDarkMode ? Colors.grey[400]! : Colors.grey[600]!),
              width: 2,
            ),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor ?? AppTheme.primaryColor,
                    ),
                  ),
                )
              : null,
        ),
      );
    }
  }

  
}

// Tambahkan widget ini ke file adaptive_widgets.dart Anda yang sudah ada
// Letakkan setelah AdaptiveAppBar

// AdaptiveBackButton - Widget yang hilang
class AdaptiveBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AdaptiveBackButton({
    Key? key,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformHelper.isDarkMode(context);
    
    if (PlatformHelper.shouldUseMaterial) {
      return IconButton(
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: color ?? (isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor),
        ),
      );
    } else {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        child: Icon(
          CupertinoIcons.back,
          color: color ?? (isDarkMode ? AppTheme.darkTextColor : AppTheme.textColor),
        ),
      );
    }
  }
}

// AdaptiveIcon - Widget tambahan yang berguna
class AdaptiveIcon extends StatelessWidget {
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final double? size;
  final Color? color;

  const AdaptiveIcon({
    Key? key,
    required this.materialIcon,
    required this.cupertinoIcon,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      PlatformHelper.shouldUseMaterial ? materialIcon : cupertinoIcon,
      size: size,
      color: color,
    );
  }
}