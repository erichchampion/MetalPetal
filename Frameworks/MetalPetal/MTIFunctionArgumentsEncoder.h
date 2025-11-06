//
//  MTIFunctionArgumentsEncoder.h
//  MetalPetal
//
//  Created by YuAo on 2020/7/11.
//

#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTIFunctionArgumentEncodingProxy <NSObject>

- (void)encodeBytes:(const void *)bytes length:(NSUInteger)length;

@end

@protocol MTIFunctionArgumentEncoding <NSObject>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (BOOL)encodeValue:(id)value argument:(MTLArgument *)argument proxy:(id<MTIFunctionArgumentEncodingProxy>)proxy error:(NSError **)error;
#pragma clang diagnostic pop

@end

__attribute__((objc_subclassing_restricted))
@interface MTIFunctionArgumentsEncoder : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (BOOL)encodeArguments:(NSArray<MTLArgument *>*)arguments
                 values:(NSDictionary<NSString *, id> *)parameters
           functionType:(MTLFunctionType)functionType
                encoder:(id<MTLCommandEncoder>)encoder
                  error:(NSError **)error;
#pragma clang diagnostic pop

@end


NS_ASSUME_NONNULL_END
