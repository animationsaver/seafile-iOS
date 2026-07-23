//
//  SeafTabBarStyler.m
//  seafile
//

#import "SeafTabBarStyler.h"
#import "SeafTheme.h"
#import "Constants.h"

@implementation SeafTabBarStyler

+ (void)applyStandardAppearanceToTabBar:(UITabBar *)tabBar {
    // Apple-standard: selected items use the system accent (systemBlue).
    UIColor *selectedColor = [UIColor systemBlueColor];
    UIColor *normalColor = [SeafTheme secondaryText];

    tabBar.tintColor = selectedColor;
    tabBar.unselectedItemTintColor = normalColor;
    tabBar.translucent = NO;

    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SeafTheme primaryBackgroundColor];
        appearance.shadowColor = [UIColor opaqueSeparatorColor];

        // Under an explicit (opaque) appearance, item colors come from the
        // itemAppearance rather than tabBar.tintColor, so configure all three
        // layout variants to keep the accent tint consistent.
        NSArray<UITabBarItemAppearance *> *itemAppearances = @[
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance,
        ];
        for (UITabBarItemAppearance *itemAppearance in itemAppearances) {
            itemAppearance.selected.iconColor = selectedColor;
            itemAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: selectedColor};
            itemAppearance.normal.iconColor = normalColor;
            itemAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: normalColor};
        }

        tabBar.standardAppearance = appearance;
        tabBar.scrollEdgeAppearance = appearance;
    }
}

@end
