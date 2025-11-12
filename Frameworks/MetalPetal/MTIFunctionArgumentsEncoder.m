//
//  MTIFunctionArgumentsEncoder.m
//  MetalPetal
//
//  Created by YuAo on 2020/7/11.
//

#import "MTIFunctionArgumentsEncoder.h"
#import "MTIDefer.h"
#import "MTIVector.h"
#import "MTIError.h"
#import "MTIBuffer.h"
#import <TargetConditionals.h>

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
#define MTI_HAS_METAL_BINDING_REFLECTION 1
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 130000
#define MTI_HAS_METAL_BINDING_REFLECTION 1
#elif defined(__TV_OS_VERSION_MAX_ALLOWED) && __TV_OS_VERSION_MAX_ALLOWED >= 160000
#define MTI_HAS_METAL_BINDING_REFLECTION 1
#else
#define MTI_HAS_METAL_BINDING_REFLECTION 0
#endif

static const NSUInteger MTILegacyArgumentTypeBuffer = 0;
static const MTLDataType MTIArgumentDataTypeInvalid = (MTLDataType)NSIntegerMax;

@protocol MTLLegacyArgument <NSObject>
@property (readonly) NSString *name;
@property (readonly) NSUInteger index;
@property (readonly, getter=isActive) BOOL active;
@property (readonly) NSUInteger type;
@property (readonly) NSUInteger bufferDataSize;
@property (readonly) NSUInteger bufferDataType;
@end

static Class MTILegacyArgumentClass(void) {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = NSClassFromString(@"MTLArgument");
    });
    return cls;
}

static BOOL MTIArgumentIsLegacyArgument(id argument) {
    Class legacyClass = MTILegacyArgumentClass();
    return legacyClass && [argument isKindOfClass:legacyClass];
}

static NSString * MTIArgumentGetName(id argument) {
#if MTI_HAS_METAL_BINDING_REFLECTION
    if (@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)) {
        if ([argument conformsToProtocol:@protocol(MTLBinding)]) {
            return [(id<MTLBinding>)argument name];
        }
    }
#endif
    if (MTIArgumentIsLegacyArgument(argument)) {
        return [(id<MTLLegacyArgument>)argument name];
    }
    return nil;
}

static NSUInteger MTIArgumentGetIndex(id argument) {
#if MTI_HAS_METAL_BINDING_REFLECTION
    if (@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)) {
        if ([argument conformsToProtocol:@protocol(MTLBinding)]) {
            return [(id<MTLBinding>)argument index];
        }
    }
#endif
    if (MTIArgumentIsLegacyArgument(argument)) {
        return [(id<MTLLegacyArgument>)argument index];
    }
    return NSNotFound;
}

static BOOL MTIArgumentIsBuffer(id argument) {
#if MTI_HAS_METAL_BINDING_REFLECTION
    if (@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)) {
        if ([argument conformsToProtocol:@protocol(MTLBinding)]) {
            return [(id<MTLBinding>)argument type] == MTLBindingTypeBuffer;
        }
    }
#endif
    if (MTIArgumentIsLegacyArgument(argument)) {
        return [(id<MTLLegacyArgument>)argument type] == MTILegacyArgumentTypeBuffer;
    }
    return NO;
}

static NSUInteger MTIArgumentGetBufferDataSize(id argument) {
#if MTI_HAS_METAL_BINDING_REFLECTION
    if (@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)) {
        if ([argument conformsToProtocol:@protocol(MTLBufferBinding)]) {
            return [(id<MTLBufferBinding>)argument bufferDataSize];
        }
    }
#endif
    if (MTIArgumentIsLegacyArgument(argument)) {
        return [(id<MTLLegacyArgument>)argument bufferDataSize];
    }
    return 0;
}

static MTLDataType MTIArgumentGetBufferDataType(id argument) {
#if MTI_HAS_METAL_BINDING_REFLECTION
    if (@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)) {
        if ([argument conformsToProtocol:@protocol(MTLBufferBinding)]) {
            return [(id<MTLBufferBinding>)argument bufferDataType];
        }
    }
#endif
    if (MTIArgumentIsLegacyArgument(argument)) {
        return (MTLDataType)[(id<MTLLegacyArgument>)argument bufferDataType];
    }
    return MTIArgumentDataTypeInvalid;
}

