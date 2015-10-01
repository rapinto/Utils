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
    lResult = [lResult stringByRemovingPercentEncoding];
    return lResult;
}



#pragma mark -
#pragma mark String Validating Methods


+ (void)testEmailValidation
{
    NSLog(@"Validate %@ (VALID): %i", @"david.jones@proseware.com", [Utils validateEmail:@"david.jones@proseware.com"]);
    NSLog(@"Validate %@ (VALID): %i", @"d.j@server1.proseware.com", [Utils validateEmail:@"d.j@server1.proseware.com"]);
    NSLog(@"Validate %@ (VALID): %i", @"jones@ms1.proseware.com", [Utils validateEmail:@"jones@ms1.proseware.com"]);
    NSLog(@"Validate %@ (VALID): %i", @"j@proseware.com9", [Utils validateEmail:@"j@proseware.com9"]);
    NSLog(@"Validate %@ (VALID): %i", @"js#internal@proseware.com", [Utils validateEmail:@"js#internal@proseware.com"]);
    NSLog(@"Validate %@ (VALID): %i", @"j_9@[129.126.118.1]", [Utils validateEmail:@"j_9@[129.126.118.1]"]);
    NSLog(@"Validate %@ (VALID): %i", @"js@proseware.com9", [Utils validateEmail:@"js@proseware.com9"]);
    NSLog(@"Validate %@ (VALID): %i", @"j.s@server1.proseware.com", [Utils validateEmail:@"j.s@server1.proseware.com"]);
    NSLog(@"Validate %@ (VALID): %i", @"js@contoso.ä¸­å›½", [Utils validateEmail:@"js@contoso.ä¸­å›½"]);
    NSLog(@"Validate %@ (VALID): %i", @"\"j\\\"s\\\"\"@proseware.com", [Utils validateEmail:@"\"j\\\"s\\\"\"@proseware.com"]);
    NSLog(@"Validate %@ (INVALID): %i", @"js@proseware..com", [Utils validateEmail:@"js@proseware..com"]);
    NSLog(@"Validate %@ (INVALID): %i", @"js*@proseware.com", [Utils validateEmail:@"js*@proseware.com"]);
    NSLog(@"Validate %@ (INVALID): %i", @"j..s@proseware.com", [Utils validateEmail:@"j..s@proseware.com"]);
    NSLog(@"Validate %@ (INVALID): %i", @"j.@server1.proseware.com", [Utils validateEmail:@"j.@server1.proseware.com"]);
}


+ (BOOL)validateEmail:(NSString*)_Email
{
    // First, we check that there's one @ symbol,
    // and that the lengths are right.
    NSString* lEmailRegex =  @"^[^@]{1,64}@[^@]{1,255}$";
    NSPredicate* lEmailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", lEmailRegex];
    
    if (![lEmailTest evaluateWithObject:_Email])
    {
        return NO;
    }
    
    
    // Split it into sections to make life easier
    NSArray* lSplitedEmail = [_Email componentsSeparatedByString:@"@"];
    if ([lSplitedEmail count] > 1)
    {
        NSArray* lSplitedLocalEmail = [[lSplitedEmail objectAtIndex:0] componentsSeparatedByString:@"."];
        NSString* lLocalRegex =  @"^(([A-Za-z0-9!#$%&'*+/=?^_`{|}~-][A-Za-z0-9!#$%&↪'*+/=?^_`{|}~.-]{0,63})|(\"[^(\\|\")]{0,62}\"))$";
        NSPredicate* lLocalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", lLocalRegex];
        for (NSString* aString in lSplitedLocalEmail)
        {
            if (![lLocalTest evaluateWithObject:aString])
            {
                return NO;
            }
        }
        
        // Check if domain is IP. If not,
        // it should be valid domain name
        NSString* lDomainRegex =  @"^[?[0-9.]+]?$";
        NSPredicate* lDomainTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", lDomainRegex];
        
        if (![lDomainTest evaluateWithObject:[lSplitedEmail objectAtIndex:1]])
        {
            NSArray* lSplitedDomain = [[lSplitedEmail objectAtIndex:1] componentsSeparatedByString:@"."];
            
            if ([lSplitedDomain count] < 2)
            {
                return NO;
            }
            
            
            for (int i = 0; i < [lSplitedDomain count]; i++)
            {
                NSString* lEvaluatedStr = [lSplitedDomain objectAtIndex:i];
                
                if (i == 0 && [[lEvaluatedStr substringToIndex:1] isEqualToString:@"["])
                {
                    lEvaluatedStr = [lEvaluatedStr substringFromIndex:1];
                }
                
                if (i == [lSplitedDomain count] - 1 && [lEvaluatedStr length] > 0 && [[lEvaluatedStr substringFromIndex:[lEvaluatedStr length] - 1] isEqualToString:@"]"])
                {
                    lEvaluatedStr = [lEvaluatedStr substringToIndex:[lEvaluatedStr length] - 1];
                }
                
                NSString* lDomainIPRegexSTR =  @"^(([A-Za-z0-9]{0,61}[A-Za-z0-9])|↪([A-Za-z0-9]+))$";
                NSPredicate* lDomainIPRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", lDomainIPRegexSTR];
                
                if (![lDomainIPRegex evaluateWithObject:lEvaluatedStr])
                {
                    return NO;
                }
            }
        }
    }
    else
    {
        return NO;
    }
    
    return YES;
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
