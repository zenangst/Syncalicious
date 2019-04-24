import Cocoa

class AnimationFactory {
  func createBasicAnimation(keyPath: String) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: keyPath)
    animation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    return animation
  }

  func createAnimationGroup(_ animations: [CAAnimation]) -> CAAnimationGroup {
    let animationGroup = CAAnimationGroup()
    animationGroup.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    animationGroup.animations = animations
    animationGroup.isRemovedOnCompletion = false
    return animationGroup
  }
}
