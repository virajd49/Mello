/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol MaxiPlayerSourceProtocol: class {
    var originatingFrameInWindow: CGRect { get }
    var originatingCoverImageView: UIImageView { get }
}




class MaxiSongCardViewController: UIViewController {
    
    // MARK: - Properties
    let cardCornerRadius: CGFloat = 10
    var trackid: String!
    let primaryDuration = 0.5 //set to 0.5 when ready
    let backingImageEdgeInset: CGFloat = 15.0
    var sourceView: Frame!
    var originatingFrameInWindow: CGRect!
    var originatingCoverImageView: UIImageView!
    var song_name: String!
    var play_bar_time: Float!
    var post : Post!
    
    //scroller
    @IBOutlet weak var scrollView: UIScrollView!
    //this gets colored white to hide the background.
    //It has no height so doesnt contribute to the scrollview content
    @IBOutlet weak var stretchySkirt: UIView!
    
    //cover image
    @IBOutlet weak var coverImageContainer: UIView!
    @IBOutlet weak var coverArtImage: UIImageView!
    @IBOutlet weak var dismissChevron: UIButton!
    //add cover image constraints here
    
    
    //cover image constraints
    @IBOutlet weak var coverImageContainerTopInset: NSLayoutConstraint!
    
    //backing image
    var backingImage: UIImage?
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerLayer: UIView!
    //add backing image constraints here
    //add backing image constraints here
    @IBOutlet weak var backingImageTopInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageLeadingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageTrailingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageBottomInset: NSLayoutConstraint!
    
    @IBOutlet weak var coverImageLeading: NSLayoutConstraint!
    @IBOutlet weak var coverImageTop: NSLayoutConstraint!
    @IBOutlet weak var coverImageBottom: NSLayoutConstraint!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    //lower module constraints
    @IBOutlet weak var lowerModuleTopConstraint: NSLayoutConstraint!
    
    //fake tabbar contraints
    var tabBarImage: UIImage?
    @IBOutlet weak var bottomSectionHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSectionLowerConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSectionImageView: UIImageView!
    
    
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modalPresentationCapturesStatusBarAppearance = true //allow this VC to control the status bar appearance
        modalPresentationStyle = .overFullScreen //dont dismiss the presenting view controller when presented
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backingImageView.image = backingImage
        scrollView.contentInsetAdjustmentBehavior = .never //dont let Safe Area insets affect the scroll view
        
        //sourceView.originatingCoverImageView = originatingCoverImageView
        //sourceView.originatingFrameInWindow = originatingFrameInWindow
        //DELETE THIS LATER
        coverImageContainer.layer.cornerRadius = cardCornerRadius
        coverImageContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        let tapGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        tapGesture.direction = UISwipeGestureRecognizerDirection.down
        self.scrollView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureImageLayerInStartPosition()
        coverArtImage.image = originatingCoverImageView.image
        configureCoverImageInStartPosition()
        stretchySkirt.backgroundColor = .white //from starter project, this hides the gap
        configureLowerModuleInStartPosition()
        configureBottomSection()
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingImageIn()
        animateImageLayerIn()
        animateCoverImageIn()
        animateLowerModuleIn()
        animateBottomSectionOut()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destination = segue.destination as? SongPlayControlViewController {
            destination.currentSong?.songname = trackid
            destination.playbar_progress = play_bar_time
            destination.song_name = post.songname
            destination.currentSong = post
        }
    }
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer){
        animateBackingImageOut()
        animateCoverImageOut()
        animateLowerModuleOut()
        animateBottomSectionIn()
        
        animateImageLayerOut() { _ in
            self.dismiss(animated: false)
        }
    }
    
}

// MARK: - IBActions
extension MaxiSongCardViewController {
    
    @IBAction func dismissAction(_ sender: Any) {
        animateBackingImageOut()
        animateCoverImageOut()
        animateLowerModuleOut()
        animateBottomSectionIn()
        
        animateImageLayerOut() { _ in
            self.dismiss(animated: false)
        }
    }
    
}

//background image animation
extension MaxiSongCardViewController {
    
    //1.
    private func configureBackingImageInPosition(presenting: Bool) {
        let edgeInset: CGFloat = presenting ? backingImageEdgeInset : 0
        let dimmerAlpha: CGFloat = presenting ? 0.3 : 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius : 0
        
        backingImageLeadingInset.constant = edgeInset
        backingImageTrailingInset.constant = edgeInset
        let aspectRatio = backingImageView.frame.height / backingImageView.frame.width
        backingImageTopInset.constant = edgeInset * aspectRatio
        backingImageBottomInset.constant = edgeInset * aspectRatio
        //2.
        dimmerLayer.alpha = dimmerAlpha
        //3.
        backingImageView.layer.cornerRadius = cornerRadius
    }
    
    //4.
    private func animateBackingImage(presenting: Bool) {
        UIView.animate(withDuration: primaryDuration) {
            self.configureBackingImageInPosition(presenting: presenting)
            self.view.layoutIfNeeded() //IMPORTANT!
        }
    }
    
