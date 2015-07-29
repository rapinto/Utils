//
//  Utils.m
//
//
//  Created by Raphaël Pinto on 19/08/2014.
//
// The MIT License (MIT)
// Copyright (c) 2015 Raphael Pinto.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



#import "Utils.h"



@implementation Utils



#pragma mark -
#pragma mark String encoding and conversion



+ (NSString*)AFEncodeBase64WithData:(NSData*)_Data
{
    NSUInteger length = [_Data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[_Data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}


+ (NSMutableAttributedString*)convertHTMLToNSAttributedString:(NSString*)_HTML
{
    if ([_HTML length] == 0)
    {
        return nil;
    }
    
    
    NSData* lData = [_HTML dataUsingEncoding:NSUTF32StringEncoding];
    NSDictionary* lDictionary = nil;
    NSError* lError = nil;
    
    
    NSMutableAttributedString* lDesc = [[NSMutableAttributedString alloc] initWithData:lData
                                                                               options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                    documentAttributes:&lDictionary
                                                                                 error:&lError];
    
    [lDesc enumerateAttributesInRange:NSMakeRange(0, [lDesc length])
                              options:NSAttributedStringEnumerationReverse
                           usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
     {
         UIFont* lFont = attrs[NSFontAttributeName];
         
         if (lFont.pointSize == 20.00)
         {
             [lDesc removeAttribute:NSFontAttributeName range:range];
         }
     }];
    
    return lDesc;
}


+ (NSString *)URLDecodeString:(NSString*)_EncodedString
{
    NSString* lResult = [_EncodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    lResult = [lResult stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return lResult;
}



#pragma mark -
#pragma mark Attributed String size calculator



+ (CGSize)sizeForString:(NSString*)_String
               withFont:(UIFont*)_Font
                maxSize:(CGSize)_MaxSize
{
    if ([_String length] == 0)
    {
        return CGSizeZero;
    }
    
    
    NSMutableAttributedString* lAttributedString = [[NSMutableAttributedString alloc] initWithString:_String];
    
    [lAttributedString addAttribute:NSFontAttributeName value:_Font range:NSMakeRange(0, [_String length])];
    
    CGRect paragraphRect = [lAttributedString boundingRectWithSize:_MaxSize
                                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           context:nil];
    return CGSizeMake(ceil(paragraphRect.size.width), ceil(paragraphRect.size.height));
}



#pragma mark -
#pragma mark Image Methods



+ (float)get_JPG_MO_WeightForImage:(UIImage*)_Image compression:(float)_JPGCompression
{
    NSData* lImageData = UIImageJPEGRepresentation(_Image, _JPGCompression);
    float lImageSize = lImageData.length;
    return lImageSize/(1024*1024);
}



@end
