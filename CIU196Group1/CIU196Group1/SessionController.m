//
//  SessionController.m
//  CIU196Group1
//
//  Created by Robert Sebescen on 2013-11-29.
//  Copyright (c) 2013 Eric Zhang, Robert Sebescen. All rights reserved.
//

#import "SessionController.h"
#import "Game.h"
#import "Utilities.h"

@implementation SessionController

static NSString * ip = @"http://95.80.44.85/";


- (id) init {
    self = [super init];
    
    if (self) {

    }
    return self;
}

// Gets a new session ID from the server. if the server responds with an error, the error message is printed and -1 is returned.
- (NSInteger) getNewSessionID {
//    [self getPlayerData:1];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@", ip, @"?action=newsession"]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                              encoding:NSUTF8StringEncoding];
    
    @try {
        //NSLog(@"Server returned ok: %d",  [responseStr integerValue]);
        return [responseStr integerValue];
    }
    @catch (NSException *e) {
        NSLog(@"Server returned exception: %@", responseStr);
        return -1;
    }
}

// Adds a player to an existing session. The method will connect to the server and retrieve an available player ID for that session. If the server responded with an error, the error message is printed and -1 is returned.
// TODO: make server check if sessionID exists
- (NSInteger) addPlayerToSession : (NSInteger) sessionID{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?action=addplayer&sessionid=%lu&name=%@", ip, (long)sessionID, [[[[Game sharedGame] myself] name] stringByReplacingOccurrencesOfString:@" " withString:@"+"]]]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    @try {
        NSInteger returnVal =  [responseStr integerValue];
        [[Game sharedGame] setSessionID:sessionID];
        [[[Game sharedGame] myself] setInGameID:returnVal];
        [self uploadPlayerImage];
        return returnVal;
    }
    @catch (NSException *e) {
        NSLog(@"Server returned exception: %@", responseStr);
        return -1;
    }
}

// Retrieves the number of players in the session with the given sessionID. If the server responded with an error, the error message is printed and -1 is returned.
- (NSInteger) getNumberOfPlayersInSession {
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%d", ip, @"?action=getnumberofplayers&sessionid=", [[Game sharedGame] sessionID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    @try {
        //NSLog(@"Server returned ok: %d",  [responseStr integerValue]);
        return [responseStr integerValue];
    }
    @catch (NSException *e) {
        NSLog(@"Server returned exception: %@", responseStr);
        return -1;
    }
}

// queries the server for player data given a sessionID. returns an NSArray of NSDictionaries, to be
// parsed by Player.parseFromJSON
Player* player;

- (NSMutableArray *) getPlayerData {
    
    /* something is broken with this
    __block NSData* data;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: [NSString stringWithFormat:@"%@%@%d", ip, @"?action=getplayerdata&sessionid=", sessionID]]];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
        NSLog(@"aaa %@", data);

    });
     */
    
    // create the URL we'd like to query
    NSURL *myURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@%@%lu", ip, @"?action=getplayerdata&sessionid=", (long)[[Game sharedGame] sessionID]]];
                    
    // we'll receive raw data so we'll create an NSData Object with it
    NSData *myData = [[NSData alloc]initWithContentsOfURL:myURL];
                    
    id myJSON = [NSJSONSerialization JSONObjectWithData:myData options:NSJSONReadingMutableContainers error:nil];

    NSMutableArray *players = [NSMutableArray arrayWithCapacity:20];
    for (NSDictionary* playerData in myJSON) {
        if(![playerData[@"playerName"] isKindOfClass:[NSNull class]]) {
            player = [[Player alloc] init];

            [player setName: playerData[@"playerName"]];
            
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@/uploadedfiles/%d-%d.jpg", ip,
                                                                                              [[Game sharedGame] sessionID], [playerData[@"playerID"] intValue]]]];

            NSLog(@"%@",[NSString stringWithFormat:@"%@/uploadedfiles/%d-%d.jpg", ip,
                   [[Game sharedGame] sessionID], [playerData[@"playerID"] intValue]]);
            
            UIImage *image = [UIImage imageWithData: imageData];
            [player setImage: image];
            
        }
        else
            [player setName: @"empty"];
        
        //        [player setRole: (NSInteger)playerData[@"playerRole"]];
        //        [player setIsAlive: (bool)playerData[@"playerAlive"]];
        
        [players addObject:player];

    }

    
    return players;
}





- (NSDictionary *)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    return json;
}

