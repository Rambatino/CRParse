//
//  CRPhotoService.m
//  Cloakroom
//
//  Created by Mark Ramotowski on 30/11/2014.
//  Copyright (c) 2014 Mark Ramotowski. All rights reserved.
//

#define thumbnailPixelWidth ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] \
&& ([UIScreen mainScreen].scale == 2.0)) ? 192 : 96

#define photoPixelWidth ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] \
&& ([UIScreen mainScreen].scale == 2.0)) ? 800 : 400

#define baseUrl @"https://upload.uploadcare.com/base/"

// Keys

//#define publicKey @"e84a031b3da1f560d56d"
//#define secretKey @"d928dabd866bf21302e9"

#define publicKey @"eac1dfa24386b9fe53dd"
#define secretKey @"4302aa056914cf99e5c5"

/*
 curl -F "UPLOADCARE_PUB_KEY=e84a031b3da1f560d56d" \
 -F "UPLOADCARE_STORE=1" \
 -F "file=@aaronmillman.jpg" https://upload.uploadcare.com/base/
 */

#import "CRPhotoService.h"

@implementation CRPhotoService

+ (void) savePhotoToObject:(NSManagedObject*) object withPhotoUrl:(NSString*) photoUrl withKey:(NSString*) key {
    
    if (photoUrl.length > 0 && (![photoUrl isEqualToString:[object valueForKey:@"photoUrl"]] || (![object valueForKey:@"photo"] && ![[object valueForKey:@"photoStatus"] isEqualToNumber:@404]))) {
        
        // check to see what class it is
        NSString *className = object.entity.name;
        
        if ([className isEqualToString:@"CRMember"]) {
            
            // save the photo to the object for a member
            photoUrl = [self returnPhotoUrlFromUploadcareUrl:[NSString stringWithFormat:@"%@-/resize/%i/", photoUrl,photoPixelWidth]];
            
        } else if ([className isEqualToString:@"CRVenue"]) {
            
            // save the photo to the object for a venue
            photoUrl = [self returnPhotoFromPhotoFilePath:photoUrl];
            
        }
                
        NSDictionary *photoInformation = [self returnPhotoFromPhotoUrl:photoUrl];
        
        // if the photo exists, set it
        if (photoInformation[@"photo"]) {
        
            [object setValue:photoInformation[@"photo"] forKey:key];
            
        }
        
        if (photoInformation[@"status"]) {
            
            [object setValue:photoInformation[@"status"] forKey:@"photoStatus"];
            
        }
        
    }
}

+ (NSString*) returnPhotoFromPhotoFilePath:(NSString*) photoUrl {
    NSRegularExpression *myRegEx = [[NSRegularExpression alloc]initWithPattern:@"/[a-zA-Z_0-9]+.[jpg]+" options:0 error:nil];
    NSRange rangeOfTheString = [myRegEx rangeOfFirstMatchInString:photoUrl options:0 range:NSMakeRange(0, photoUrl.length)];

    return [@"http://www.doublemg.com/cloakroom/facebook/1200" stringByAppendingString:[photoUrl substringWithRange:rangeOfTheString]];
}

+ (NSDictionary*) returnPhotoFromPhotoUrl:(NSString*) photoUrl {

    NSMutableDictionary *dictionary = @{}.mutableCopy;
    
    NSURLResponse *response = [[NSURLResponse alloc]init];
    NSData *data =  [NSURLConnection sendSynchronousRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:photoUrl]]  returningResponse:&response error:nil];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    dictionary[@"status"] = @([httpResponse statusCode]);
    if (data) {
        dictionary[@"photo"] = data;
    }

    return dictionary;
    
}

+ (UIImage*) imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(newSize.width > image.size.width ? image.size.width : newSize.width , newSize.height  > image.size.height ? image.size.height : newSize.height));
    
    [image drawInRect:CGRectMake(0,0,newSize.width > image.size.width ? image.size.width : newSize.width ,newSize.height > image.size.height ? image.size.height : newSize.height )];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

