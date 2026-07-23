//
//  SeafCell.m
//  seafile
//
//  Created by Wang Wei on 1/19/13.
//  Copyright (c) 2013 Seafile Ltd. All rights reserved.
//

#import "SeafCell.h"
#import "SeafTheme.h"

@implementation SeafCell
@synthesize imageView;
@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize progressView;
@synthesize checkboxImageView;
@synthesize checkboxWidthConstraint;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Set cell background color to transparent
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        // Disable default selection background view
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        // Disable multiple selection background
        self.multipleSelectionBackgroundView = [[UIView alloc] init];
        self.multipleSelectionBackgroundView.backgroundColor = [UIColor clearColor];
        _isStarredCell = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    // Disable default selection background view
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    // Disable multiple selection background
    self.multipleSelectionBackgroundView = [[UIView alloc] init];
    self.multipleSelectionBackgroundView.backgroundColor = [UIColor clearColor];
    _isStarredCell = NO;
    
    // Initialize checkbox image view
    if (!self.checkboxImageView) {
        self.checkboxImageView = [[UIImageView alloc] init];
        self.checkboxImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.checkboxImageView];
        
        // Add constraints
        self.checkboxWidthConstraint = [self.checkboxImageView.widthAnchor constraintEqualToConstant:0];
        self.checkboxWidthConstraint.active = YES;
        
        [NSLayoutConstraint activateConstraints:@[
            [self.checkboxImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
            [self.checkboxImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [self.checkboxImageView.heightAnchor constraintEqualToConstant:24],
        ]];
    }
    
    // Set basic properties for cellBackgroundView
    self.cellBackgroundView.backgroundColor = [SeafTheme primarySurface];
    self.cellBackgroundView.clipsToBounds = YES;

    // Add rounded corners to the imageView
    self.imageView.layer.cornerRadius = 5.0f;

    // Dynamic Type (Apple-standard typography): scale the file-list labels
    // relative to their XIB-designed size so they honor the user's preferred
    // content size. UIFontMetrics keeps the size identical at the default
    // content size category and only scales for accessibility, so there is
    // no layout jump for existing rows.
    if (@available(iOS 11.0, *)) {
        if (self.textLabel.font) {
            self.textLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:self.textLabel.font];
        }
        if (self.detailTextLabel.font) {
            self.detailTextLabel.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleFootnote] scaledFontForFont:self.detailTextLabel.font];
        }
    }
    self.textLabel.adjustsFontForContentSizeCategory = YES;
    self.detailTextLabel.adjustsFontForContentSizeCategory = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.isLastCell) {
        // Unified separator inset matching card-style list standard
        self.separatorInset = UIEdgeInsetsMake(0, SEAF_SEPARATOR_LEFT_INSET, 0, SEAF_SEPARATOR_RIGHT_INSET);
    }
    else {
        // reset separatorInset to default.
        self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }
}

- (void)updateCellStyle:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell {
    // Reset corner radius
    self.cellBackgroundView.layer.mask = nil;
    self.cellBackgroundView.layer.cornerRadius = 0;
    self.cellBackgroundView.layer.maskedCorners = 0;
    
    if (!isFirstCell && !isLastCell) {
        // No corner radius for middle cells
        return;
    }
    
    // Set corner radius
    self.cellBackgroundView.layer.cornerRadius = SEAF_CELL_CORNER;
    
    if (isFirstCell && isLastCell) {
        // If it's both the first and last row, all four corners are rounded
        self.cellBackgroundView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner |
                                                     kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    } else if (isFirstCell) {
        // First row, top two corners are rounded
        self.cellBackgroundView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    } else {
        // Last row, bottom two corners are rounded
        self.cellBackgroundView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    }
}

- (void)updateCheckboxImageForSelected:(BOOL)selected
{
    // Apple-standard multi-select indicator: use SF Symbols with semantic
    // colors (accent for the checked state, tertiary label for unchecked),
    // matching the native editing checkmarks in Mail/Photos and removing the
    // previous hard-coded white tints. Falls back to the bundled asset images
    // when SF Symbols are unavailable (iOS < 13).
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightRegular];
        NSString *symbolName = selected ? @"checkmark.circle.fill" : @"circle";
        UIImage *symbol = [UIImage systemImageNamed:symbolName withConfiguration:config];
        if (symbol) {
            self.checkboxImageView.image = [symbol imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.checkboxImageView.tintColor = selected ? [UIColor systemBlueColor] : [UIColor tertiaryLabelColor];
            return;
        }
    }

    // Legacy fallback: bundled asset images (used on iOS < 13).
    NSString *imageName = selected ? @"ic_checkbox_checked" : @"ic_checkbox_unchecked";
    self.checkboxImageView.image = [UIImage imageNamed:imageName];
    self.checkboxImageView.tintColor = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Avoid using system default editing style
//    [super setEditing:editing animated:animated];
    self.isUserEditing = editing;
    if (editing) {
        [self updateCheckboxImageForSelected:self.isSelected];
        self.checkboxWidthConstraint.constant = 24;
    } else {
        self.checkboxImageView.image = nil;
        self.checkboxImageView.tintColor = nil;
        self.checkboxWidthConstraint.constant = 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // Don't call super method, completely override default behavior
     [super setSelected:selected animated:animated];
    
    // Handle checkbox only in editing mode
    if (self.isUserEditing) {
        [self updateCheckboxImageForSelected:selected];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]
            && self.isUserEditing) {
            [self updateCheckboxImageForSelected:self.isSelected];
        }
    }
}

- (void)reset
{
    self.detailTextLabel.text = nil;
    self.detailTextLabel.textColor = Utils.cellDetailTextTextColor;
    self.badgeImage.hidden = true;
    self.badgeLabel.hidden = true;
    self.cacheStatusView.hidden = true;
    self.progressView.hidden = true;
    
    self.imageView.image = nil;

    self.moreButton.hidden = self.isStarredCell ? NO : YES;
    [self resetCellFile];
}

// Cancel thumb task, clear cell seafile, and clear cached thumbnail image in memory
- (void)resetCellFile {
    if (self.cellSeafFile){
        [self.cellSeafFile cancelNotDisplayThumb];
        self.cellSeafFile = nil;
    }
}

- (IBAction)moreButtonTouch:(id)sender {
    if (self.moreButtonBlock) {
        self.moreButtonBlock(self.cellIndexPath);
    }
}

- (void)updateSeparatorInset:(BOOL)isLastCell {
    self.isLastCell = isLastCell;
    if (isLastCell) {
        self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    } else {
        [self setNeedsLayout];
    }
}

@end
