//
//  CDVAlipay.m
//  X5
//
//  Created by 007slm on 12/8/14.
//
//

#import "CDVAlipay.h"
#import "AlipayOrder.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation CDVAlipay
-(void)handleOpenURL:(NSNotification *)notification{
    NSURL* url = [notification object];
    //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if (url!=nil && [url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService]
         processOrderWithPaymentResult:url
         standbyCallback:^(NSDictionary *resultDic) {
             NSLog(@"result = %@", resultDic);
             CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]]];
             [self.commandDelegate sendPluginResult:result callbackId:self.currentCallbackId];
             [self endForExec];
         }];
    }
}


-(void)pluginInitialize{
    CDVViewController *viewController = (CDVViewController *)self.viewController;
    self.partner = [viewController.settings objectForKey:@"partner"];
    self.rsa_private = [viewController.settings objectForKey:@"rsa_private"];
    self.rsa_public = [viewController.settings objectForKey:@"rsa_public"];
}


-(void) prepareForExec:(CDVInvokedUrlCommand *)command{
    self.currentCallbackId = command.callbackId;
    
}

-(NSDictionary *)checkArgs:(CDVInvokedUrlCommand *) command{
    // check arguments
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数错误"] callbackId:command.callbackId];
        
        [self endForExec];
        return nil;
    }
    return params;
}

-(void) endForExec{
    self.currentCallbackId = nil;
}



- (NSString*)urlEncodedString:(NSString *)string {
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
}

- (void)pay:(CDVInvokedUrlCommand*)command{
    [self prepareForExec:command];
    NSString *orderInfo = [command.arguments objectAtIndex:0];
    NSString *sign = [command.arguments objectAtIndex:1];
    NSDictionary *alipaySetting = [command.arguments objectAtIndex:2];
    self.partner = alipaySetting[@"partner"];
    self.rsa_public = alipaySetting[@"rsa_public"];
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = [self partner];
    
    //encode signs
    NSString *signedString = [ self urlEncodedString:sign];

    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderInfo, signedString, @"RSA"];
        NSLog(@"orderString = %@",orderString);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]]];
            [self.commandDelegate sendPluginResult:result callbackId:self.currentCallbackId];
            [self endForExec];
        }];
    }
}



@end