static inline void MTIArgumentsEncoderEncodeBytes(MTLFunctionType functionType, id<MTLCommandEncoder> encoder, const void * bytes, NSUInteger length, NSUInteger index) {
    switch (functionType) {
        case MTLFunctionTypeFragment:
            [(id<MTLRenderCommandEncoder>)encoder setFragmentBytes:bytes length:length atIndex:index];
            break;
        case MTLFunctionTypeVertex:
            [(id<MTLRenderCommandEncoder>)encoder setVertexBytes:bytes length:length atIndex:index];
            break;
        case MTLFunctionTypeKernel:
            if ([encoder conformsToProtocol:@protocol(MTLComputeCommandEncoder)]) {
                [(id<MTLComputeCommandEncoder>)encoder setBytes:bytes length:length atIndex:index];
            } else if ([encoder conformsToProtocol:@protocol(MTLRenderCommandEncoder)]) {
                #if TARGET_OS_IPHONE && !TARGET_OS_MACCATALYST && !TARGET_OS_TV
                [(id<MTLRenderCommandEncoder>)encoder setTileBytes:bytes length:length atIndex:index];
                #endif
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unsupported command encoder." userInfo:nil];
            }
            break;
        default:
            break;
    }
}

static inline void MTIArgumentsEncoderEncodeBuffer(MTLFunctionType functionType, id<MTLCommandEncoder> encoder, id<MTLBuffer> buffer, NSUInteger index) {
    switch (functionType) {
        case MTLFunctionTypeFragment:
            [(id<MTLRenderCommandEncoder>)encoder setFragmentBuffer:buffer offset:0 atIndex:index];
            break;
        case MTLFunctionTypeVertex:
            [(id<MTLRenderCommandEncoder>)encoder setVertexBuffer:buffer offset:0 atIndex:index];
            break;
        case MTLFunctionTypeKernel:
            if ([encoder conformsToProtocol:@protocol(MTLComputeCommandEncoder)]) {
                [(id<MTLComputeCommandEncoder>)encoder setBuffer:buffer offset:0 atIndex:index];
            } else if ([encoder conformsToProtocol:@protocol(MTLRenderCommandEncoder)]) {
                #if TARGET_OS_IPHONE && !TARGET_OS_MACCATALYST && !TARGET_OS_TV
                [(id<MTLRenderCommandEncoder>)encoder setTileBuffer:buffer offset:0 atIndex:index];
                #endif
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unsupported command encoder." userInfo:nil];
            }
            break;
        default:
            break;
    }
}

__attribute__((objc_subclassing_restricted))
@interface MTIFunctionArgumentEncodingProxyImplementation: NSObject <MTIFunctionArgumentEncodingProxy>

@property (nonatomic) BOOL used;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong, readonly) id<MTLCommandEncoder> encoder;
@property (nonatomic, strong, readonly) id argument;
@property (nonatomic, readonly) MTLFunctionType functionType;

@end

@implementation MTIFunctionArgumentEncodingProxyImplementation

- (instancetype)initWithEncoder:(id<MTLCommandEncoder>)encoder functionType:(MTLFunctionType)functionType argument:(id)argument {
    if (self = [super init]) {
        _encoder = encoder;
        _functionType = functionType;
        _argument = argument;
        _used = NO;
        _error = nil;
    }
    return self;
}

- (void)encodeBytes:(const void *)bytes length:(NSUInteger)length {
    NSAssert(_encoder != nil, @"An encoding proxy can only encode/reportError once.");
    if (_encoder) {
        NSUInteger expectedSize = MTIArgumentGetBufferDataSize(_argument);
        NSUInteger index = MTIArgumentGetIndex(_argument);
        if (expectedSize == 0 || index == NSNotFound) {
            _error = MTIErrorCreate(MTIErrorUnsupportedParameterType, (@{@"Argument": _argument}));
            _used = YES;
        } else if (length != expectedSize) {
            _error = MTIErrorCreate(MTIErrorParameterDataSizeMismatch, (@{@"Argument": _argument}));
            _used = YES;
        } else {
            MTIArgumentsEncoderEncodeBytes(_functionType, _encoder, bytes, length, index);
            _used = YES;
        }
        _encoder = nil;
        _argument = nil;
    }
}

- (void)invalidate {
    _encoder = nil;
    _argument = nil;
}

@end

@implementation MTIFunctionArgumentsEncoder

