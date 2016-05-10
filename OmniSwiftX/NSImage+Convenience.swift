//
//  NSImage+Convenience.swift
//  OmniSwiftX
//
//  Created by Cooper Knaak on 5/5/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

extension NSImage {
    
    public class func imageWithPDFURL(pdfURL:NSURL, size:NSSize) -> NSImage? {
        let pdfDoc = CGPDFDocumentCreateWithURL(pdfURL)
        let pdfPage = CGPDFDocumentGetPage(pdfDoc, 1)
        let pageFrame = CGPDFPageGetBoxRect(pdfPage, CGPDFBox.CropBox)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let retina              = GLSFrameBuffer.getRetinaScale()
        let width               = Int(size.width * retina)
        let height              = Int(size.height * retina)
        let bytesPerPixel       = 4
        let bitsPerComponent    = 8
        let bytesPerRow         = bytesPerPixel * width
        let bitmapInfo          = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextSaveGState(context)
        
        CGContextScaleCTM(context, retina * size.width / pageFrame.size.width, retina * size.height / pageFrame.size.height)
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pdfPage, CGPDFBox.CropBox, pageFrame, 0, true))
        
        CGContextDrawPDFPage(context, pdfPage)
        
        let image = CGBitmapContextCreateImage(context)
        
        CGContextRestoreGState(context)
        
        guard let cgImage = image else {
            return nil
        }
        
        return NSImage(CGImage: cgImage, size: size)
    }
    
    public class func imageWithPDFFile(pdfFile:String, size:NSSize) -> NSImage? {
        let pdfDoc = CGPDFDocumentCreateWithURL(NSURL(fileURLWithPath: pdfFile))
        let pdfPage = CGPDFDocumentGetPage(pdfDoc, 1)
        let pageFrame = CGPDFPageGetBoxRect(pdfPage, CGPDFBox.CropBox)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let retina              = GLSFrameBuffer.getRetinaScale()
        let width               = Int(size.width * retina)
        let height              = Int(size.height * retina)
        let bytesPerPixel       = 4
        let bitsPerComponent    = 8
        let bytesPerRow         = bytesPerPixel * width
        let bitmapInfo          = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextSaveGState(context)
        
        CGContextScaleCTM(context, retina * size.width / pageFrame.size.width, retina * size.height / pageFrame.size.height)
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pdfPage, CGPDFBox.CropBox, pageFrame, 0, true))
        
        CGContextDrawPDFPage(context, pdfPage)
        
        let image = CGBitmapContextCreateImage(context)
        
        CGContextRestoreGState(context)
        
        guard let cgImage = image else {
            return nil
        }
        
        return NSImage(CGImage: cgImage, size: size)
    }
    
}