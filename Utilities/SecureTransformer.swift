//
//  SecureTransformer.swift
//  NeckSus13
//
//  Created by Khalid Mukhtar on 06/03/2025.
//
// SecureTransformer.swift
import Foundation

@objc(SecureTransformer)
final class SecureTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName("SecureTransformer")
    
    // SecureTransformer.swift
    override class var allowedTopLevelClasses: [AnyClass] {
        return [
            NSArray.self,    // ✅ Critical for arrays (locations/radiation/reliefs)
            NSString.self,
            NSNumber.self,
            NSDate.self,
            NSSet.self,
            NeckSus13.NumbnessEntry.self,
            NeckSus13.PainPoint.self
        ]
    }
}
