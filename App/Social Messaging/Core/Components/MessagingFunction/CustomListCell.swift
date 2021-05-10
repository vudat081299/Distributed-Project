//
//  CustomListCell.swift
//  Social Messaging
//
//  Created by Dat vu on 17/04/2021.
//

import UIKit

enum Section: Hashable {
    case main
}

struct Category: Hashable {
    let icon: UIImage?
    let name: String?
    
    static let music = Category(icon: UIImage(systemName: "music.mic"), name: "Music")
    static let transportation = Category(icon: UIImage(systemName: "car"), name: "Transportation")
    static let weather = Category(icon: UIImage(systemName: "cloud.rain"), name: "Weather")
}

struct Item: Hashable {
    let category: Category
    let image: UIImage?
    let title: String?
    let description: String?
    init(category: Category, imageName: String? = nil, title: String? = nil, description: String? = nil) {
        self.category = category
        if let imageNameNonOptional = imageName {
            if let subImage = UIImage(systemName: imageNameNonOptional) {
                self.image = subImage
            } else {
                let aImageView = UIImageView(image: UIImage(named: imageNameNonOptional))
                aImageView.frame = CGRect(x: aImageView.frame.origin.x, y: aImageView.frame.origin.y, width: 40, height: 40)
                self.image = aImageView.image
            }
           
        } else {
            self.image = nil
        }
        self.title = title
        self.description = description
    }
    private let identifier = UUID()
    
//    static let all = [
//        Item(category: .music, imageName: "headphones", title: "Headphones",
//             description: "A portable pair of earphones that are used to listen to music and other forms of audio."),
//        Item(category: .music, imageName: "hifispeaker.fill", title: "Loudspeaker",
//             description: "A device used to reproduce sound by converting electrical impulses into audio waves."),
//        Item(category: .transportation, imageName: "airplane", title: "Plane",
//             description: "A commercial airliner used for long distance travel."),
//        Item(category: .transportation, imageName: "tram.fill", title: "Tram",
//             description: "A trolley car used as public transport in cities."),
//        Item(category: .transportation, imageName: "car.fill", title: "Car",
//             description: "A personal vehicle with four wheels that is able to carry a small number of people."),
//        Item(category: .weather, imageName: "hurricane", title: "Hurricane",
//             description: "A tropical cyclone in the Caribbean with violent wind."),
//        Item(category: .weather, imageName: "tornado", title: "Tornado",
//             description: "A destructive vortex of swirling violent winds that advances beneath a large storm system."),
//        Item(category: .weather, imageName: "tropicalstorm", title: "Tropical Storm",
//             description: "A localized, intense low-pressure system, forming over tropical oceans."),
//        Item(category: .weather, imageName: "snow", title: "Snow",
//             description: "Atmospheric water vapor frozen into ice crystals falling in light flakes.")
//    ]
    static let all = [
        Item(category: .music, imageName: "avatar_13", title: "Headphones",
             description: "A portable pair of earphones that are used to listen to music and other forms of audio.A portable pair of earphones that are used to listen to music and other forms of audio.A portable pair of earphones that are used to listen to music and other forms of audio.A portable pair of earphones that are used to listen to music and other forms of audio.A portable pair of earphones that are used to listen to music and other forms of audio."),
        Item(category: .music, imageName: "avatar_1", title: "Loudspeaker",
             description: "A device used to reproduce sound by converting electrical impulses into audio waves."),
        Item(category: .transportation, imageName: "avatar_1", title: "Plane",
             description: "A commercial airliner used for long distance travel."),
        Item(category: .transportation, imageName: "avatar_1", title: "Tram",
             description: "A trolley car used as public transport in cities."),
        Item(category: .transportation, imageName: "avatar_1", title: "Car",
             description: "A personal vehicle with four wheels that is able to carry a small number of people."),
        Item(category: .weather, imageName: "avatar_1", title: "Hurricane",
             description: "A tropical cyclone in the Caribbean with violent wind."),
        Item(category: .weather, imageName: "avatar_1", title: "Tornado",
             description: "A destructive vortex of swirling violent winds that advances beneath a large storm system."),
        Item(category: .weather, imageName: "avatar_1", title: "Tropical Storm",
             description: "A localized, intense low-pressure system, forming over tropical oceans."),
        Item(category: .weather, imageName: "avatar_12", title: "Snow",
             description: "Atmospheric water vapor frozen into ice crystals falling in light flakes."),
        Item(category: .weather, imageName: "avatar_12", title: "Snow",
             description: "Atmospheric water vapor frozen into ice crystals falling in light flakes."),
        Item(category: .weather, imageName: "avatar_1", title: "Tropical Storm",
             description: "A localized, intense low-pressure system, forming over tropical oceans."),
        Item(category: .weather, imageName: "avatar_1", title: "Tropical Storm",
             description: "A localized, intense low-pressure system, forming over tropical oceans.")
    ]
}

// Declare a custom key for a custom `item` property.
fileprivate extension UIConfigurationStateCustomKey {
    static let item = UIConfigurationStateCustomKey("com.apple.ItemListCell.item")
}

// Declare an extension on the cell state struct to provide a typed property for this custom state.
private extension UICellConfigurationState {
    var item: Item? {
        set { self[.item] = newValue }
        get { return self[.item] as? Item }
    }
}

