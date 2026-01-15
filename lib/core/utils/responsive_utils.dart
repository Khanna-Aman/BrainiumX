import 'package:flutter/material.dart';

/// Comprehensive responsive design utilities for BrainiumX
/// Handles all screen sizes from phones to tablets to desktops
class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Minimum and maximum constraints
  static const double minScreenWidth = 320;
  static const double maxContentWidth = 1200;
  
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Get responsive grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 4;
    }
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    switch (deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding);
      case DeviceType.tablet:
        return EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding);
      case DeviceType.desktop:
        return EdgeInsets.fromLTRB(32, 32, 32, 32 + bottomPadding);
    }
  }
  
  /// Get responsive content width with max constraint
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth;
      case DeviceType.tablet:
        return (screenWidth * 0.9).clamp(minScreenWidth, 800);
      case DeviceType.desktop:
        return (screenWidth * 0.8).clamp(minScreenWidth, maxContentWidth);
    }
  }
  
  /// Get responsive font size scaling
  static double getFontScale(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.desktop:
        return 1.2;
    }
  }
  
  /// Get responsive game grid size for optimal gameplay
  static double getGameGridSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = getDeviceType(context);
    final padding = getScreenPadding(context);
    
    // Calculate available space
    final availableWidth = screenSize.width - padding.horizontal;
    final availableHeight = screenSize.height - padding.vertical - 200; // Reserve for UI
    
    // Choose smaller dimension for square grid
    final maxSize = availableWidth < availableHeight ? availableWidth : availableHeight;
    
    switch (deviceType) {
      case DeviceType.mobile:
        return maxSize.clamp(250, 400);
      case DeviceType.tablet:
        return maxSize.clamp(300, 500);
      case DeviceType.desktop:
        return maxSize.clamp(350, 600);
    }
  }
  
  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 48;
      case DeviceType.tablet:
        return 52;
      case DeviceType.desktop:
        return 56;
    }
  }
  
  /// Get responsive icon size
  static double getIconSize(BuildContext context, {IconSizeType type = IconSizeType.normal}) {
    final deviceType = getDeviceType(context);
    final baseSize = switch (type) {
      IconSizeType.small => 16.0,
      IconSizeType.normal => 24.0,
      IconSizeType.large => 32.0,
      IconSizeType.xlarge => 48.0,
    };
    
    final scale = switch (deviceType) {
      DeviceType.mobile => 1.0,
      DeviceType.tablet => 1.2,
      DeviceType.desktop => 1.4,
    };
    
    return baseSize * scale;
  }
  
  /// Get responsive spacing
  static double getSpacing(BuildContext context, {SpacingType type = SpacingType.normal}) {
    final deviceType = getDeviceType(context);
    final baseSpacing = switch (type) {
      SpacingType.xs => 4.0,
      SpacingType.small => 8.0,
      SpacingType.normal => 16.0,
      SpacingType.large => 24.0,
      SpacingType.xlarge => 32.0,
    };
    
    final scale = switch (deviceType) {
      DeviceType.mobile => 1.0,
      DeviceType.tablet => 1.2,
      DeviceType.desktop => 1.4,
    };
    
    return baseSpacing * scale;
  }
  
  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Get safe area insets
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  /// Get responsive card aspect ratio
  static double getCardAspectRatio(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);
    
    if (isLandscapeMode) {
      return switch (deviceType) {
        DeviceType.mobile => 2.0,
        DeviceType.tablet => 2.2,
        DeviceType.desktop => 2.5,
      };
    } else {
      return switch (deviceType) {
        DeviceType.mobile => 1.5,
        DeviceType.tablet => 1.6,
        DeviceType.desktop => 1.8,
      };
    }
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Icon size type enumeration
enum IconSizeType {
  small,
  normal,
  large,
  xlarge,
}

/// Spacing type enumeration
enum SpacingType {
  xs,
  small,
  normal,
  large,
  xlarge,
}

/// Responsive widget wrapper
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool centerContent;
  
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.centerContent = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final contentWidth = maxWidth ?? ResponsiveUtils.getContentWidth(context);
    
    if (centerContent) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: child,
        ),
      );
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: contentWidth),
      child: child,
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? forceColumns;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.forceColumns,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? ResponsiveUtils.getGridColumns(context);
    final aspectRatio = childAspectRatio ?? ResponsiveUtils.getCardAspectRatio(context);
    final mainSpacing = mainAxisSpacing ?? ResponsiveUtils.getSpacing(context);
    final crossSpacing = crossAxisSpacing ?? ResponsiveUtils.getSpacing(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: mainSpacing,
        crossAxisSpacing: crossSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