    //5.
    func animateBackingImageIn() {
        animateBackingImage(presenting: true)
    }
    
    func animateBackingImageOut() {
        animateBackingImage(presenting: false)
    }
}

//Image Container animation.
extension MaxiSongCardViewController {
    
    private var startColor: UIColor {
        return UIColor.white.withAlphaComponent(0.3)
    }
    
    private var endColor: UIColor {
        return .white
    }
    
    //1.
    private var imageLayerInsetForOutPosition: CGFloat {
        let imageFrame = view.convert(originatingFrameInWindow, to: view)
        let inset = imageFrame.minY - backingImageEdgeInset
        return inset
    }
    
    //2.
    func configureImageLayerInStartPosition() {
        coverImageContainer.backgroundColor = startColor
        let startInset = imageLayerInsetForOutPosition
        dismissChevron.alpha = 0
        coverImageContainer.layer.cornerRadius = 0
        coverImageContainerTopInset.constant = startInset
        view.layoutIfNeeded()
    }
    
    //3.
    func animateImageLayerIn() {
        //4.
        UIView.animate(withDuration: primaryDuration / 4.0) {
            self.coverImageContainer.backgroundColor = self.endColor
        }
        
        //5.
        UIView.animate(withDuration: primaryDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
            self.coverImageContainerTopInset.constant = 0
            self.dismissChevron.alpha = 1
            self.coverImageContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
    
    //6.
    func animateImageLayerOut(completion: @escaping ((Bool) -> Void)) {
        let endInset = imageLayerInsetForOutPosition
        
        UIView.animate(withDuration: primaryDuration / 4.0,
                       delay: primaryDuration, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseOut], animations: {
                        self.coverImageContainer.backgroundColor = self.startColor
        }, completion: { finished in
            completion(finished) //fire complete here , because this is the end of the animation
        })
        
        UIView.animate(withDuration: primaryDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            self.coverImageContainerTopInset.constant = endInset
            self.dismissChevron.alpha = 0
            self.coverImageContainer.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
        })
    }
}

//cover image animation
extension MaxiSongCardViewController {
    //1.
    func configureCoverImageInStartPosition() {
        let originatingImageFrame = originatingCoverImageView.frame
        coverImageHeight.constant = originatingImageFrame.height
        coverImageLeading.constant = originatingImageFrame.minX
        coverImageTop.constant = originatingImageFrame.minY
        coverImageBottom.constant = originatingImageFrame.minY
    }
    
    //2.
    func animateCoverImageIn() {
        let coverImageEdgeContraint: CGFloat = 30
        let endHeight = coverImageContainer.bounds.width - coverImageEdgeContraint * 2
        UIView.animate(withDuration: primaryDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations:  {
            self.coverImageHeight.constant = endHeight
            self.coverImageLeading.constant = coverImageEdgeContraint
            self.coverImageTop.constant = coverImageEdgeContraint
            self.coverImageBottom.constant = coverImageEdgeContraint
            self.view.layoutIfNeeded()
        })
    }
    
    //3.
    func animateCoverImageOut() {
        UIView.animate(withDuration: primaryDuration,
                       delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseOut], animations:  {
                        self.configureCoverImageInStartPosition()
                        self.view.layoutIfNeeded()
        })
    }
}

//lower module animation
extension MaxiSongCardViewController {
    
    //1.
    private var lowerModuleInsetForOutPosition: CGFloat {
        let bounds = view.bounds
        let inset = bounds.height - bounds.width
        return inset
    }
    
    //2.
    func configureLowerModuleInStartPosition() {
        lowerModuleTopConstraint.constant = lowerModuleInsetForOutPosition
    }
    
    //3.
    func animateLowerModule(isPresenting: Bool) {
        let topInset = isPresenting ? 0 : lowerModuleInsetForOutPosition
        UIView.animate(withDuration: primaryDuration,
                       delay:0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: [.curveEaseIn],
                       animations: {
                        self.lowerModuleTopConstraint.constant = topInset
                        self.view.layoutIfNeeded()
        })
    }
    
    //4.
    func animateLowerModuleOut() {
        animateLowerModule(isPresenting: false)
    }
    
    //5.
    func animateLowerModuleIn() {
        animateLowerModule(isPresenting: true)
    }
}

//fake tab bar animation
extension MaxiSongCardViewController {
    //1.
    func configureBottomSection() {
        if let image = tabBarImage {
            bottomSectionHeight.constant = image.size.height
            bottomSectionImageView.image = image
        } else {
            bottomSectionHeight.constant = 0
        }
        view.layoutIfNeeded()
    }
    
    //2.
    func animateBottomSectionOut() {
        if let image = tabBarImage {
            UIView.animate(withDuration: primaryDuration / 2.0,
                           delay:0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.curveEaseIn],
                           animations: {
                self.bottomSectionLowerConstraint.constant = -image.size.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //3.
    func animateBottomSectionIn() {
        if tabBarImage != nil {
            UIView.animate(withDuration: primaryDuration / 2.0,
                           delay:0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                           options: [.curveEaseIn],
                           animations: {
                self.bottomSectionLowerConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
}




