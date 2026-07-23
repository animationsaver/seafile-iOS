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

    [self applySFSymbolsToTabBarItems:tabBar];
}

// Apple-standard iconography: replace the bundled tab images with SF Symbols.
// The mapping is keyed off each item's tag, which initTabController sets to the
// fixed TABBED_* index (0 Libraries, 1 Starred, 2 Wikis, 3 Activity,
// 4 Settings). Keying off the tag keeps the icons correct even when the
// optional Wiki/Activity tabs are hidden and the visible order changes.
+ (void)applySFSymbolsToTabBarItems:(UITabBar *)tabBar {
    if (@available(iOS 13.0, *)) {
        NSDictionary<NSNumber *, NSArray<NSString *> *> *symbolsByTag = @{
            @0 : @[@"folder", @"folder.fill"],       // Libraries
            @1 : @[@"star", @"star.fill"],            // Starred
            @2 : @[@"book", @"book.fill"],            // Wikis
            @3 : @[@"clock", @"clock.fill"],          // Activity
            @4 : @[@"gearshape", @"gearshape.fill"],  // Settings
        };
        for (UITabBarItem *item in tabBar.items) {
            NSArray<NSString *> *names = symbolsByTag[@(item.tag)];
            if (!names) continue;
            UIImage *normal = [UIImage systemImageNamed:names.firstObject];
            if (normal) {
                item.image = normal;
                UIImage *selected = [UIImage systemImageNamed:names.lastObject];
                item.selectedImage = selected ?: normal;
            }
        }
    }
}

@end