+ (BOOL)encodeArguments:(NSArray *)arguments values:(NSDictionary<NSString *,id> *)parameters functionType:(MTLFunctionType)functionType encoder:(id<MTLCommandEncoder>)encoder error:(NSError * __autoreleasing *)inOutError {
    
    for (id argument in arguments) {
        if (!MTIArgumentIsBuffer(argument)) {
            continue;
        }
        NSString *argumentName = MTIArgumentGetName(argument);
        if (argumentName.length == 0) {
            continue;
        }
        id value = parameters[argumentName];
        if (!value) {
            continue;
        }
        
        NSUInteger index = MTIArgumentGetIndex(argument);
        NSUInteger dataSize = MTIArgumentGetBufferDataSize(argument);
        MTLDataType dataType = MTIArgumentGetBufferDataType(argument);
        
        if (index == NSNotFound || dataSize == 0 || dataType == MTIArgumentDataTypeInvalid) {
            if (inOutError != nil) {
                *inOutError = MTIErrorCreate(MTIErrorUnsupportedParameterType, (@{@"Argument": argument, @"Value": value ?: [NSNull null]}));
            }
            return NO;
        }
        
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *number = value;
            switch (dataType) {
                case MTLDataTypeBool: {
                    bool b = (bool)number.boolValue;
                    NSAssert(sizeof(b) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &b, sizeof(b), index);
                } break;
                case MTLDataTypeInt: {
                    int i = number.intValue;
                    NSAssert(sizeof(i) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &i, sizeof(i), index);
                } break;
                case MTLDataTypeUInt: {
                    unsigned int i = number.unsignedIntValue;
                    NSAssert(sizeof(i) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &i, sizeof(i), index);
                } break;
                case MTLDataTypeChar: {
                    char c = number.charValue;
                    NSAssert(sizeof(c) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &c, sizeof(c), index);
                } break;
                case MTLDataTypeUChar: {
                    unsigned char c = number.unsignedCharValue;
                    NSAssert(sizeof(c) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &c, sizeof(c), index);
                } break;
                case MTLDataTypeShort: {
                    short s = number.shortValue;
                    NSAssert(sizeof(s) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &s, sizeof(s), index);
                } break;
                case MTLDataTypeUShort: {
                    unsigned short s = number.unsignedShortValue;
                    NSAssert(sizeof(s) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &s, sizeof(s), index);
                } break;
                case MTLDataTypeFloat: {
                    float f = number.floatValue;
                    NSAssert(sizeof(f) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &f, sizeof(f), index);
                } break;
                case MTLDataTypeHalf: {
                    float f = number.floatValue;
                    __fp16 h = f;
                    NSAssert(sizeof(h) == dataSize, @"");
                    MTIArgumentsEncoderEncodeBytes(functionType, encoder, &h, sizeof(h), index);
                } break;
                default: {
                    if (inOutError != nil) {
                        *inOutError = MTIErrorCreate(MTIErrorParameterDataTypeMismatch, (@{@"Argument": argument, @"Value": value}));
                    }
                    return NO;
                } break;
            }
        } else if ([value isKindOfClass:[NSValue class]]) {
            NSValue *nsValue = (NSValue *)value;
            NSUInteger size;
            NSGetSizeAndAlignment(nsValue.objCType, &size, NULL);
            void *valuePtr = malloc(size);
            [nsValue getValue:valuePtr];
            @MTI_DEFER {
                free(valuePtr);
            };
            if (dataSize != size) {
                if (inOutError != nil) {
                    *inOutError = MTIErrorCreate(MTIErrorParameterDataSizeMismatch, (@{@"Argument": argument, @"Value": value}));
                }
                return NO;
            }
            MTIArgumentsEncoderEncodeBytes(functionType, encoder, valuePtr, size, index);
        } else if ([value isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)value;
            MTIArgumentsEncoderEncodeBytes(functionType, encoder, data.bytes, data.length, index);
        } else if ([value isKindOfClass:[MTIVector class]]) {
            MTIVector *vector = (MTIVector *)value;
            MTIArgumentsEncoderEncodeBytes(functionType, encoder, vector.bytes, vector.byteLength, index);
        } else if ([value isKindOfClass:[MTIDataBuffer class]]) {
            MTIDataBuffer *dataBuffer = (MTIDataBuffer *)value;
            id<MTLBuffer> buffer = [dataBuffer bufferForDevice:encoder.device];
            MTIArgumentsEncoderEncodeBuffer(functionType, encoder, buffer, index);
        } else {
            static Class<MTIFunctionArgumentEncoding> SIMDValueEncoder;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                Class encoder = NSClassFromString(@"MTISIMDArgumentEncoder");
                if ([encoder conformsToProtocol:@protocol(MTIFunctionArgumentEncoding)]) {
                    SIMDValueEncoder = encoder;
                }
            });
            if (SIMDValueEncoder) {
                MTIFunctionArgumentEncodingProxyImplementation *proxy = [[MTIFunctionArgumentEncodingProxyImplementation alloc] initWithEncoder:encoder functionType:functionType argument:argument];
                NSError *encoderError;
                [SIMDValueEncoder encodeValue:value argument:argument proxy:proxy error:&encoderError];
                NSError *error = encoderError ?: proxy.error;
                if (error) {
                    if (inOutError != nil) {
                        *inOutError = error;
                    }
                    return NO;
                }
                if (!proxy.used) {
                    [proxy invalidate];
                    if (inOutError != nil) {
                        *inOutError = MTIErrorCreate(MTIErrorUnsupportedParameterType, (@{@"Argument": argument, @"Value": value}));
                    }
                    return NO;
                }
            } else {
                if (inOutError != nil) {
                    *inOutError = MTIErrorCreate(MTIErrorUnsupportedParameterType, (@{@"Argument": argument, @"Value": value}));
                }
                return NO;
            }
        }
    }
    
    return YES;
}
@end