+ (NSString*) returnPhotoUrlFromUploadcareUrl:(NSString*) currentPhotoUrl {
    
    NSRegularExpression *myRegEx = [[NSRegularExpression alloc]initWithPattern:@"-/resize/[0-9]+x[0-9]+/" options:0 error:nil];
    NSRange rangeOfTheString = [myRegEx rangeOfFirstMatchInString:currentPhotoUrl options:0 range:NSMakeRange(0, currentPhotoUrl.length)];
    NSMutableString *finalString = currentPhotoUrl.mutableCopy;
    if (currentPhotoUrl.length > rangeOfTheString.location) {
        [finalString replaceCharactersInRange:rangeOfTheString withString:@""];
    }
    return finalString;
    
}

+ (void) storeImage:(UIImage*) image completion:(void (^) (NSError *error, NSDictionary *imageName)) completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.uploadcare.com/base/"]];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"unique-consistent-string";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"UPLOADCARE_PUB_KEY"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", publicKey] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"UPLOADCARE_STORE"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"0"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=file; filename=photo.jpg\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSMutableDictionary *imageFileName = @{}.mutableCopy;
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                               if (data.length > 0 && [httpResponse statusCode] == 200) {
                                   // {"file": "08b215d8-ad0b-4eb8-be68-d553ce0127d1"}
                                   imageFileName[@"photoUrl"] = [[@"http://www.ucarecdn.com/" stringByAppendingString:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil][@"file"]] stringByAppendingString:@"/"];
                                   
                                   imageFileName[@"uuid"] = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil][@"file"];
                                   
                                   
                               }
                               //                               {"cdnUrl":"http://www.ucarecdn.com/dfc4f9fc-57fa-4ae0-a3c7-dd0ca7841be6/-/crop/812x812/278,432/-/resize/200x200/","cdnUrlModifiers":"-/crop/812x812/278,432/-/resize/200x200/","crop":{"height":812,"left":278,"sh":200,"sw":200,"top":432,"width":812},"isImage":true,"isStored":false,"name":"eriple-photo-side-instagrammed.jpg","originalImageInfo":{"datetime_original":null,"format":"JPEG","geo_location":null,"height":1860,"width":1728},"originalUrl":"http://www.ucarecdn.com/dfc4f9fc-57fa-4ae0-a3c7-dd0ca7841be6/","size":401170,"uuid":"dfc4f9fc-57fa-4ae0-a3c7-dd0ca7841be6"}
                               
                               //                               NSData *data = [NSJSONSerialization dataWithJSONObject:
                               //                                               @{@"facebook" : @{@"id" : DEFAULT_VALUE(facebookId),
                               //                                                                 @"access_token" : DEFAULT_VALUE(accessToken),
                               //                                                                 @"expiration_date" : DEFAULT_VALUE([df stringFromDate:expirationDate])}}
                               //                                                                              options:NSJSONWritingPrettyPrinted error:&error];
                               //
                               //                               // convert the data to json
                               //                               ParseUser *currentUser = [ParseUser currentUser];
                               //                               currentUser[@"authData"] = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                               //                               error = [NSError errorWithDomain:NSOSStatusErrorDomain code:1 userInfo:@{@"result":@"failed to upload"}];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (completion) {
                                       completion(error,imageFileName);
                                   }
                               });
                           }];
}

+ (void) deletePhotoForUserWithFileName:(NSString*) fileName completion:(void (^) (NSError *error, NSData *photo)) completion {
    if(fileName) {
        fileName = [self returnPhotoUrlFromUploadcareUrl:fileName];
        NSMutableString *string = [[NSMutableString alloc] initWithString:fileName];
        [string replaceOccurrencesOfString:@"www" withString:@"api" options:NSCaseInsensitiveSearch range:NSMakeRange(0, fileName.length)];
        [string replaceOccurrencesOfString:@"ucarecdn.com/" withString:@"uploadcare.com/files/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, fileName.length)];
        [string replaceOccurrencesOfString:@"http://" withString:@"https://" options:NSCaseInsensitiveSearch range:NSMakeRange(0, fileName.length)];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
        [request setHTTPMethod:@"DELETE"];
        [request addValue:@"Uploadcare.Simple e84a031b3da1f560d56d:d928dabd866bf21302e9" forHTTPHeaderField:@"Authorization"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if ([(NSHTTPURLResponse*) response statusCode] == 404) {
            
                data = nil;
            
            }
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Sort the image view out
                   
                    SAFE_FUNCTION(completion,connectionError,data);
                    
                });

        }];
    }
}

@end
