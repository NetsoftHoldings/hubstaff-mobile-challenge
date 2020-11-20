//
//  HTAllSitesResponseBlock.h
//  Hubstaff Test
//
//  Created by André Campana on 19.11.20.
//

#ifndef HTAllSitesResponseBlock_h
#define HTAllSitesResponseBlock_h

@class HTSite;

// Must see: http://goshdarnblocksyntax.com/
typedef void(^HTActiveSitesResultBlock)(NSArray<HTSite *> *sites);

#endif /* HTAllSitesResponseBlock_h */