// This list cell subclass is an abstract class with a property that holds the item the cell is displaying,
// which is added to the cell's configuration state for subclasses to use when updating their configuration.
class ItemListCell: UICollectionViewListCell {
    private var item: Item? = nil
    
    func updateWithItem(_ newItem: Item) {
        guard item != newItem else { return }
        item = newItem
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.item = self.item
        return state
    }
}

class CustomListCell: ItemListCell {
    static let reuseIdentifier = "CustomListCell"
    private let maxWidthOfImage = 60
    
    private func defaultListContentConfiguration() -> UIListContentConfiguration { return .subtitleCell() }
    private lazy var listContentView = UIListContentView(configuration: defaultListContentConfiguration())
    
    private let categoryIconView = UIImageView()
    private let categoryLabel = UILabel()
    private var customViewConstraints: (categoryLabelLeading: NSLayoutConstraint,
                                        categoryLabelTrailing: NSLayoutConstraint,
                                        categoryIconTrailing: NSLayoutConstraint)?
    
    private func setupViewsIfNeeded() {
        // We only need to do anything if we haven't already setup the views and created constraints.
        guard customViewConstraints == nil else { return }
        
        contentView.addSubview(listContentView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryIconView)
        listContentView.translatesAutoresizingMaskIntoConstraints = false
        let defaultHorizontalCompressionResistance = listContentView.contentCompressionResistancePriority(for: .horizontal)
        listContentView.setContentCompressionResistancePriority(defaultHorizontalCompressionResistance - 1, for: .horizontal)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = (
            categoryLabelLeading: categoryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: listContentView.trailingAnchor),
            categoryLabelTrailing: categoryIconView.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor),
            categoryIconTrailing: contentView.trailingAnchor.constraint(equalTo: categoryIconView.trailingAnchor)
        )
        NSLayoutConstraint.activate([
            listContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            listContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            constraints.categoryLabelLeading,
            constraints.categoryLabelTrailing,
            constraints.categoryIconTrailing
        ])
        customViewConstraints = constraints
    }
    
    private var separatorConstraint: NSLayoutConstraint?
    private func updateSeparatorConstraint() {
        guard let textLayoutGuide = listContentView.textLayoutGuide else { return }
        if let existingConstraint = separatorConstraint, existingConstraint.isActive {
            return
        }
        let constraint = separatorLayoutGuide.leadingAnchor.constraint(equalTo: textLayoutGuide.leadingAnchor)
        constraint.isActive = true
        separatorConstraint = constraint
    }
    
    /// - Tag: UpdateConfiguration
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        self.setupViewsIfNeeded()
        
        // Configure the list content configuration and apply that to the list content view.
        var content = self.defaultListContentConfiguration().updated(for: state)
        
//        DispatchQueue.global(qos: .utility).async { [weak self] in
//            guard let self = self else { return }
            // Perform your work here
            // ...
            content.image = state.item?.image
            content.imageProperties.preferredSymbolConfiguration = .init(font: content.textProperties.font, scale: .large)
            content.imageProperties.maximumSize = CGSize(width: self.maxWidthOfImage, height: self.maxWidthOfImage)
            content.imageProperties.cornerRadius = CGFloat(self.maxWidthOfImage) / 2
            content.text = state.item?.title
            
            // Switch back to the main queue to
            // update your UI
//            DispatchQueue.main.async {
                if (state.item?.description?.count)! > 90 {
                    var string = state.item?.description!
                    let range = string!.index(string!.startIndex, offsetBy: 90)..<string!.endIndex
                    string!.removeSubrange(range)
                    content.secondaryText = string! + "..."
                } else {
                    content.secondaryText = state.item?.description
                }
                content.secondaryTextProperties.color = .systemGray2
                
                content.axesPreservingSuperviewLayoutMargins = []
                self.listContentView.configuration = content
                
                // Get the list value cell configuration for the current state, which we'll use to obtain the system default
                // styling and metrics to copy to our custom views.
                let valueConfiguration = UIListContentConfiguration.valueCell().updated(for: state)
                
                // Configure custom image view for the category icon, copying some of the styling from the value cell configuration.
                self.categoryIconView.image = state.item?.category.icon
                self.categoryIconView.tintColor = valueConfiguration.imageProperties.resolvedTintColor(for: self.tintColor)
                self.categoryIconView.preferredSymbolConfiguration = .init(font: valueConfiguration.secondaryTextProperties.font, scale: .small)
                
                // Configure custom label for the category name, copying some of the styling from the value cell configuration.
                self.categoryLabel.text = state.item?.category.name
                self.categoryLabel.textColor = valueConfiguration.secondaryTextProperties.resolvedColor()
                self.categoryLabel.font = valueConfiguration.secondaryTextProperties.font
                self.categoryLabel.adjustsFontForContentSizeCategory = valueConfiguration.secondaryTextProperties.adjustsFontForContentSizeCategory
                
                // Update some of the constraints for our custom views using the system default metrics from the configurations.
                self.customViewConstraints?.categoryLabelLeading.constant = content.directionalLayoutMargins.trailing
                self.customViewConstraints?.categoryLabelTrailing.constant = valueConfiguration.textToSecondaryTextHorizontalPadding
                self.customViewConstraints?.categoryIconTrailing.constant = content.directionalLayoutMargins.trailing
                self.updateSeparatorConstraint()
//            }
//        }
    }
}

