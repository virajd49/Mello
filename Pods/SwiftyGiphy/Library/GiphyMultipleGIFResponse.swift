//
//  GiphyAPIResponse.swift
//  SwiftyGiphy
//
//  Created by Brendan Lee on 3/9/17.
//  Copyright © 2017 52inc. All rights reserved.
//

import Foundation
import ObjectMapper

public struct GiphyMultipleGIFResponse: Mappable {
    
    public fileprivate(set) var gifs: [GiphyItem] = [GiphyItem]()
    
    public fileprivate(set) var pagination: GiphyPagination?
    
    public fileprivate(set) var meta: GiphyMeta?
    
    public init?(map: Map)
    {
        
    }
    
    public init() {}
    
    mutating public func mapping(map: Map) {
        
        gifs        <- map["data"]
        pagination  <- map["pagination"]
        meta        <- map["meta"]
    }
    
    public func gifsSmallerThan(sizeInBytes: Int, forWidth: CGFloat) -> [GiphyItem]
    {
        return gifs.filter({
            let size = $0.imageSetClosestTo(width: forWidth, animated: true)?.size ?? 0
            
            guard size > 0 else {
                return false
            }
            
            return size <= sizeInBytes
        })
    }
}
