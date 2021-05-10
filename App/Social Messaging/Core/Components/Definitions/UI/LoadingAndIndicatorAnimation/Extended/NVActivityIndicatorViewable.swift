#if canImport(UIKit)
import UIKit
//import NVActivityIndicatorView

/**
 *  UIViewController conforms this protocol to be able to display NVActivityIndicatorView as UI blocker.
 *
 *  This extends abilities of UIViewController to display and remove UI blocker.
 */
@available(*, deprecated, message: "")
public protocol NVActivityIndicatorViewable {}

@available(*, deprecated, message: "")
public extension NVActivityIndicatorViewable where Self: UIViewController {

    /// Current status of animation, read-only.
    var isAnimating: Bool { return NVActivityIndicatorPresenter.sharedInstance.isAnimating }

    /**
     Display UI blocker.

     Appropriate NVActivityIndicatorView.DEFAULT_* values are used for omitted params.

     - parameter size:                 size of activity indicator view.
     - parameter message:              message displayed under activity indicator view.
     - parameter messageFont:          font of message displayed under activity indicator view.
     - parameter type:                 animation type.
     - parameter color:                color of activity indicator view.
     - parameter padding:              padding of activity indicator view.
     - parameter displayTimeThreshold: display time threshold to actually display UI blocker.
     - parameter minimumDisplayTime:   minimum display time of UI blocker.
     - parameter fadeInAnimation:      fade in animation.
     */
    func startAnimating(
        _ size: CGSize? = nil,
        message: String? = nil,
        messageFont: UIFont? = nil,
        type: NVActivityIndicatorType? = nil,
        color: UIColor? = nil,
        padding: CGFloat? = nil,
        displayTimeThreshold: Int? = nil,
        minimumDisplayTime: Int? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        fadeInAnimation: FadeInAnimation? = NVActivityIndicatorView.DEFAULT_FADE_IN_ANIMATION) {
        let activityData = ActivityData(size: size,
                                        message: message,
                                        messageFont: messageFont,
                                        type: type,
                                        color: color,
                                        padding: padding,
                                        displayTimeThreshold: displayTimeThreshold,
                                        minimumDisplayTime: minimumDisplayTime,
                                        backgroundColor: backgroundColor,
                                        textColor: textColor)

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, fadeInAnimation)
    }

    /**
     Remove UI blocker.

     - parameter fadeOutAnimation: fade out animation.
     */
    func stopAnimating(_ fadeOutAnimation: FadeOutAnimation? = NVActivityIndicatorView.DEFAULT_FADE_OUT_ANIMATION) {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(fadeOutAnimation)
    }
}
#endif