- (void) removePlayerFromSession {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%lu%@%d", ip, @"?action=removeplayer&sessionid=", (long)[[Game sharedGame] sessionID], @"&playerid=", [[[Game sharedGame] myself] inGameID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    NSLog(@"response from server: %@", responseStr);
}

- (bool) isGameReady {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%lu", ip, @"?action=sessionready&sessionid=", (long)[[Game sharedGame] sessionID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    @try {
        //NSLog(@"Server returned ok: %d",  [responseStr integerValue]);
        return [responseStr boolValue];
    }
    @catch (NSException *e) {
        NSLog(@"Server returned exception: %@", responseStr);
        return -1;
    }
}

- (void) startGame {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%lu", ip, @"?action=startgame&sessionid=", (long)[[Game sharedGame] sessionID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    NSLog(@"response from server: %@", responseStr);
}

- (bool) isChanged {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%lu%@%d", ip, @"?action=ischanged&sessionid=", (long)[[Game sharedGame] sessionID], @"&playerid=", [[[Game sharedGame] myself] inGameID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    @try {
        //NSLog(@"Server returned ok: %d",  [responseStr integerValue]);
        return [responseStr boolValue];
    }
    @catch (NSException *e) {
        NSLog(@"Server returned exception: %@", responseStr);
        return -1;
    }
}

- (void) changeCleared {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%lu%@%d", ip, @"?action=changecleared&sessionid=", (long)[[Game sharedGame] sessionID], @"&playerid=", [[[Game sharedGame] myself] inGameID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    NSLog(@"response from server: %@", responseStr);

}

- (void) getSecret {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?action=getroleandsecret&sessionid=%lu&playerid=%lu", ip, (long)[[Game sharedGame] sessionID], (long)[[[Game sharedGame] myself] inGameID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    // will return a string in the form role;clue
    NSLog(@"response from server: %@", responseStr);
    
    NSArray *words = [responseStr componentsSeparatedByString:@";"];
    [[[Game sharedGame] myself] setRole: [words[0] integerValue]];
    [[[Game sharedGame] myself] setClue: words[1]];
    
}


// uploads the players current image to server.
- (void) uploadPlayerImage{
    
    UIImage *scaledProfileImage = [Utilities scaledImageCopyOfSize:[[[Game sharedGame] myself] image] : CGSizeMake(100, 100)];
    
    NSData *storeData = UIImageJPEGRepresentation(scaledProfileImage, 90);
    NSString *URLString = [NSString stringWithFormat:@"%@/uploadimage.php", ip];
    
    NSMutableURLRequest *request  = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *idItem = [NSString stringWithFormat:@"%d-%d", [[Game sharedGame] sessionID], [[[Game sharedGame] myself] inGameID]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n", idItem] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:storeData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    [request addValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    NSLog(@"body length %d",[body length]);
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *responseStr = [[NSString alloc] initWithData:returnData
                                                  encoding:NSUTF8StringEncoding];
}

//RobertTODO: return random order please, from server, so should be same for all player
- (NSMutableArray*) getOrder{
    if ([self didEveryoneGotOrder]) {
        [self clearOrder];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?action=getplayorder&sessionid=%lu&playerid=%lu", ip, (long)[[Game sharedGame] sessionID], (long)[[[Game sharedGame] myself] inGameID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    NSLog(@"response from server: %@", responseStr);
    
    NSMutableArray *arrayFromString = [[responseStr componentsSeparatedByString:@","] mutableCopy];
    
    return arrayFromString;
}

- (bool) didEveryoneGotOrder {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%lu", ip, @"?action=isordercleared&sessionid=", (long)[[Game sharedGame] sessionID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    @try {
        //NSLog(@"Server returned ok: %d",  [responseStr integerValue]);
        return [responseStr boolValue];
    }
    @catch (NSException *e) {
        NSLog(@"Server returned exception: %@", responseStr);
        return -1;
    }
}

- (void) clearOrder {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?action=clearorder&sessionid=%lu", ip, (long)[[Game sharedGame] sessionID]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSString* responseStr = [[NSString alloc] initWithData:response
                                                  encoding:NSUTF8StringEncoding];
    
    NSLog(@"response from server: %@", responseStr);
}


//RobertTODO: call the server with targetID, based on the role, different action applied on server, if i send targetID as -1, that is a empty action, but necessary to change the flag somehow
- (void)commitAction : (NSInteger) targetID{
    if (targetID >=0 && targetID < [[Game sharedGame] count]) {
        NSLog(@"action target is: No.%d - %@", targetID, [[[Game sharedGame] heroAtIndex:targetID] name]);
    }
    else{
        NSLog(@"non action committed");
    }
}

@end
