//
//  Extensions.swift
//  Project2
//
//  Created by virdeshp on 1/4/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import UIKit


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(imageurlstring: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: imageurlstring as NSString) as?
            UIImage {
            self.image = cachedImage
            //print ("cached image")
            return
        }
        let url = URL(string: imageurlstring)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        
            if error != nil {
                print(error)
                return
            }
        
            DispatchQueue.main.async {
                            
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: imageurlstring as NSString)
                    print("downloaded image")
                    self.image = downloadedImage
                }
                            
            }
        
        }).resume()
    }
    
}


func timeDisplayFormat (totalSeconds: Int) -> String {
    
    var finalString = ""
    
    let seconds: String = String(format: "%02d", Int(totalSeconds) % 60)
    let minutes: String = String(format: "%02d", Int(totalSeconds)/60)
    finalString = "\(minutes):\(seconds)"
    
    return finalString
    
}



extension UserDefaults {
    
    func setisLoggedIn(value: Bool) {
        set(value, forKey:"isLoggedIn")
        synchronize()
    }
    
    func getisLoggedIn() -> Bool {
        return self.bool(forKey:"isLoggedIn")
       
    }
    
}


extension UILabel {

    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText

        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }

    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
    
    
    //
    //  InteractiveLinkLabel.swift
    //  ClickableLabel
    //
    //  Created by Steven Curtis on 31/10/2019.
    //  Copyright © 2019 Steven Curtis. All rights reserved.
    //

    
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
         print("Point override")
        
         let superBool = super.point(inside: point, with: event)
         
         // Configure NSTextContainer
         let textContainer = NSTextContainer(size: bounds.size)
         textContainer.lineFragmentPadding = 0.0
         textContainer.lineBreakMode = lineBreakMode
         textContainer.maximumNumberOfLines = numberOfLines
         
         // Configure NSLayoutManager and add the text container
         let layoutManager = NSLayoutManager()
         layoutManager.addTextContainer(textContainer)
         
         guard let attributedText = attributedText else {return false}
         
         // Configure NSTextStorage and apply the layout manager
         let textStorage = NSTextStorage(attributedString: attributedText)
         textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, attributedText.length))
         textStorage.addLayoutManager(layoutManager)
         
         // get the tapped character location
         let locationOfTouchInLabel = point
         
         // account for text alignment and insets
         let textBoundingBox = layoutManager.usedRect(for: textContainer)
         var alignmentOffset: CGFloat!
         switch textAlignment {
         case .left, .natural, .justified:
             alignmentOffset = 0.0
         case .center:
             alignmentOffset = 0.5
         case .right:
             alignmentOffset = 1.0
         @unknown default:
             fatalError()
         }
         
         let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
         let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
         let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)
         
         // work out which character was tapped
         let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
         
         // work out how many characters are in the string up to and including the line tapped, to ensure we are not off the end of the character string
         let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) - 1
         let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: font.lineHeight * CGFloat(lineTapped))
         let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
         
         guard characterIndex < charsInLineTapped else {return false}
         
         let attributeName = NSAttributedString.Key.font
         
        let attributeValue = self.attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil) as! UIFont
         
        if attributeValue == UIFont.systemFont(ofSize: 14, weight: .semibold) {
            print("Hit the URL string!!")
            //UIApplication.shared.open(url)
        } else {
            return false
        }
      
         
         return superBool
         
     }
}


